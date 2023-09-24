`include "parameters.vh"

module TOP
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
		input wire i_rx,

		output wire o_tx,
		output wire o_locked,
		output wire [NB_STATE-1:0] o_state
	);


	wire [`ADDRWIDTH-1:0] wire_im_addr, wire_br_addr, wire_dm_addr, wire_pc_value;
	wire [ NB_DATA-1:0] wire_im_data_write, wire_br_data, wire_dm_data;
	wire [`ADDRWIDTH-1:0] wire_cant_cycles;
	wire [NB_REG-1:0] wire_addr_reg_debug_unit; //direccion a registro a leer
	wire wire_ctrl_addr_debug_mem, wire_im_write_enable, wire_dm_enable, wire_enable_pipe, wire_du_select_addr, wire_halt;
	wire [7:0] tx_data_to_send, aux_rx_data_pipe;
	wire aux_tx_done_pipe, aux_rx_done_pipe, tx_start_debug_unit; 
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
		.o_halt(wire_halt)
	);

	debug_unit2 debug_unit2
    (
        .i_clock(clock_w),
        .i_reset(i_reset),
        .i_halt(wire_halt),          
        .i_rx_done(aux_rx_done_pipe),      
        .i_tx_done(aux_tx_done_pipe),      
        .i_rx_data(aux_rx_data_pipe),     
        .i_pc_value(wire_pc_value),     
        .i_dm_data(wire_dm_data),      
        .i_br_data(wire_br_data),      
        .o_im_write_enable(wire_im_write_enable), 
        .o_im_data_write(wire_im_data_write),
        .o_im_addr(wire_im_addr),      
        .o_tx_data(tx_data_to_send),      
        .o_tx_start(tx_start_debug_unit),     
        .o_br_addr(wire_br_addr),      
        .o_br_read(wire_br_read),  
        .o_dm_addr(wire_dm_addr),      
        .o_dm_enable(wire_dm_enable), 
        .o_dm_read_enable(wire_dm_read_enable), 
        .o_state(o_state),
        .o_enable_pipe(wire_enable_pipe),
        .o_debug_unit_load(wire_du_select_addr)
    );

    UART2 uart_pipeline
    (
        .i_clock(clock_w),
        .i_reset(i_reset),
        .i_rx(i_rx),                   //wire para rx bit a bit
        .i_tx_data(tx_data_to_send),        //data to transfer
        .i_tx_start(tx_start_debug_unit),   //start transfer
        .o_rx_data(aux_rx_data_pipe),       //data complete recive
        .o_rx_done_tick(aux_rx_done_pipe),  //rx done
        .o_tx(o_tx),                   //wire para tx bit a bit
        .o_tx_done_tick(aux_tx_done_pipe)   //tx done
    );

endmodule