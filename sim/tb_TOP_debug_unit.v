module tb_TOP_debug_unit;

  // Parameters
  localparam  BYTE = 8;
  localparam  ADDR = 5;

  // Ports
  reg               i_clock;
  reg               i_reset;
  reg [BYTE-1:0]    command;
  reg               send = 0;

  TOP_debug_unit #( .BYTE(BYTE),
                    .ADDR(ADDR))
  TOP_debug_unit (.i_clock(i_clock),
                      .i_reset(i_reset),
                      .command(command),
                      .send (send));

  initial begin
    i_clock = 1'b0;
    i_reset = 1'b1;
    command = 8'd0;
    send    = 1'b0;

    #100
    i_reset = 1'b0;
    command = 8'd4;
    send    = 1'b1;

    #20
    send    = 1'b0;

//    #1200000
//    command = 8'd6;
//    send    = 1'b1;

//    #20
//    send    = 1'b0;

//    #1200000
//    command = 8'd6;
//    send    = 1'b1;

//    #20
//    send    = 1'b0;

//    #1200000
//    command = 8'd7;
//    send    = 1'b1;
    
    #500000000
    
    $finish;
  end

  always
    #10  i_clock = ! i_clock ;

endmodule
