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
		input wire [`ADDRWIDTH-1:0] i_send_program_counter, //pc + 1
		input wire [N_BITS-1:0] 	i_cant_cycles,
		input wire [NB_DATA-1:0] 	i_reg_debug_unit, //viene del banco de registros
		input wire i_bit_sucio,
		input wire [NB_DATA-1:0] 	i_mem_debug_unit,

		output reg [NB_REG-1:0] 	o_addr_reg_debug_unit,// direccion a leer del registro para enviar a pc

		output reg [`ADDRWIDTH-1:0] o_addr_mem_debug_unit, //direccion a leer en memoria
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
		output wire [NB_STATE-1:0] o_state
	);
	localparam 	[NB_STATE-1:0]  Number_Instr        	=  16'b0000000000000001;//1
	localparam 	[NB_STATE-1:0]	Receive_One_Instr     	=  16'b0000000000000010;//2
	localparam 	[NB_STATE-1:0]	Check_Send_All_Instr	=  16'b0000000000000100;//4
	localparam 	[NB_STATE-1:0]	Waiting_operation  		=  16'b0000000000001000;//8
	localparam 	[NB_STATE-1:0]	Check_Operation    		=  16'b0000000000010000;//16 To choose between step or continuous mode
	localparam 	[NB_STATE-1:0]	Step_to_step       		=  16'b0000000000100000;//32 
	localparam 	[NB_STATE-1:0]	Wait_One_Cicle     		=  16'b0000000001000000;//64 
	localparam 	[NB_STATE-1:0]	Continue_to_Halt  		=  16'b0000000010000000;//128 For continuous mode
	localparam 	[NB_STATE-1:0]	Send_program_counter  	=  16'b0000000100000000;//256 
	localparam 	[NB_STATE-1:0]	Send_cant_cyles 		=  16'b0000001000000000;//512
	localparam 	[NB_STATE-1:0]	Send_one_reg			=  16'b0000010000000000;//1024
	localparam 	[NB_STATE-1:0]	Check_send_all_regs		=  16'b0000100000000000;//2048  
	localparam 	[NB_STATE-1:0]	Check_bit_sucio			=  16'b0001000000000000;//4096
	localparam 	[NB_STATE-1:0]	Send_addr_mem			=  16'b0010000000000000;//8192
	localparam 	[NB_STATE-1:0]	Send_data_mem			=  16'b0100000000000000;//16264
	localparam 	[NB_STATE-1:0]	Check_send_all_mems		=  16'b1000000000000000;//32528
	
	wire ready_full_inst;
	wire ready_number_instr;
	wire all_instr_send;
	wire [N_BITS-1:0] operation_mode;
	wire ready_mode_operate;
	wire [N_BITS-1:0] number_instructions;
	wire [`ADDRWIDTH-1:0] addr_instruction;

	wire [N_BITS-1:0] data_uart_receive;
	reg enable_read_cant_instr, enable_read_byte_to_byte, en_read_reg, en_write_reg, enable_read_instr;

	/* Finish send-data*/
	reg end_send_pc, enable_send_pc;
	reg end_send_cant_cycles, enable_send_cant_cycles;
	reg end_send_one_reg, enable_send_one_reg;
	reg end_send_mem;

	/******************/
	
	reg [NB_STATE-1:0] state, next_state;
	reg  debug_unit_reg, enable_pipe_reg, en_send_program_counter, en_send_data_reg, en_send_data_mem;	
	
	
	reg [1:0] count_bytes;
	reg [2:0] cont_byte;
	

	reg tx_start;
	reg next_tx_start;
	reg en_read_mode_operate;	
	reg [N_BITS-1:0] data_send;   
		
	assign o_en_write    = en_write_reg;
	assign o_en_read     = en_read_reg;
	assign o_address     = addr_instruction-1;
	assign o_debug_unit_reg   = debug_unit_reg;		

	/* para DEBUG */
	assign o_state = state;


wire tx_done_uart;


always @(negedge i_clock) 
begin
  	state <= next_state;
	o_enable_pipe <= enable_pipe_reg;
  	if (i_reset) 
		begin
			// Asignaciones durante el reset
			o_addr_reg_debug_unit <= {NB_REG{1'b0}};
			end_send_mem <= 1'b0;
			end_send_cant_cycles <= 1'b0;
			o_addr_mem_debug_unit <= {`ADDRWIDTH{1'b0}};
			data_send <= {N_BITS{1'b0}};
			cont_byte <= {N_BITS{1'b0}};
			enable_send_pc <= 1'b0;
			end_send_pc <= 1'b0;
			end_send_one_reg  <= 1'b0;
			tx_start <= 1'b0;
			cont_byte <= {N_BITS{1'b0}};
			state <= {NB_STATE{1'b0}};
			next_state <= {NB_STATE{1'b0}};
			o_enable_pipe <= 1'b0;
		end 
	else
	begin
		if(enable_send_pc || enable_send_cant_cycles || enable_send_one_reg)
		begin
			tx_start <= 1'b1;
		end
		if(tx_done_uart)
		begin
			tx_start <= 1'b0;
		  	if(enable_send_pc)
		  		end_send_pc <= 1'b1;
			if(enable_send_cant_cycles)
		  		end_send_cant_cycles <= 1'b1;
			if(enable_send_one_reg)
			begin
				cont_byte = cont_byte + 1;
				if (cont_byte > N_BYTES-1)
				begin
					end_send_one_reg  <= 1'b1;
					cont_byte <= 3'b0;
				end
						
			end
				
		end
	end
end		


	
  /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

	always @(posedge i_clock) //logica de cambio de estado
		begin: next_state_logic		    
			next_state 								= state;
			enable_pipe_reg	 					= 1'b0;			
			en_write_reg 							= 1'b0;
			en_read_reg								= 1'b0;
			enable_read_cant_instr 				= 1'b0; // habilita leer la cantidad de instrucciones a cargar en memoria
			enable_read_byte_to_byte 				= 1'b0;  // habilita leer bytes de las instr.
			enable_read_instr 						= 1'b0; // habilita cargar en memoria instruccion por instr.
			en_read_mode_operate 			= 1'b0;
			o_enable_mem 							= 1'b0;			
			debug_unit_reg 						= 1'b1; 
			o_ack_debug 							= 1'b0;	//habilita a la pc a enviar datos				
			o_end_send_data 					= 1'b0;	
			/* envio de datos*/
			en_send_program_counter 	= 1'b0;
			en_send_data_reg    			= 1'b0;
			en_send_data_mem    			= 1'b0;
			enable_send_cant_cycles 				= 1'b0;
			o_ctrl_read_debug_reg 		= 1'b0;
			o_ctrl_addr_debug_mem 		= 1'b0;
			o_ctrl_wr_debug_mem 			= 1'b0;	
			enable_send_one_reg = 1'b0;
					
			
			case (state)
				Number_Instr: 						//1
					begin
						next_state  = Number_Instr;	
						enable_read_cant_instr = 1'b1;
						if (ready_number_instr)
							begin								
								next_state  = Receive_One_Instr;
								enable_read_cant_instr = 1'b0;
							end								    						      					
					end	
				Receive_One_Instr: 				//2
					begin
						next_state = Receive_One_Instr;
						enable_read_byte_to_byte = 1'b1;					
						if (ready_full_inst) //Cuando esta lista la instruccion, la manda y pasa al siguiente estado
							begin	
																
								next_state = Check_Send_All_Instr;
								enable_read_instr = 1'b1;
							end								      
						  					
					end				
				Check_Send_All_Instr:			//4		//Estado con el que verificamos si se termino el envio de instrucciones		
					begin					
						enable_read_instr = 1'b0;
						en_write_reg = 1'b1;	 //habilito la escritura en memoria del pipeline															
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
							end													

					end									
				Check_Operation: 					//16 //Case que elige el modo de operacion, STEP o CONTINUO
					begin						
						debug_unit_reg = 1'b0;
						en_read_mode_operate = 1'b0;
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
							end
					end								
				Send_program_counter:  		//256
					begin	
						if(end_send_pc)
						begin
							next_state = Send_cant_cyles;
							enable_send_pc = 1'b0;
						end	
						else
						begin					
							debug_unit_reg = 1'b0;
							next_state = Send_program_counter;	
							data_send = i_send_program_counter;
							enable_send_pc = 1'b1;																									
						end
					end					
				Send_cant_cyles:					//512	
					begin	
						if(end_send_cant_cycles)
						begin
							next_state = Send_one_reg;
							enable_send_cant_cycles = 1'b0;
						end	
						else
						begin	
							end_send_pc	= 1'b0;		
							debug_unit_reg = 1'b0;
							next_state = Send_cant_cyles;	
							data_send = i_cant_cycles;
							enable_send_cant_cycles = 1'b1;																									
						end
					end	
				Send_one_reg:
					if(end_send_one_reg)
					begin
						next_state = Check_send_all_regs;
						enable_send_one_reg = 1'b0;
					end	
					else
					begin
						data_send = i_reg_debug_unit[8*cont_byte+:8];	
						end_send_cant_cycles	= 1'b0;		
						debug_unit_reg = 1'b0;
						next_state = Send_one_reg;	
						enable_send_one_reg = 1'b1;																									
					end
				Check_send_all_regs:
					begin
						end_send_one_reg = 1'b0;
						if(o_addr_reg_debug_unit == 31)
						begin
							next_state = Waiting_operation;
						end
						else
						begin
							o_addr_reg_debug_unit = o_addr_reg_debug_unit + 1;
							next_state = Send_one_reg;
						end
					end

				default:
					next_state = Number_Instr;					
			endcase
		end

	UART2 uart2
        (
        .i_clock(i_clock),
        .i_reset(i_reset),
        .i_rx(i_rx_data), //wire para rx bit a bit
        .i_tx(data_send), //data to transfer
        .i_tx_start(tx_start), //start transfer
        .o_rx(data_uart_receive), //data complete recive
        .o_rx_done_tick(rx_done_uart), //rx done
        .o_tx(o_tx_data), //wire para tx bit a bit
        .o_tx_done_tick(tx_done_uart) //tx done
        );

du_recieve du_recieve
	(
		.i_clock(i_clock),
		.i_reset(i_reset),
		.i_enable(1),
		.i_rx_done_uart(rx_done_uart),
		.i_recieve_state(state[3:0]),
		.i_data_uart_receive(data_uart_receive),

	
		.o_number_instructions(number_instructions),
		.o_ready_number_instr(ready_number_instr),
		.o_instruction(o_inst_load),
		.o_ready_full_inst(ready_full_inst),
		.o_addr_instruction(addr_instruction),
		.o_ready_all_instr_send(all_instr_send),
		.o_mode_operate(operation_mode),
		.o_ready_mode_operate(ready_mode_operate)
	);


endmodule