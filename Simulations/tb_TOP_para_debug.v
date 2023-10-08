`timescale 1ns / 1ps

module tb_TOP_para_debug;

  // Parameters
  localparam  BYTE    = 8;
  localparam  DWORD   = 32;
  localparam  ADDR    = 5;
  localparam  RB_ADDR = 5;
  localparam  NB_DATA = 8;
  localparam  NB_OP   = 6;
  localparam  NB_ST   = 10;

  reg [NB_DATA-1:0] memory [255:0]; 

  // Ports
  reg               i_clock       = 1'b0;
  reg               i_reset_wz = 1'b1;
  reg               i_reset       = 1'b1;
  reg               i_rx_done     = 1'b0;
  reg               i_tx_done     = 1'b0;
  reg [BYTE-1:0]    i_rx_data     = 8'b0;

  wire o_halt;
  wire [NB_ST-1:0]  o_state;
  wire [BYTE-1:0]   o_tx_data;
  wire              o_tx_start, o_locked;
  
  integer i;
  integer s;
  integer inst_counter;

    TOP_para_debug TOP_para_debug
	(
		.i_clock(i_clock),
		.i_reset(i_reset),
		.i_reset_wz(i_reset_wz),
		.i_rx_data(i_rx_data),
		.i_rx_done_tick(i_rx_done),
		.i_tx_done_tick(i_tx_done),

		.o_halt(o_halt),
		.o_locked(o_locked),
		.o_tx_start(o_tx_start),
		.o_tx_data(o_tx_data),
		.o_state(o_state)
	);

  initial begin
    inst_counter    = 0;
  
    i_clock         = 1'b0;
    i_reset         = 1'b1;
    i_reset_wz   = 1'b1;
    i_rx_data       = 8'd0;
    i_rx_done       = 1'b0;

    #100
    i_reset_wz   = 1'b0;

    #650
    i_reset         = 1'b0;
    
	  // Se envia cmd para escribir Instruction Mem
    #405
    i_rx_data       = 8'd1; // Escribir IM
    i_rx_done       = 1'b1;

    #10
    i_rx_done       = 1'b0;
    $monitor("[$monitor] time=%0t o_state=%b ", $time, o_state);
    $readmemb("C:/Users/chito/OneDrive/Escritorio/MIPS-DLX/Sources/CLI/instrucciones.txt", memory, 0, 255);
	  // Se envia instruccion por instruccion, byte por byte
    for (i=0; i<256; i=i+1) begin
        #200
        $display("instructions : ",inst_counter);
        inst_counter = inst_counter+1;
    	$display("valor: ", memory[i]);
		#10
		i_rx_data	= memory[i];
		i_rx_done	= 1'b1;

		#10
		i_rx_done	= 1'b0;
    end
//--------------- STEP BY STEP--------------------
    #1000
    $display("Ejecución step by step. time = %0t", $time);
    i_rx_data = 3;
    i_rx_done = 1'b1;

    #20
    i_rx_done = 1'b0;
    
    // for(s=0; s<12; s=s+1) begin
    //     #100000
    //     $display("Ejecución step  %d. time = %0t",s, $time);
    //     i_rx_data = 7;
    //     i_rx_done = 1'b1;
    
    //     #20
    //     i_rx_done = 1'b0;
    //     #1000
    //     for (i=0; i<260; i=i+1) begin
    //           #80
    //           i_tx_done	= 1'b1;
        
    //           #20
    //           i_tx_done	= 1'b0;
    //     end  
    //end
    #100000
    $finish;
  end

  always
    #5  i_clock = ! i_clock ;

endmodule
