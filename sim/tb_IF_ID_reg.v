`timescale 1ns / 1ps

module IF_ID_reg_tb;

  // Parameters
  localparam  NB_PC = 32;
  localparam  NB_INSTRUCTION = 32;

  // Ports
  reg i_clock = 0;
  reg [NB_PC-1:0] i_IF_adder_result;
  reg [NB_INSTRUCTION-1:0] i_IF_instruction;
  wire [NB_PC-1:0] o_ID_adder_result;
  wire [NB_INSTRUCTION-1:0] o_ID_instruction;

  IF_ID_reg 
  #(
    .NB_PC(NB_PC ),
    .NB_INSTRUCTION (
        NB_INSTRUCTION )
  )
  IF_ID_reg (
    .i_clock (i_clock ),
    .i_IF_adder_result (i_IF_adder_result ),
    .i_IF_instruction (i_IF_instruction ),
    .o_ID_adder_result (o_ID_adder_result ),
    .o_ID_instruction  ( o_ID_instruction)
  );

  initial begin
    begin
      $finish;
    end
  end

  always
    #5  i_clock = ! i_clock ;

endmodule
