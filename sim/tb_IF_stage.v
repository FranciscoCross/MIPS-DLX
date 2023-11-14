`timescale 1ns / 1ps

module tb_IF;

  // Parameters
  localparam  NB_PC_CONSTANT = 3;
  localparam  NB_PC          = 32;
  localparam  NB_INSTRUCTION = 32;
  localparam  NB_MEM_WIDTH   = 8;


  // Ports
  reg i_clock;
  reg i_IF_branch;
  reg i_IF_j_jal;
  reg i_IF_jr_jalr;
  reg i_IF_pc_enable;
  reg i_IF_pc_reset;
  reg i_IF_read_enable;
  reg i_IF_write_enable;                      // DEBUG_UNIT control 
  reg [NB_MEM_WIDTH-1:0] i_IF_write_data;   // DEBUG_UNIT control 
  reg [NB_PC-1:0] i_IF_branch_addr;
  reg [NB_PC-1:0] i_IF_jump_addr;
  reg [NB_PC-1:0] i_IF_data_last_register;
  wire [NB_PC-1:0] o_IF_adder_result;
  wire [NB_INSTRUCTION-1:0] o_IF_instruction;

  FETCH 
  #(
    .NB_PC_CONSTANT(NB_PC_CONSTANT ),
    .NB_PC(NB_PC),
    .NB_INSTRUCTION(NB_INSTRUCTION )
  )
  FETCH (
    .i_clock (i_clock ),
    .i_IF_branch (i_IF_branch ),
    .i_IF_j_jal (i_IF_j_jal),
    .i_IF_jr_jalr(i_IF_jr_jalr),
    .i_IF_pc_enable (i_IF_pc_enable),
    .i_IF_pc_reset (i_IF_pc_reset ),
    .i_IF_read_enable (i_IF_read_enable ),
    .i_IF_write_enable(i_IF_write_enable),
    .i_IF_write_data(i_IF_write_data),
    .i_IF_branch_addr (i_IF_branch_addr ),
    .i_IF_jump_addr (i_IF_jump_addr ),
    .i_IF_data_last_register(i_IF_data_last_register),
    .o_IF_adder_result (o_IF_adder_result ),
    .o_IF_instruction  ( o_IF_instruction)
  );

  initial begin
    begin
      i_clock           = 0;
      i_IF_pc_reset     = 1'b1;
      i_IF_branch       = 1'b0;
      i_IF_j_jal        = 1'b0;
      i_IF_jr_jalr      = 1'b0;
      i_IF_write_enable = 1'b0;
      i_IF_write_data   = {NB_MEM_WIDTH{1'b0}}; // DEBUG UNIT
      i_IF_branch_addr  = 32'h4;
      i_IF_jump_addr = 32'h3;
      i_IF_data_last_register     = 32'h2;
      
      #40
      i_IF_read_enable = 1'b1;
      // PC + 1
      #40
      i_IF_pc_reset = 1'b0;
      i_IF_pc_enable = 1'b1;
      // branch addr
      #40
      i_IF_branch = 1'b1;
      
      // j/jal addr
      #40
      i_IF_j_jal = 1'b1;

      // jr/jalrl addr
      #40
      i_IF_jr_jalr = 1'b1;

      #1000

      $finish;
    end
  end

  always
    #5  i_clock = ! i_clock ;

endmodule
