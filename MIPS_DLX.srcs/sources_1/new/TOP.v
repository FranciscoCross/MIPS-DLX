`include "parameters.vh"

module TOP
	#(	
		parameter CLOCK         = 50E6,
		parameter NB_OPCODE     = 6,
		parameter BAUD_RATE     = 203400,
		parameter NB_STATE      = 12,		
		parameter NB_DATA       = 32,	
		parameter NB_REG        = 5,
		parameter N_BITS        = 8,
		parameter NB_EX_CTRL    = 7,
		parameter NB_MEM_CTRL   = 6,
		parameter NB_WB_CTRL    = 3				
	)
	(
		input wire i_clock,
		input wire i_reset,
		input wire i_reset_wz,
		input wire i_rx_data,

		output wire tx_data_o,
		output wire locked_o,	
		output wire ack_debug_o,
		output wire end_send_data_o
	);


	wire [NB_DATA-1:0] wire_inst_load;
	wire [`ADDRWIDTH-1:0] wire_addr_load_inst; // instruccion a cargar y su direccion

	wire wire_en_write, wire_en_read, wire_debug_unit;	
    wire clock_w, locked_wz;
	wire wire_halt, wire_enable_pipe;
	wire wire_enable_mem;

	wire [`ADDRWIDTH-1:0] wire_send_program_counter;
	wire [NB_DATA-1:0] wire_reg_debug_unit;
	wire [N_BITS-1:0] wire_cant_cycles;
	wire [NB_REG-1:0] wire_addr_reg_debug_unit; //direccion a registro a leer
	wire wire_bit_sucio;
	wire wire_ctrl_addr_debug_mem;
	wire wire_ctrl_wr_debug_mem;
	wire [`ADDRWIDTH:0] wire_addr_mem_debug_unit;
	wire [NB_DATA-1:0] wire_mem_debug_unit;
	wire wire_ctrl_read_debug_reg;

	
	assign locked_o = locked_wz;
	assign halt_o = wire_halt;

	clock_wz clock_wz
  	(  
		.clk_out1(clock_w),
	  	.reset(i_reset_wz), 
	  	.locked(locked_wz),
	  	.clk_in1(i_clock)
	 );


    pipeline pipeline
	(
		.clock(clock_w),
		.i_reset(i_reset),
		.i_inst_load(wire_inst_load),
		.i_addr_inst_load(wire_addr_load_inst),		
		.i_en_write(wire_en_write),
		.i_en_read(wire_en_read),
		.i_enable_mem(wire_enable_mem),
		.i_enable_pipe(wire_enable_pipe),
		.i_debug_unit(wire_debug_unit),
		.i_addr_debug_unit(wire_addr_reg_debug_unit), //addr de registro debug
		.i_addr_mem_debug_unit(wire_addr_mem_debug_unit),
		.i_ctrl_read_debug_reg(wire_ctrl_read_debug_reg),
		.i_ctrl_wr_debug_mem(wire_ctrl_wr_debug_mem), //leyendo para debug mem
		.i_ctrl_addr_debug_mem(wire_ctrl_addr_debug_mem), 
		.o_bit_sucio(wire_bit_sucio),
		.o_data_send_pc(wire_send_program_counter),
		.o_data_reg_debug_unit(wire_reg_debug_unit),
		.o_data_mem_debug_unit(wire_mem_debug_unit),
		.o_count_cycles(wire_cant_cycles),
		.o_halt(wire_halt)
	);

	
    debug_unit#(.CLOCK(CLOCK), .BAUD_RATE(BAUD_RATE)) debug_unit
	(
		.i_clock(clock_w),
		.i_reset(i_reset),
		.i_halt(wire_halt),	
		.i_rx_data(i_rx_data),	
		.i_send_program_counter(wire_send_program_counter), //pc + 1
		.i_cant_cycles(wire_cant_cycles),
		.i_reg_debug_unit(wire_reg_debug_unit), //viene del banco de registros
		.i_bit_sucio(wire_bit_sucio),
		.i_mem_debug_unit(wire_mem_debug_unit),
		
        .o_addr_reg_debug_unit(wire_addr_reg_debug_unit),// direccion a leer del registro para enviar a pc
        .o_addr_mem_debug_unit(wire_addr_mem_debug_unit), //direccion a leer en memoria
		.o_ctrl_addr_debug_mem(wire_ctrl_addr_debug_mem),
		.o_ctrl_wr_debug_mem(wire_ctrl_wr_debug_mem),
		.o_ctrl_read_debug_reg(wire_ctrl_read_debug_reg),
		.o_tx_data(tx_data_o),
		.o_en_write(wire_en_write), //habilitamos la escritura en memoria, sabiendo que el dato ya esta completo formando los 32 bits de la instruccion
		.o_en_read(wire_en_read),		
		.o_enable_pipe(wire_enable_pipe),
		.o_enable_mem(wire_enable_mem),
		.o_debug_unit_reg(wire_debug_unit),				
		.o_inst_load(wire_inst_load), //instruccion a cargar en memoria
		.o_address(wire_addr_load_inst), //direccion donde se carga la instruccion
		.o_ack_debug(ack_debug_o), //avisa al test que ya puede enviar el comando
		.o_end_send_data(end_send_data_o) //avisa al test que ya se termino de enviar datos de memoria
	);
endmodule