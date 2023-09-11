`include "parameters.vh"

module TOP
	#(	
		parameter CLOCK         = 50E6,
		parameter BAUD_RATE     = 19200,	
		parameter N_BITS        = 8,		
	)
	(
		input wire i_clock,
		input wire i_reset,
		input wire i_reset_wz,
		input wire i_rx,
        input wire i_tx_start,
		output wire [N_BITS-1:0] i_tx_data,

		output wire o_tx,
		output wire o_locked,
        output wire o_rx_done,
        output wire o_tx_done,
		output wire [N_BITS-1:0] o_state
	);

	clock_wz clock_wz
  	(  
		.clk_out1(clock_w),
	  	.reset(i_reset_wz),
	  	.locked(o_locked),
	  	.clk_in1(i_clock)
	 );

    UART2 uart
    (
    .i_clock(clock_w),
    .i_reset(i_reset),
    .i_rx(i_rx), //wire para rx bit a bit
    .i_tx(i_tx_data), //data to transfer
    .i_tx_start(i_tx_start), //start transfer
    .o_rx(o_state), //data recibida
    .o_rx_done_tick(o_rx_done), //rx done
    .o_tx(o_tx), //wire para tx bit a bit
    .o_tx_done_tick(o_tx_done) //tx done
    );

endmodule