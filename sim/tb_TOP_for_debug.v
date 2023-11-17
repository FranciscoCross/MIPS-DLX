`timescale 1ns / 1ps

module tb_TOP_for_debug;

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
  reg               i_clock_reset = 1'b1;
  reg               i_reset       = 1'b1;
  reg               i_rx_done     = 1'b0;
  reg               i_tx_done     = 1'b0;
  reg [BYTE-1:0]    i_rx_data     = 8'b0;

  wire o_halt;
  wire [NB_ST-1:0]  o_state;
  wire [BYTE-1:0]   o_tx_data;
  wire              o_tx_start;
  
  integer i;
  integer s;
  integer inst_counter;

  TOP_for_debug #(.BYTE(BYTE),
        .DWORD(DWORD),
        .ADDR(ADDR),
        .RB_ADDR(RB_ADDR))
  TOP(.i_clock(i_clock),
          .i_reset(i_reset),
          .i_rx_done(i_rx_done),
          .i_tx_done(i_tx_done),
          .i_rx_data(i_rx_data),
          .i_clock_reset(i_clock_reset),
          .o_halt(o_halt),
          .o_state(o_state),
          .o_tx_data(o_tx_data),
          .o_tx_start(o_tx_start)); 


  initial begin
    inst_counter    = 0;
  
    i_clock         = 1'b0;
    i_reset         = 1'b1;
    i_clock_reset   = 1'b1;
    i_rx_data       = 8'd0;
    i_rx_done       = 1'b0;

    #100
    i_clock_reset   = 1'b0;

    #650
    i_reset         = 1'b0;
    
	// Se envia cmd para escribir Instruction Mem
    #405
    i_rx_data       = 8'd1; // Escribir IM
    i_rx_done       = 1'b1;

    #20
    i_rx_done       = 1'b0;
    $readmemb("C:/Users/chito/OneDrive/Escritorio/MIPS-DLX/GUI/programs/compiled.txt", memory, 0, 255);
	//Se envian todas las instrucciones
    for (i=0; i<256; i=i+1) begin
        #200
        $display("instructions : ",inst_counter);
        inst_counter = inst_counter+1;
    	$display("valor: ", memory[i]);
		#20
		i_rx_data	= memory[i];
		i_rx_done	= 1'b1;

		#20
		i_rx_done	= 1'b0;
    end
//--------------- CONTINUA --------------------
    #1000
    $display("Ejecucion continua", $time);
    i_rx_data = 8'd2; // Ejecuion continua
    i_rx_done = 1'b1;

    #20
    i_rx_done = 1'b0;
    $finish;
  end

  always
    #5  i_clock = ! i_clock ;

endmodule
