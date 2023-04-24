`timescale 1ns / 1ps
`include "parameters.vh"

`define mode_step_to_step 	8'b00000100 //4
`define mode_continue 		8'b00010000 //16

module debug_unit
	#(
		parameter CLOCK        = 50E6,
		parameter BAUD_RATE  = 9600,
		parameter NB_DATA    = 32,
		parameter NB_REG     = 5,
		parameter N_BITS     = 8,
		parameter N_BYTES    = 4,		
		parameter NB_STATE   = 11,
		parameter N_COUNT	 = 10			
	)
	(
		input wire i_clock,
		input wire i_reset,
		input wire i_halt,	
		input wire i_rx_data,	
		input wire [`ADDRWIDTH-1:0] i_send_program_counter, //pc + 1
		input wire [N_BITS-1:0] i_cant_cycles,
		input wire [NB_DATA-1:0] i_reg_debug_unit, //viene del banco de registros
		input wire i_bit_sucio,
		input wire [NB_DATA-1:0] i_mem_debug_unit,
		//DEBUG POR FALTA DE UART
		input wire data_rx_ready_uart,//rx_empty_o,
		input wire tx_to_pc_done,			
		input wire [NB_DATA-1:0] data_uart_receive,
		//####

		output reg [NB_REG-1:0] o_addr_reg_debug_unit,// direccion a leer del registro para enviar a pc

		output wire [`ADDRWIDTH:0] o_addr_mem_debug_unit, //direccion a leer en memoria
		output reg o_ctrl_addr_debug_mem,
		output reg o_ctrl_wr_debug_mem,
		output reg o_ctrl_read_debug_reg,
		output wire o_tx_data,
		output wire o_en_write, //habilitamos la escritura en memoria, sabiendo que el dato ya esta completo formando los 32 bits de la instruccion
		output wire o_en_read,		
		output reg o_enable_pipe,
		output reg o_enable_mem,
		
		output wire o_debug_unit_reg,				
		output wire [NB_DATA-1:0] o_inst_load, //instruccion a cargar en memoria
		output wire [`ADDRWIDTH-1:0] o_address, //direccion donde se carga la instruccion
		output reg o_ack_debug, //avisa al test que ya puede enviar el comando
		output reg o_end_send_data, //avisa al test que ya se termino de enviar datos de memoria

		/* para DEBUG */
		output wire o_data_ready,		
		output wire o_en_read_cant_instr,
		output wire o_receive_full_inst,
		output wire o_send_inst_finish,
		output wire [NB_STATE-1:0] o_state,
		output wire [N_BITS-1:0] o_data_receive,
		output wire tx_start_o			
	
	);

	localparam 	[NB_STATE-1:0]  Number_Instr        	=  11'b00000000001;
	localparam 	[NB_STATE-1:0]	Receive_One_Instr      	=  11'b00000000010;
	localparam 	[NB_STATE-1:0]	Check_Send_All_Instr 	=  11'b00000000100;
	localparam 	[NB_STATE-1:0]	Waiting_operation  		=  11'b00000001000;//8
	localparam 	[NB_STATE-1:0]	Check_Operation    		=  11'b00000010000;//16
	localparam 	[NB_STATE-1:0]	Step_to_step       		=  11'b00000100000;//32 
	localparam 	[NB_STATE-1:0]	Continue_to_Halt  		=  11'b00001000000;//64 
	localparam 	[NB_STATE-1:0]	Send_program_counter    =  11'b00010000000;//128 
	localparam 	[NB_STATE-1:0]	Send_cant_cyles 		=  11'b00100000000; 
	localparam 	[NB_STATE-1:0]	Send_Registers			=  11'b01000000000; 
	localparam 	[NB_STATE-1:0]	Send_Memory				=  11'b10000000000; 

	
    //wire data_rx_ready_uart;
	reg en_read_cant_instr, read_byte_to_byte, ready_full_inst, en_read_reg, en_write_reg, en_send_instr, all_instr_send, count_one_cycle, read_mode_operate;

	/* Finish send-data*/
	reg end_send_program_counter;
	reg end_send_cant_cycles;
	reg end_send_regs;
	reg end_send_mem;

	/******************/
	reg [N_BYTES-2:0] count_bytes;
	
	reg [N_BITS-1:0] operation_mode;
	//wire [N_BITS-1:0] data_uart_receive;
	reg [N_BITS-1:0] number_instructions, count_instruction_now;
	reg [`ADDRWIDTH-1:0] address_reg;
	reg [NB_DATA-1:0] instruction;
	reg [NB_STATE-1:0] state, next_state;
	reg [NB_REG-1:0] addr_debug_unit_reg;
    reg [`ADDRWIDTH:0] addr_mem_debug_unit_reg;
	reg  debug_unit_reg, enable_pipe_reg;

	/* enable envio de datos */
	reg en_send_program_counter, en_send_data_reg, en_send_data_mem, en_send_cant_cyles;	

	reg [N_BITS-1:0] cont_byte;
	//reg [N_BITS*5-1:0] mem_data;
		
	/* ********************************************** */
	reg tx_start;
	//wire tx_to_pc_done;
	reg data_ready, ready_number_instr, tx_done_data, bit_end_send_reg;

	reg mode_operate_ready, mode_operate_check;	
	reg [N_BITS-1:0] data_send, data_send_reg;   
		
	assign o_en_write    = en_write_reg;
	assign o_en_read     = en_read_reg;
	assign o_inst_load   = instruction;
	assign o_address     = address_reg;
	assign o_debug_unit_reg   = debug_unit_reg;		
	assign o_addr_mem_debug_unit = addr_mem_debug_unit_reg;

	/* para DEBUG */
	assign o_state = state;
	assign o_data_ready = data_rx_ready_uart;
	assign o_data_receive = data_uart_receive;
	assign o_en_read_cant_instr = en_read_cant_instr;
	assign o_receive_full_inst = ready_full_inst;
	assign o_send_inst_finish = all_instr_send;	
	assign tx_start_o = tx_start;

/* 
#############################################################################################
#############---Always para setear estado incial y desabilitar el pipeline---#################
############################################################################################## */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
	always @(posedge i_clock) 
		begin			
			if (i_reset) //Si se resetea seteamos Number_Instr como estado inicial y deshabilitamos el pipeline
				begin
					state <= Number_Instr;	
					o_enable_pipe <= 1'b0;
				end  					
			else
				begin
					state <= next_state;
					o_enable_pipe <= enable_pipe_reg;
				end
		end
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/*
##############################################################################################
#######################################---Number_Instr---######################################
##############################################################################################
*/
/* ++++++++++++++++++++++++++STEP QUE SE ENCARGAR DE RECIBIR NUMERO INSTRUCCIONES+++++++++++++++++++++++++++++ */
	always @(posedge i_clock)
    	begin
    		if (i_reset)
    			begin
    				//$display("Reset ok");
    				number_instructions <= {N_BITS{1'b0}};
    				ready_number_instr     = 1'b0;
    			end	
    		else
    			begin
    				if (en_read_cant_instr)
    					begin
    						if (data_rx_ready_uart)
    							begin
    								ready_number_instr     = 1'b1;
    								number_instructions = data_uart_receive;
    								//$display("Cantidad de instrucciones %d", number_instructions);
    							end
    						else
    							begin
    								ready_number_instr     = 1'b0;
    								number_instructions <= number_instructions;    								    							
    							end    						
    					end		    			
		    		else
		    			begin
		    				ready_number_instr  = ready_number_instr;
		    				number_instructions <= number_instructions;		    				
		    			end	  
    			end
    	end
/* ################################## STEP PARA LEER LA INSTRUCCION DE 32 bits en partes de 1 byte a la vez ################################## */
    always @(posedge i_clock)
    	begin
    		if (i_reset)
    			begin
    				ready_full_inst = 1'b0;
    				count_bytes <= {N_COUNT{1'b0}};
    			end  	
    		else
    			begin
    				if (read_byte_to_byte)
    					begin    						
    						if (data_rx_ready_uart)
    							begin
    								if (count_bytes == N_BYTES-1)
		    							begin
		    							//$display("Listo la instruccion de 4 bytes");		    								
		    								ready_full_inst = 1'b1;
		    								count_bytes <= {N_COUNT{1'b0}};
		    							end    						
		    						else
		    							begin		    								
		    								ready_full_inst = 1'b0;
		    								count_bytes <= count_bytes + {{N_COUNT-1{1'b0}},1'b1};
		    							end
		    					end
		    				else
		    					begin		    						
		    						ready_full_inst = 1'b0;
		    						count_bytes <= count_bytes; 
		    					end    						
    							
    					end		    			
		    		else
		    			begin		    			
		    				ready_full_inst = 1'b0;
		    				count_bytes <= count_bytes; 
		    			end 			
		    		
    			end
    	end

/* ################################## INCREMENTO ADDRES LOAD INSTR ################################## 	
	Aca se encargar de incrementar el addr cuando ya se envio una instruccions, es decir pasa al siguiente lugar a cargar
*/
    always @(posedge i_clock)
    	begin
    		if (i_reset) 
    			address_reg <= {`ADDRWIDTH{1'b0}};
    		else
    			begin
    				if (en_send_instr)
    					address_reg <= count_instruction_now + 1;
    				else
    					address_reg <= address_reg;
    			end
    	end
/* ################################## LOAD INSTRUCTION MEMORY ################################## 
	Aca lo que se hace es cargar la memoria del byte menos significativo al mas significativo, por eso siempre el dato ultimo se concatena al byte mas sigficativo
	En la proximas iteraciones se va dezplazando (cocatenando el nuevo en el max significativo)
*/

    always @(posedge i_clock)
    	begin
    		if (i_reset)
    			instruction <= {N_COUNT{1'b0}};
      		
    		else
    			begin
    				if (read_byte_to_byte)
    					begin
    						if (data_rx_ready_uart)
   								instruction <= { data_uart_receive, instruction[31:8]};
      						else
    							instruction <= instruction;
    					end    			
		    		else
		    			instruction <= instruction; 
    			end
    	end

/* ############################################### READ MODE OPERATE ####################################################### */
    always @(posedge i_clock)
    	begin
    		if (i_reset)
    			operation_mode <= {N_COUNT{1'b0}};
      		
    		else
    			begin
    				if (read_mode_operate)
    					operation_mode= data_uart_receive;						
 	    					    			
		    		else
		    			operation_mode <= operation_mode;
    			end
    	end

/* #############---BLOQUE QUE SE ENCARGA DE HABILIAR CAMBIO DE ESTADO SI Y SOLO SI LA DATA ESTA LISTA---################################### */

	always @(posedge i_clock)
    	begin
    		if (i_reset)
    			mode_operate_ready <= 1'b0;
    		else
    			begin
    				if (mode_operate_check)
    					begin
    						mode_operate_ready <= 1'b0;
    						if (data_rx_ready_uart)
  								mode_operate_ready <= 1'b1;
    					end		    			
		    		else
		    			mode_operate_ready <= mode_operate_ready;
    			end
    	end
/* #############---LOGICA PARA SABER CUANTAS CUANTAS INSTRUCCIONES SE VAN ENVIANDO, Y DECLARAR CUANDO SE TERMINA---############# */
    always @(posedge i_clock)
    	begin
    		if (i_reset)
    			begin
    				all_instr_send = 1'b0;
    				count_instruction_now <= {N_COUNT{1'b0}};
    			end
    			
    		else
    			begin
    				if (en_send_instr)
    					begin
    						if (count_instruction_now == number_instructions-1)
    							begin
    								all_instr_send = 1'b1;    								
    								count_instruction_now <= {N_COUNT{1'b0}}; 
    							end    							
    						else
    							begin
    								all_instr_send = 1'b0;
    								count_instruction_now <= count_instruction_now + 1;
    							end
    							
    					end
    					
    				else
    					begin
    						all_instr_send = all_instr_send;
    						count_instruction_now <= count_instruction_now;  						
    					end
    					
    			end
    	end
/* #############---ENVIO DE DATOS A LA COMPUTADORA---############# */     
   always @(posedge i_clock)
    	begin 			
    		if (i_reset)
    			begin
    				o_addr_reg_debug_unit <= {NB_REG{1'b0}};
    				end_send_regs <= 1'b0;
    				end_send_cant_cycles <= 1'b0;
    				addr_mem_debug_unit_reg <=  {`ADDRWIDTH{1'b0}};
    				data_send 		  <= 8'b0;
    				cont_byte 		  <= 8'b0;
    				end_send_program_counter  <= 1'b0;  
					tx_start = 1'b0;			 				
    			end    			
    		else
    			begin 
    				if (en_send_program_counter)
    					begin  
    						end_send_program_counter = 1'b0;    						

    						if (tx_to_pc_done)
    							begin 	
		    						if (cont_byte == 1'b1)
		    							begin
		    								end_send_program_counter = 1'b1;		    								
		    								cont_byte 		 <= 8'b0;
		    							end	    						 
		    						else
		    							begin
		    										    						 	
		    						 		data_send = i_send_program_counter;		    						 		
		    						 		cont_byte = cont_byte + 1;    						
    										tx_start = 1'b1;    										
		    						 	end 						  				
						  		end						    	  							
  
	    					else
	    						tx_start = 1'b0;						    	  						
		    			end
		    		else if (en_send_cant_cyles)
		    			begin
							end_send_cant_cycles = 1'b0;

							if (tx_to_pc_done)
				    			begin
				    			    if (cont_byte == 1'b1)
										begin
											end_send_cant_cycles = 1'b1;
											cont_byte 		 <= 8'b0;											
										end
									else
										begin
											data_send = i_cant_cycles;
					    					cont_byte = cont_byte + 1;					    					     								
					    					tx_start = 1'b1;					    					
										end	 
		    					end
		    				else
		    					begin
		    						tx_start = 1'b0;
						    		data_send <= data_send;
						    		cont_byte <= cont_byte;
		    					end 
		    			end
		    		else if (en_send_data_reg)
						begin							
							end_send_regs = 1'b0;
							o_addr_reg_debug_unit <= o_addr_reg_debug_unit;	

							if (tx_to_pc_done)
	    						begin	
	    							if (cont_byte == N_BYTES)
				    					begin
				    						end_send_regs = 1'b1;
				    						o_addr_reg_debug_unit <= o_addr_reg_debug_unit + 1;		//ACA AUMENTO A LA SIGUIENTE DIRECCION DEL REGISTRO A ENVIAR		    						
				    						cont_byte 		  <= 8'b0;
				    					end
				    				else 
				    					begin
					    					data_send = i_reg_debug_unit[8*cont_byte+:8]; //8*cont_byte+ -> determinan el inicio de los 8 bits que se toman de los 32 (0, 8, 16, 24) por ende se van a enviar desde el byte menos significativo hasta el mas significativo
					    					cont_byte = cont_byte + 1;								    		
								    		tx_start = 1'b1;  								
					    				end	 
			    				end
			    			else
			    				begin			    					
			    					tx_start = 1'b0;
						    		data_send <= data_send;
						    		cont_byte <= cont_byte;
			    				end
			    		end
			    	else if (en_send_data_mem)
						begin
							end_send_mem = 1'b0;
							addr_mem_debug_unit_reg <= addr_mem_debug_unit_reg;

							if (tx_to_pc_done)
				    			begin				    				
				    				if (i_bit_sucio)
				    					begin
				    						if (cont_byte == N_BYTES)
				    							begin
				    								end_send_mem = 1'b1;
				    								addr_mem_debug_unit_reg <= addr_mem_debug_unit_reg + 1;	//ACA AUMENTO A LA SIGUIENTE DIRECCION DE MEMORIA A ENVIAR		    								
				    								cont_byte 		 <= 8'b0;
				    							end
				    						else
				    							begin
						    						data_send = i_mem_debug_unit[8*cont_byte+:8];				    											    						
						    						cont_byte = cont_byte + 1;			                                            									    		
										    		tx_start = 1'b1;										    		
										    	end	
				    					end
				    				else
				    					begin
				    						end_send_mem = 1'b1;
				    						addr_mem_debug_unit_reg <= addr_mem_debug_unit_reg + 1;					    						
										end
			    						
				    			end
				    		else
			    				begin			    					
			    					tx_start = 1'b0;
						    		data_send <= data_send;
						    		cont_byte <= cont_byte;
			    				end
				    	end 
		    		else 
		    			begin
		    				end_send_program_counter  	= 1'b0;
		    				end_send_regs 				= 1'b0;
							end_send_cant_cycles 		= 1'b0;
		    				end_send_mem 				= 1'b0;
					    	data_send <= data_send;
					    	cont_byte <= cont_byte;  
		    			end
		    	end
		end
   	
  /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

	always @(*) //logica de cambio de estado
		begin: next_state_logic		    
			next_state = state;
			enable_pipe_reg = 1'b0;			
			read_mode_operate = 1'b0;
			en_write_reg = 1'b0;
			en_read_reg = 1'b0;
			en_read_cant_instr = 1'b0; // habilita leer la cantidad de instrucciones a cargar en memoria
			read_byte_to_byte = 1'b0;  // habilita leer bytes de las instr.
			en_send_instr = 1'b0; // habilita cargar en memoria instruccion por instr.

			mode_operate_check = 1'b0;
			o_enable_mem = 1'b0;			
			debug_unit_reg = 1'b1; 

			o_ack_debug = 1'b0;	//habilita a la pc a enviar datos				
			o_end_send_data = 1'b0;	
			/* envio de datos*/
			en_send_program_counter   = 1'b0;
			en_send_data_reg    = 1'b0;
			en_send_data_mem    = 1'b0;
			en_send_cant_cyles = 1'b0;

			o_ctrl_read_debug_reg = 1'b0;
				
			
			o_ctrl_addr_debug_mem = 1'b0;
			o_ctrl_wr_debug_mem = 1'b0;			
			case (state)
				//En este estado inicial es el que se encarga de recibir la cantidad total de instrucciones a tratar
				Number_Instr:
					begin
						next_state  = Number_Instr;	
						en_read_cant_instr = 1'b1;
						if (ready_number_instr)
							begin								
								next_state  = Receive_One_Instr;
								en_read_cant_instr = 1'b0;
							end								    						      					
					end	
				//Recibe UNA instruccion en partes un byte (4 partes para formar la instruccion de 32 bits)		
				Receive_One_Instr:
					begin
						next_state = Receive_One_Instr;
						read_byte_to_byte = 1'b1;					
						if (ready_full_inst) //Cuando esta lista la instruccion, la manda y pasa al siguiente estado
							begin																												
								next_state = Check_Send_All_Instr;
								en_send_instr = 1'b1;
								en_write_reg = 1'b1;	 //habilito la escritura en memoria del pipeline															
							end								      
						  					
					end				
				Check_Send_All_Instr:			//Estado con el que verificamos si se termino el envio de instrucciones		
					begin
						//$display("Check Send Inst");						
						en_send_instr = 1'b0;
						if (all_instr_send)
							begin	
								//$display("Pasando a waiting");
								o_ack_debug = 1'b1; //mando a la pc que esta todo ok por el momento
								next_state  = Waiting_operation;								
							end
						else
							//$display("Todavia no se termino de enviat instrucciones");	
							next_state  = Receive_One_Instr;	
					end	
				Waiting_operation:
					begin
						//$display("state Waiting_operation");
						mode_operate_check = 1'b1;
						debug_unit_reg = 1'b0;						

						if (mode_operate_ready)
							begin								
								next_state = Check_Operation;
								read_mode_operate = 1'b1;
							end											
						else
							next_state = Waiting_operation;				

					end					
				Check_Operation:
					begin						
						debug_unit_reg = 1'b0;
						case (operation_mode)
							`mode_step_to_step:
								next_state = Step_to_step;	
							`mode_continue:
								next_state = Continue_to_Halt;	
							default:
								next_state = Waiting_operation;
						endcase				
					end						
				Step_to_step:
					//Step en donde habilitamos el pipeline para que se corra un ciclo
					begin
						if(count_one_cycle == 0)
							begin
								en_read_reg = 1'b1;
								enable_pipe_reg = 1'b1;
								o_enable_mem = 1'b1;							
								debug_unit_reg = 1'b0;
								en_write_reg = 1'b0;						
								count_one_cycle = 1;
								next_state = Step_to_step;
							end
						else
							begin
								en_read_reg = 1'b1;	
								debug_unit_reg = 1'b0;
								en_write_reg = 1'b0;	
								en_send_program_counter = 1'b1;
								next_state = Send_program_counter;

								if (i_halt)
								begin
									enable_pipe_reg = 1'b0;															
									en_send_program_counter = 1'b1;
								end
							end							
					end
				Continue_to_Halt:
					begin						
						en_read_reg = 1'b1;
						enable_pipe_reg = 1'b1;
						o_enable_mem = 1'b1;						
						next_state = Continue_to_Halt;
						debug_unit_reg = 1'b0;
						en_write_reg = 1'b0;						
						
						if (i_halt)
							begin
								//$display("salto halt");	
								enable_pipe_reg = 1'b0;
								en_send_program_counter = 1'b1;
								next_state = Send_program_counter;
								
							end
					end				
				Send_program_counter:
					begin							
						debug_unit_reg = 1'b0;
						en_send_program_counter = 1'b1;
						next_state = Send_program_counter;						

						if (end_send_program_counter)
							begin																							
								en_send_program_counter = 1'b0;	
								next_state = Send_cant_cyles;							
							end	
					end	
				Send_cant_cyles:
					begin						
						debug_unit_reg = 1'b0;
						en_send_cant_cyles = 1'b1;						
						next_state = Send_cant_cyles;

						if (end_send_cant_cycles)
							begin
								en_send_cant_cyles = 1'b0;
								o_ctrl_read_debug_reg = 1'b1;													
								next_state = Send_Registers;
							end												
					end				
				Send_Registers:
					begin						
						debug_unit_reg = 1'b0;
						en_send_data_reg = 1'b1;
						o_ctrl_read_debug_reg = 1'b1;
						next_state = Send_Registers;
					
						if (end_send_regs)
							begin								
								if (o_addr_reg_debug_unit == 5'b0) //Quiere decir que se llego al numero 32 ya que se envio desde el 0 al 31, (32 == 100000)
	    							begin
	    								//$display("Pasando a enviar memoria");
	    								o_ctrl_read_debug_reg = 1'b0;
	      								en_send_data_reg = 1'b0;

										next_state = Send_Memory;										
										o_ctrl_wr_debug_mem = 1'b1;
										o_ctrl_addr_debug_mem = 1'b1;
										o_enable_mem = 1'b1;										
	    							end	    							
							end
					end				
				Send_Memory:
					begin	
						debug_unit_reg = 1'b0;
						o_ctrl_wr_debug_mem = 1'b1;
						o_ctrl_addr_debug_mem = 1'b1;
						en_send_data_mem = 1'b1;
						o_enable_mem = 1'b1;
					
						next_state = Send_Memory;
						if (end_send_mem)
							begin
								if (addr_mem_debug_unit_reg == `N_ELEMENTS-1)
									begin
										o_end_send_data = 1'b1;										
										en_send_data_mem = 1'b1;										
										o_ack_debug = 1'b1;
										next_state = Waiting_operation;
										//$display("FINISH ENVIO DE DATOS");	
									end	
							end		
					end
					
							
				default:
					next_state = Number_Instr;					
			endcase
		end
	
/*
	uart#(.CLOCK(CLOCK), .BAUD_RATE(BAUD_RATE)) uart
	(
		.clock(i_clock),
		.reset(i_reset),
		.i_tx_data(data_send), ///DATA DE LO QUE VOY A ENVIAR A LA PC
		.i_tx_start(tx_start), //Inicio la trasmicion del byte al pipeline
		.i_rx_data(i_rx_data), //DATA DE LO QUE VOY RECIBIENDO DE LA PC

		.o_tx_done(tx_to_pc_done), //TERMINO LA TRASMICION DEL BYTE
		.o_tx_data(o_tx_data), //por donde se manda el bit a bit
		.o_rx_finish(data_rx_ready_uart), //SE ALERTA QUE ESTA LISTO EN o_rx_data EL BYTE QUE SE RECIBIO
		.o_rx_data(data_uart_receive)
	);*/

	
endmodule