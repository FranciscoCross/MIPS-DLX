`timescale 1ns / 1ps

module tb_program_counter;

  // Parameters
  localparam  NB = 32;

  // Ports
  reg i_enable = 0;
  reg i_clock = 0;
  reg i_reset = 0;
  reg [NB-1:0] i_mux_pc = 32'd0;;
  wire [NB-1:0] o_pc;

  program_counter 
  #(
    .NB (
        NB )
  )
  program_counter_1 (
    .i_enable (i_enable ),
    .i_clock (i_clock ),
    .i_reset (i_reset ),
    .i_mux_pc (i_mux_pc ),
    .o_pc  ( o_pc)
  );

  initial begin
    begin
      i_reset = 1'b1;

      #20

      i_reset = 1'b0;
      i_enable = 1'b1;

      #20

      i_mux_pc = 32'd1;

      #20

      i_mux_pc = 32'd10;
    
      $finish;
    end
  end

  always
    #5  i_clock = ! i_clock ;

endmodule
