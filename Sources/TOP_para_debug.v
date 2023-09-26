`include "parameters.vh"

module TOP_para_debug
	#(	
		parameter CLOCK         = 50E6,
		parameter NB_OPCODE     = 6,
		parameter BAUD_RATE     = 19200,
		parameter NB_STATE      = 10,		
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
		input wire [N_BITS-1:0] i_rx_data,
		input wire i_rx_done_tick,
		input wire i_tx_done_tick,

		output wire o_halt,
		output wire o_locked,
		output wire o_tx_start,
		output wire [N_BITS-1:0] o_tx_data,
		output wire [NB_STATE-1:0] o_state
	);



	wire [`ADDRWIDTH-1:0] wire_im_addr, wire_br_addr, wire_dm_addr, wire_pc_value;
	wire [ NB_DATA-1:0] wire_im_data_write, wire_br_data, wire_dm_data;
	wire wire_im_write_enable, wire_dm_enable, wire_enable_pipe, wire_du_select_addr, wire_halt;
    wire clock_w;
	
	clock_wz clock_wz
  	(  
		.clk_out1(clock_w),
	  	.reset(i_reset_wz),
	  	.locked(o_locked),
	  	.clk_in1(i_clock)
	 );

    pipeline pipeline
	(
		.clock(clock_w),
		.i_reset(i_reset),
		.i_im_data(wire_im_data_write),
		.i_im_addr(wire_im_addr),		
		.i_im_enable_write(wire_im_write_enable),
		.i_en_read(1'b1),
		.i_enable_mem(wire_dm_enable),
		.i_enable_pipe(wire_enable_pipe),
		.i_dm_enable_read(wire_dm_enable),
		.i_debug_unit(wire_du_select_addr),
		.i_br_addr(wire_br_addr), 
		.i_dm_addr(wire_dm_addr),
		.i_br_enable(1'b1),
		.i_dm_enable(wire_dm_enable), //leyendo para debug mem
		.i_dm_enable_addr(wire_dm_enable), 
		.o_data_send_pc(wire_pc_value),
		.o_data_reg_debug_unit(wire_br_data),
		.o_data_mem_debug_unit(wire_dm_data),
		.o_halt(o_halt)
	);

	debug_unit2 debug_unit2
    (
        .i_clock(clock_w),
        .i_reset(i_reset),
        .i_halt(o_halt),          
        .i_rx_done(i_rx_done_tick),      
        .i_tx_done(i_tx_done_tick),      
        .i_rx_data(i_rx_data),     
        .i_pc_value(wire_pc_value),     
        .i_dm_data(wire_dm_data),      
        .i_br_data(wire_br_data),      
        .o_im_write_enable(wire_im_write_enable), 
        .o_im_data_write(wire_im_data_write),
        .o_im_addr(wire_im_addr),      
        .o_tx_data(o_tx_data),      
        .o_tx_start(o_tx_start),     
        .o_br_addr(wire_br_addr),      
        .o_br_read(wire_br_read),  
        .o_dm_addr(wire_dm_addr),      
        .o_dm_enable(wire_dm_enable), 
        .o_dm_read_enable(wire_dm_read_enable), 
        .o_state(o_state),
        .o_enable_pipe(wire_enable_pipe),
        .o_debug_unit_load(wire_du_select_addr)
    );

endmodule