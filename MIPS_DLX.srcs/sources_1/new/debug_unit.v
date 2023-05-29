`timescale 1ns / 1ps
`include "parameters.vh"

`define mode_step_to_step 	8'b00000100 //4
`define mode_continue 			8'b00010000 //16

module debug_unit
	#(
		parameter CLOCK      = 50E6,
		parameter BAUD_RATE  = 9600,
		parameter NB_DATA    = 32,
		parameter NB_REG     = 5,
		parameter N_BITS     = 8,
		parameter N_BYTES    = 4,		
		parameter NB_STATE   = 12,
		parameter N_COUNT	 	 = 10			
	)
	(
		input wire i_clock,
		input wire i_reset,
		input wire i_halt,	
		input wire i_rx_data,	
		input wire [`ADDRWIDTH:0] i_send_program_counter, //pc + 1
		input wire [N_BITS-1:0] 	i_cant_cycles,
		input wire [NB_DATA-1:0] 	i_reg_debug_unit, //viene del banco de registros
		input wire i_bit_sucio,
		input wire [NB_DATA-1:0] 	i_mem_debug_unit,

		output reg [NB_REG-1:0] 	o_addr_reg_debug_unit,// direccion a leer del registro para enviar a pc

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
		output wire [NB_DATA-1:0] 		o_inst_load, //instruccion a cargar en memoria
		output wire [`ADDRWIDTH-1:0] 	o_address, //direccion donde se carga la instruccion
		output reg o_ack_debug, //avisa al test que ya puede enviar el comando
		output reg o_end_send_data, //avisa al test que ya se termino de enviar datos de memoria

		/* para DEBUG */
		output wire o_data_ready,		
		output wire o_en_read_cant_instr,
		output wire o_receive_full_inst,
		output wire o_send_inst_finish,
		output wire [NB_STATE-1:0] o_state,
		output wire [N_BITS-1:0] o_data_receive,
		output wire o_tx_start			
	
	);
	localparam 	[NB_STATE-1:0]  Number_Instr        	=  12'b000000000001;//1
	localparam 	[NB_STATE-1:0]	Receive_One_Instr     =  12'b000000000010;//2
	localparam 	[NB_STATE-1:0]	Check_Send_All_Instr 	=  12'b000000000100;//4
	localparam 	[NB_STATE-1:0]	Waiting_operation  		=  12'b000000001000;//8
	localparam 	[NB_STATE-1:0]	Check_Operation    		=  12'b000000010000;//16 To choose between step or continuous mode
	localparam 	[NB_STATE-1:0]	Step_to_step       		=  12'b000000100000;//32 
	localparam 	[NB_STATE-1:0]	Wait_One_Cicle     		=  12'b000001000000;//64 
	localparam 	[NB_STATE-1:0]	Continue_to_Halt  		=  12'b000010000000;//128 For continuous mode
	localparam 	[NB_STATE-1:0]	Send_program_counter  =  12'b000100000000;//256 
	localparam 	[NB_STATE-1:0]	Send_cant_cyles 			=  12'b001000000000;//512
	localparam 	[NB_STATE-1:0]	Send_Registers				=  12'b010000000000;//1024 
	localparam 	[NB_STATE-1:0]	Send_Memory						=  12'b100000000000;//2048

	reg en_read_cant_instr, read_byte_to_byte, ready_full_inst, en_read_reg, en_write_reg, en_send_instr, all_instr_send, read_mode_operate;
  reg count_one_cycle = 0;
	/* UART */
	reg data_rx_ready_uart;

	/* Finish send-data*/
	reg end_send_program_counter;
	reg end_send_cant_cycles;
	reg end_send_reg;
	reg end_send_mem;

	/******************/
	reg [1:0] count_bytes;
	
	reg [N_BITS-1:0] operation_mode;
	wire [N_BITS-1:0] data_uart_receive;
	reg [N_BITS-1:0] number_instructions, count_instruction_now;
	reg [`ADDRWIDTH-1:0] address_reg;
	reg [NB_DATA-1:0] instruction;
	reg [NB_STATE-1:0] state = Number_Instr;
	reg [NB_STATE-1:0] next_state = Number_Instr;
	reg [NB_REG-1:0] addr_debug_unit_reg;
    reg [`ADDRWIDTH:0] addr_mem_debug_unit_reg;
	reg  debug_unit_reg, enable_pipe_reg;

	/* enable envio de datos */
	reg en_send_program_counter, en_send_data_reg, en_send_data_mem, en_send_cant_cyles;	

	reg [N_BITS-1:0] cont_byte;
	//reg [N_BITS*5-1:0] mem_data;
		
	/* ********************************************** */
	/* SEND DATA TO THE COMPUTER*/
	
	//Este es un delay para tener en cuenta entre la diferencia por TX y RX. 
	//De esa manera se evita transmitir cuando el receptor no esta listo
	localparam integer WAIT_TX = 36*(CLOCK / (BAUD_RATE*16)); 

	reg tx_start = 0;
	reg tx_to_computer_done_aux = 0;
	reg tx_to_computer_done = 0;
	reg data_ready, ready_number_instr, bit_end_send_reg;

	reg ready_mode_operate, en_read_mode_operate;	
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
	assign o_tx_start = tx_start;



