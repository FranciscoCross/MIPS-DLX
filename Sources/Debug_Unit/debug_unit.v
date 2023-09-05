`timescale 1ns / 1ps
`include "parameters.vh"

`define mode_step_to_step 	8'b00000100 //4
`define mode_continue 			8'b00010000 //16

module debug_unit
	#(
		parameter CLOCK      = 50E6,
		parameter BAUD_RATE  = 19200,
		parameter NB_DATA    = 32,
		parameter NB_REG     = 5,
		parameter N_BITS     = 8,
		parameter N_BYTES    = 4,		
		parameter NB_STATE   = 14,
		parameter N_COUNT	 	 = 10			
	)
	(
		input wire i_clock,
		input wire i_reset,
		input wire i_halt,	
		input wire i_rx_data,	
		input wire [`ADDRWIDTH-1:0] i_send_program_counter, //pc + 1
		input wire [`ADDRWIDTH-1:0] 	i_cant_cycles,
		input wire [NB_DATA-1:0] 	i_reg_debug_unit, //viene del banco de registros
		input wire i_bit_sucio,
		input wire [NB_DATA-1:0] 	i_mem_debug_unit,

		output wire [NB_REG-1:0] 	o_addr_reg_debug_unit,// direccion a leer del registro para enviar a pc

		output wire [`ADDRWIDTH-1:0] o_addr_mem_debug_unit, //direccion a leer en memoria
		output wire o_ctrl_addr_debug_mem,
		output wire o_ctrl_wr_debug_mem,
		output wire o_ctrl_read_debug_reg,
		output wire o_tx_data,
		output wire o_en_write, //habilitamos la escritura en memoria, sabiendo que el dato ya esta completo formando los 32 bits de la instruccion
		output wire o_en_read,		
		output wire o_enable_pipe,
		output wire o_enable_mem,
		
		output wire o_debug_unit_reg,				
		output wire [NB_DATA-1:0] 		o_inst_load, //instruccion a cargar en memoria
		output wire [`ADDRWIDTH-1:0] 	o_address, //direccion donde se carga la instruccion
		output wire o_read_du,

		/* para DEBUG */
		output wire [NB_STATE-1:0] o_state
	);
	localparam 	[NB_STATE-1:0]  Number_Instr        	=  14'b00000000000001;//1
	localparam 	[NB_STATE-1:0]	Receive_One_Instr     	=  14'b00000000000010;//2
	localparam 	[NB_STATE-1:0]	Check_Send_All_Instr	=  14'b00000000000100;//4
	localparam 	[NB_STATE-1:0]	Waiting_operation  		=  14'b00000000001000;//8
	localparam 	[NB_STATE-1:0]	Check_Operation    		=  14'b00000000010000;//16 To choose between step or continuous mode
	localparam 	[NB_STATE-1:0]	Step_to_step       		=  14'b00000000100000;//32 
	localparam 	[NB_STATE-1:0]	Wait_One_Cicle     		=  14'b00000001000000;//64 
	localparam 	[NB_STATE-1:0]	Continue_to_Halt  		=  14'b00000010000000;//128 For continuous mode
	localparam 	[NB_STATE-1:0]	Send_program_counter  	=  14'b00000100000000;//256 
	localparam 	[NB_STATE-1:0]	Send_cant_cyles 		=  14'b00001000000000;//512
	localparam 	[NB_STATE-1:0]	Send_one_reg			=  14'b00010000000000;//1024
	localparam 	[NB_STATE-1:0]	Check_send_all_regs		=  14'b00100000000000;//2048  
	localparam 	[NB_STATE-1:0]	Check_bit_sucio			=  14'b01000000000000;//4096
	localparam 	[NB_STATE-1:0]	Send_addr_mem			=  14'b10000000000000;//8192
	localparam 	[NB_STATE-1:0]	Send_data_mem			=  14'b00000001111111;//127
	localparam 	[NB_STATE-1:0]	Check_send_all_mems		=  14'b11111111111111;//32767
	
	wire ready_full_inst, ready_number_instr, all_instr_send, ready_mode_operate;
	wire [N_BITS-1:0] operation_mode;
	wire [N_BITS-1:0] number_instructions;
	wire [`ADDRWIDTH-1:0] addr_instruction;

	wire [N_BITS-1:0] data_uart_receive;
	reg en_read_reg, en_write_reg;

	/* Finish send-data*/
	reg end_send_pc, enable_send_pc;
	reg end_send_cant_cycles, enable_send_cant_cycles;
	reg end_send_one_reg, enable_send_one_reg;
	reg end_send_addr_mem, enable_send_addr_mem;
	reg end_send_mem, enable_send_mem;
	reg tx_busy;

	/******************/
	
	reg [NB_STATE-1:0] state, next_state;
	reg  debug_unit_reg, enable_pipe_reg;	
	reg [2:0] cont_byte;
	reg tx_start;
	reg [N_BITS-1:0] data_send;   
		

	


	wire tx_done_uart;
	wire rx_done_uart;
	reg [`ADDRWIDTH-1:0] 	addr_reg_debug_unit;
	reg [`ADDRWIDTH-1:0]    addr_mem_debug_unit;
	reg read_du;
	reg enable_mem;
	reg ctrl_read_debug_reg;
	reg ctrl_wr_debug_mem;
	reg ctrl_addr_debug_mem;

always @(negedge i_clock) 
begin
  	state = next_state;
	
  	if (i_reset) 
		begin
			// Asignaciones durante el reset
			end_send_mem 				= 1'b0;
			end_send_cant_cycles 		= 1'b0;
			cont_byte 					= {N_BITS{1'b0}};
			end_send_pc 				= 1'b0;
			end_send_addr_mem 			= 1'b0;
			end_send_one_reg  			= 1'b0;
			tx_start 					= 1'b0;
			tx_busy 					= 1'b0;
		end 
	else
	begin
		if(enable_send_pc || enable_send_cant_cycles || enable_send_one_reg || enable_send_addr_mem || enable_send_mem)
		begin
			if(tx_busy == 0)
			begin
				tx_start 	= 1'b1;
				tx_busy 	= 1'b1;
			end
			else 
			begin
				tx_start = 1'b0;
			end
		end
		if(tx_done_uart)
		begin
			tx_busy = 1'b0;
		  	if(enable_send_pc)
		  		end_send_pc = 1'b1;
			if(enable_send_cant_cycles)
		  		end_send_cant_cycles = 1'b1;
			if(enable_send_one_reg)
			begin
				cont_byte = cont_byte + 1;
				if (cont_byte > N_BYTES-1)
				begin
					end_send_one_reg  = 1'b1;
					cont_byte = 3'b0;
				end
						
			end
			if(enable_send_addr_mem)
				end_send_addr_mem = 1'b1;
			if(enable_send_mem)
			begin
				cont_byte = cont_byte + 1;
				if (cont_byte > N_BYTES-1)
				begin
					end_send_mem  = 1'b1;
					cont_byte = 3'b0;
				end
			end
		end
	end
end		

  /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

	always @(posedge i_clock) //logica de cambio de estado
		begin
		next_state 					= state;
		en_read_reg					= 1'b0;
		enable_mem 					= 1'b0;			
		debug_unit_reg 				= 1'b1; 
		ctrl_read_debug_reg 		= 1'b0;
		//ctrl_addr_debug_mem 		= 1'b0;
		ctrl_wr_debug_mem 			= 1'b0;	
		if (i_reset) 
		begin
			// Asignaciones durante el reset
			enable_send_cant_cycles		= 1'b0;
			enable_send_one_reg			= 1'b0;
			enable_send_addr_mem		= 1'b0;
			enable_send_mem				= 1'b0;
			enable_mem					= 1'b0;
			ctrl_read_debug_reg			= 1'b0;
			ctrl_wr_debug_mem			= 1'b0;
			ctrl_addr_debug_mem			= 1'b0;
			addr_reg_debug_unit 		= {NB_REG{1'b0}};
			addr_mem_debug_unit			= {`ADDRWIDTH{1'b0}};
			data_send 					= {N_BITS{1'b0}};
			enable_send_pc 				= 1'b0;
			state 						= Number_Instr;
			next_state 					= Number_Instr;
			enable_pipe_reg 			= 1'b0;
			read_du 					= 1'b0;
			en_read_reg					= 1'b0;
			en_write_reg				= 1'b0;
		end
		else
		begin	    
			case (state)
				Number_Instr: 						//1
					begin
						next_state  = Number_Instr;	
						if (ready_number_instr)
						begin								
							next_state  = Receive_One_Instr;
						end
						else
						begin
							next_state  = next_state;
						end								    						      					
					end	
				Receive_One_Instr: 				//2
					begin
						en_write_reg = 1'b0;
						if (ready_full_inst) //Cuando esta lista la instruccion, la manda y pasa al siguiente estado
						begin									
							next_state = Check_Send_All_Instr;
						end	
						else
							next_state  = Receive_One_Instr;
					end				
				Check_Send_All_Instr:			//4		//Estado con el que verificamos si se termino el envio de instrucciones		
					begin					
						en_write_reg = 1'b1;	 //habilito la escritura en memoria de instrucciones del pipeline															
						if (all_instr_send)
						begin	
							next_state  = Waiting_operation;
															
						end
						else
							next_state  = Receive_One_Instr;	
					end	
				Waiting_operation: 				//8	
					begin
						en_write_reg = 1'b0;	
						debug_unit_reg = 1'b0;						
						if (ready_mode_operate)
						begin								
							next_state = Check_Operation;
						end	
						else
							next_state  = Waiting_operation;
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
						enable_mem = 1'b1;	
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
						end
						else
							enable_pipe_reg = enable_pipe_reg;

					end				
				Continue_to_Halt:					//128	
					begin						
						en_read_reg = 1'b1;
						enable_pipe_reg = 1'b1;
						enable_mem = 1'b1;						
						next_state = Continue_to_Halt;
						debug_unit_reg = 1'b0;
						en_write_reg = 1'b0;						
						
						if (i_halt)
						begin
							//$display("salto halt");	
							enable_pipe_reg = 1'b0;
							next_state = Send_program_counter;
						end
						else
						begin
							enable_pipe_reg = enable_pipe_reg;
							next_state = Continue_to_Halt;
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
					begin
					    read_du  = 1'b1;
						ctrl_read_debug_reg = 1'b1;
						if(end_send_one_reg)
						begin
							next_state = Check_send_all_regs;
							addr_reg_debug_unit = addr_reg_debug_unit + 1;
							enable_send_one_reg = 1'b0;
						end	
						else
						begin
							data_send = i_reg_debug_unit[8*cont_byte+:8];	
							end_send_cant_cycles	= 1'b0;		
							next_state = Send_one_reg;	
							enable_send_one_reg = 1'b1;																									
						end
					end
				Check_send_all_regs:
					begin
						end_send_one_reg = 1'b0;
						if(addr_reg_debug_unit == 32)
						begin
							ctrl_read_debug_reg = 1'b1;
							next_state = Check_bit_sucio;
						end
						else
						begin
							next_state = Send_one_reg;
						end
					end
				Check_bit_sucio: //4096
					begin
						enable_mem = 1'b1;
						ctrl_wr_debug_mem  = 1'b1;
						ctrl_addr_debug_mem = 1'b1;
						if(i_bit_sucio)
						begin
							next_state = Send_addr_mem;
						end
						else
						begin
							addr_mem_debug_unit = addr_mem_debug_unit + 1;
							next_state = Check_send_all_mems;
						end
					end
				Send_addr_mem: //8192
					begin	
						enable_mem = 1'b1;
						ctrl_wr_debug_mem  = 1'b1;
						ctrl_addr_debug_mem = 1'b1;
						if(end_send_addr_mem)
						begin
							next_state = Send_data_mem;
							enable_send_addr_mem = 1'b0;
						end	
						else
						begin					
							next_state = Send_addr_mem;	
							data_send = addr_mem_debug_unit;
							enable_send_addr_mem = 1'b1;																									
						end
					end	
				Send_data_mem://127
					begin
						enable_mem = 1'b1;
						ctrl_wr_debug_mem  = 1'b1;
						ctrl_addr_debug_mem = 1'b1;
						if(end_send_mem)
						begin
							addr_mem_debug_unit = addr_mem_debug_unit + 1;
							next_state = Check_send_all_mems;
							enable_send_mem = 1'b0;
						end	
						else
						begin
							data_send = i_mem_debug_unit[8*cont_byte+:8];	
							end_send_addr_mem	= 1'b0;		
							next_state = Send_data_mem;	
							enable_send_mem = 1'b1;																									
						end
					end
				Check_send_all_mems: //32528
					begin
						end_send_mem = 1'b0;
						ctrl_wr_debug_mem  = 1'b1;
						ctrl_addr_debug_mem = 1'b1;
						if(addr_mem_debug_unit == 7'b0)
						begin
							enable_mem = 1'b0;
							ctrl_wr_debug_mem  = 1'b0;
							ctrl_addr_debug_mem = 1'b0;
							next_state = Waiting_operation;
						end
						else
						begin
							enable_mem = 1'b1;
							ctrl_wr_debug_mem  = 1'b1;
							ctrl_addr_debug_mem = 1'b1;
							next_state = Check_bit_sucio;
						end
					end
				default:
					next_state = Number_Instr;					
			endcase
		end
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

assign o_addr_reg_debug_unit 	= addr_reg_debug_unit;
assign o_addr_mem_debug_unit 	= addr_mem_debug_unit;
assign o_ctrl_addr_debug_mem 	= ctrl_addr_debug_mem;
assign o_ctrl_wr_debug_mem 		= ctrl_wr_debug_mem;
assign o_ctrl_read_debug_reg 	= ctrl_read_debug_reg;
assign o_en_write 				= en_write_reg;
assign o_en_read 				= en_read_reg;	
assign o_enable_pipe 			= enable_pipe_reg;
assign o_enable_mem 			= enable_mem;
assign o_debug_unit_reg 		= debug_unit_reg;				
assign o_address 				= addr_instruction-1;
assign o_read_du 				= read_du;
assign o_state 					= state;



endmodule