/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
//Always para compatibilzar timing con UART
wire rx_done_uart;
always @(posedge rx_done_uart)
begin
    data_rx_ready_uart <= 1;
    #1
    data_rx_ready_uart <= 0;
end

wire tx_done_uart;
always @(posedge tx_done_uart)
begin
	#WAIT_TX  //Para que espere al RX y vuelva a transmitir
    tx_to_computer_done <= 1;
    #5
    tx_to_computer_done <= 0;
end

always @(posedge tx_start)
begin
	#100
	tx_start <= 1'b0;
end







	always @(i_clock)
    	begin
				state <= next_state;
				o_enable_pipe <= enable_pipe_reg;
				if (i_reset)
					begin
						data_rx_ready_uart 				<= 1'b0;
						operation_mode						<= {N_BITS{1'b0}};
						o_addr_reg_debug_unit 		<= {NB_REG{1'b0}};
						end_send_reg 			 				<= 1'b0;
						end_send_mem							<= 1'b0;
						end_send_cant_cycles 			<= 1'b0;
						addr_mem_debug_unit_reg 	<=  {`ADDRWIDTH{1'b0}};
						data_send 		  					<= 8'b0;
						cont_byte 		  					<= 8'b0;
						end_send_program_counter  <= 1'b0;  
						tx_start 									<= 1'b0;		
						all_instr_send 						<= 1'b0;
						count_instruction_now 		<= {N_COUNT{1'b0}};	
						ready_mode_operate 				<= 1'b0; 	
						instruction 							<= {N_COUNT{1'b0}};		
						address_reg 							<= {`ADDRWIDTH{1'b0}};
						ready_full_inst 					<= 1'b0;
						count_bytes 							<= 2'b0;
						number_instructions 			<= {N_BITS{1'b0}};
						ready_number_instr     		<= 1'b0;	
						state 										<= Number_Instr;	
						o_enable_pipe 						<= 1'b0;
					end
				else 
					begin
						if (en_send_instr)
							begin
								if (count_instruction_now == number_instructions-1)
									begin
										all_instr_send <= 1'b1;    								
										count_instruction_now <= {N_COUNT{1'b0}}; 
									end    							
								else
									begin
										all_instr_send <= 1'b0;
										count_instruction_now <= count_instruction_now + 1;
									end
									
							end
						if (read_mode_operate)
							operation_mode <= data_uart_receive;	 
						if (en_send_instr)
							address_reg <= count_instruction_now + 1;
			
						else
							begin
								ready_number_instr  = ready_number_instr;
								number_instructions <= number_instructions;		
								ready_full_inst <= ready_full_inst;
								count_bytes <= count_bytes; 
								address_reg <= address_reg;   
								instruction <= instruction; 		
								operation_mode <= operation_mode;		
								ready_mode_operate <= ready_mode_operate;
								all_instr_send = all_instr_send;
								count_instruction_now <= count_instruction_now;  	
							end	  	
					end
			end


	always @(posedge data_rx_ready_uart)
		begin
			if (en_read_cant_instr)	
				begin
					ready_number_instr  <= 1'b1;
					number_instructions <= data_uart_receive;
				end
			if (read_byte_to_byte)
				begin 
					instruction <= { data_uart_receive, instruction[31:8]};
					if (count_bytes == N_BYTES-1)
						begin	    								
							ready_full_inst <= 1'b1;
						end    						
					else
						begin		    								
							ready_full_inst <= 1'b0;
							count_bytes <= count_bytes + 1'b1;//count_bytes + {{N_COUNT-1{1'b0}},1'b1};
						end
				end
			if (en_read_mode_operate)
				begin
					ready_mode_operate <= 1'b1;
					operation_mode <= data_uart_receive;
				end
		end
	always @(negedge data_rx_ready_uart)
		begin
			if (en_read_cant_instr)	
				begin
					ready_number_instr  <= 1'b0;
					number_instructions <= number_instructions;
				end
			if (read_byte_to_byte)
				begin 
					instruction <= instruction;    						
					ready_full_inst <= ready_full_inst;
					count_bytes <= count_bytes; 
				end
			if (en_read_mode_operate)
				begin
					ready_mode_operate <= 1'b0;
					operation_mode <= operation_mode;
				end
				
		end





  always @(posedge tx_to_computer_done)
    begin        	
    if (en_send_program_counter) //ACA SE ENVIA EL PROGRAM COUNTER
			begin  
					end_send_program_counter <= 1'b1;    											    											  								    	  											    	  						
			end
    else if (en_send_cant_cyles)
			begin
					end_send_cant_cycles = 1'b1;   					     									    					
			end
  
		else if (en_send_data_reg)
			begin							
				end_send_reg 					<= 1'b0;
				o_addr_reg_debug_unit <= o_addr_reg_debug_unit;	
				//ACA ENVIO REGISTRO A REGISTRO PERO POR PARTES, OSEA QUE MANDO 4 bytes de un reg y paso al siguiente
				if (cont_byte == N_BYTES)
					begin
						end_send_reg 					<= 1'b1;
						o_addr_reg_debug_unit <= o_addr_reg_debug_unit + 1;		//ACA AUMENTO A LA SIGUIENTE DIRECCION DEL REGISTRO A ENVIAR		    						
						cont_byte 		  			<= 8'b0;
					end
				else 
					begin
						data_send <= i_reg_debug_unit[8*cont_byte+:8]; //8*cont_byte+ -> determinan el inicio de los 8 bits que se toman de los 32 (0, 8, 16, 24) por ende se van a enviar desde el byte menos significativo hasta el mas significativo
						cont_byte <= cont_byte + 1;								    		
						tx_start 	<= 1'b1;  								
					end	 
			end
    
		
		
		
		else if (en_send_data_mem)
			begin
				end_send_mem 						<= 1'b0;
				addr_mem_debug_unit_reg <= addr_mem_debug_unit_reg; 				
				if (i_bit_sucio)
					begin
						if (cont_byte == N_BYTES)
							begin
								end_send_mem 						<= 1'b1;
								addr_mem_debug_unit_reg <= addr_mem_debug_unit_reg + 1;	//ACA AUMENTO A LA SIGUIENTE DIRECCION DE MEMORIA A ENVIAR		    								
								cont_byte 		 					<= 8'b0;										    		
							end
						else
							begin
								data_send <= i_mem_debug_unit[8*cont_byte+:8];				    											    						
								cont_byte <= cont_byte + 1;			                                            									    		
								tx_start 	<= 1'b1;										    		
							end	
					end
				else
					begin
						data_send								<= data_send;	
						end_send_mem 						<= end_send_mem;
						addr_mem_debug_unit_reg <= addr_mem_debug_unit_reg + 1;					    						
					end
			end 
    else 
			begin
					end_send_program_counter  <= end_send_program_counter;
				end_send_reg 								<= end_send_reg;
					end_send_cant_cycles 			<= end_send_cant_cycles;
					end_send_mem 							<= end_send_mem;
					data_send 								<= data_send;
					cont_byte 								<= cont_byte;  
			end
    end

	always @(negedge tx_to_computer_done)
		begin
			if (en_send_cant_cyles)
				begin
					data_send <= data_send;
					cont_byte <= cont_byte;
				end
			else if (en_send_data_reg || en_send_data_mem)
				begin		    					
					tx_start 	<= tx_start;
					data_send <= data_send;
					cont_byte <= cont_byte;
				end
		end
		
  /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

	always @(*) //logica de cambio de estado
		begin: next_state_logic		    
			next_state 								= state;
			enable_pipe_reg	 					= 1'b0;			
			read_mode_operate 				= 1'b0;
			en_write_reg 							= 1'b0;
			en_read_reg								= 1'b0;
			en_read_cant_instr 				= 1'b0; // habilita leer la cantidad de instrucciones a cargar en memoria
			read_byte_to_byte 				= 1'b0;  // habilita leer bytes de las instr.
			en_send_instr 						= 1'b0; // habilita cargar en memoria instruccion por instr.
			en_read_mode_operate 			= 1'b0;
			o_enable_mem 							= 1'b0;			
			debug_unit_reg 						= 1'b1; 
			o_ack_debug 							= 1'b0;	//habilita a la pc a enviar datos				
			o_end_send_data 					= 1'b0;	
			/* envio de datos*/
			en_send_program_counter 	= 1'b0;
			en_send_data_reg    			= 1'b0;
			en_send_data_mem    			= 1'b0;
			en_send_cant_cyles 				= 1'b0;
			o_ctrl_read_debug_reg 		= 1'b0;
			o_ctrl_addr_debug_mem 		= 1'b0;
			o_ctrl_wr_debug_mem 			= 1'b0;			
			
			case (state)
				Number_Instr: 						//1
					begin
						next_state  = Number_Instr;	
						en_read_cant_instr = 1'b1;
						if (ready_number_instr)
							begin								
								next_state  = Receive_One_Instr;
								en_read_cant_instr = 1'b0;
							end								    						      					
					end	
				
				Receive_One_Instr: 				//2
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
				
				Check_Send_All_Instr:			//4		//Estado con el que verificamos si se termino el envio de instrucciones		
					begin					
						en_send_instr = 1'b0;
						if (all_instr_send)
							begin	
								o_ack_debug = 1'b1; //mando a la pc que esta todo ok por el momento
								next_state  = Waiting_operation;								
							end
						else
							next_state  = Receive_One_Instr;	
					end	
				
				Waiting_operation: 				//8	
					begin
						next_state  = Waiting_operation;	
						en_read_mode_operate = 1'b1;
						debug_unit_reg = 1'b0;						

						if (ready_mode_operate)
							begin								
								next_state = Check_Operation;
								en_read_mode_operate = 1'b0;
							end													

					end					
				
				Check_Operation: 					//16 //Case que elige el modo de operacion, STEP o CONTINUO
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
				
				Step_to_step:							//32
					begin	
						en_read_reg = 1'b1;
						enable_pipe_reg = 1'b1;
						o_enable_mem = 1'b1;	
						debug_unit_reg = 1'b0;
						en_write_reg = 1'b0;						
						next_state = Wait_One_Cicle;
					end
				
				Wait_One_Cicle:						//64	
					//Step en donde habilitamos el pipeline para que se corra un ciclo
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
				
				Continue_to_Halt:					//128	
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
								enable_pipe_reg <= 1'b0;
								en_send_program_counter <= 1'b1;
								next_state <= Send_program_counter;
								data_send <= i_send_program_counter;
								tx_start <= 1'b1;
							end
					end				
				
				Send_program_counter:  		//256
					begin							
						debug_unit_reg = 1'b0;
						en_send_program_counter = 1'b1;
						next_state = Send_program_counter;						
						
						if (end_send_program_counter)
							begin																							
								en_send_program_counter = 1'b0;	
								next_state = Send_cant_cyles;
								data_send <= i_cant_cycles;
								tx_start <= 1'b1;
							end	
					end	
				
				Send_cant_cyles:					//512	
					begin						
						debug_unit_reg = 1'b0;
						en_send_cant_cyles = 1'b1;						
						next_state = Send_cant_cyles;
						
						if (end_send_cant_cycles)
							begin
								en_send_cant_cyles = 1'b0;
								o_ctrl_read_debug_reg = 1'b1;													
								next_state = Send_Registers;
								data_send <= i_reg_debug_unit;
								cont_byte = 1'b0;
							end												
					end				
				
				Send_Registers:						//1024		
					begin					
						debug_unit_reg = 1'b0;
						en_send_data_reg = 1'b1;
						o_ctrl_read_debug_reg = 1'b1;
						next_state = Send_Registers;
						tx_start = 1'b1;
						if (end_send_reg)
							begin								
								if (o_addr_reg_debug_unit == 5'b0) //Quiere decir que se llego al numero 32 ya que se envio desde el 0 al 31, (32 == 100000)
	    							begin
	    								o_ctrl_read_debug_reg = 1'b0;
	      							en_send_data_reg = 1'b0;
											next_state = Send_Memory;										
											o_ctrl_wr_debug_mem = 1'b1;
											o_ctrl_addr_debug_mem = 1'b1;
											o_enable_mem = 1'b1;		
											data_send <= i_mem_debug_unit;
	    							end	    							
							end
					end				
				
				Send_Memory:							//2048	
					begin	
						debug_unit_reg = 1'b0;
						o_ctrl_wr_debug_mem = 1'b1;
						o_ctrl_addr_debug_mem = 1'b1;
						en_send_data_mem = 1'b1;
						o_enable_mem = 1'b1;
						next_state = Send_Memory;
						tx_start = 1'b1;
						
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




	uart#(.CLK(CLOCK), .BAUD_RATE(BAUD_RATE)) uart
	(
		//Inputs
		.clock(i_clock),
        .reset(i_reset),
        .tx_start(tx_start),
        .rx(i_rx_data),
        .tx_data(data_send),
        .parity(1),
        //Outputs
				.rx_data(data_uart_receive),
        .tx(o_tx_data),
        .rx_done(rx_done_uart),
        .tx_done(tx_done_uart)
	);

endmodule