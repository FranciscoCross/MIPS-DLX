`timescale 1ns / 1ps

module tb_MEM_stage;

  // Parameters
  localparam  NB_ADDR = 32;
  localparam  NB_DATA = 32;
  localparam  NB_PC = 32;
  localparam  NB_REG = 5;

  // Ports
  reg                 i_clock;
  reg                 i_MEM_reg_write;
  reg                 i_MEM_mem_to_reg;
  reg                 i_MEM_mem_read;
  reg                 i_MEM_mem_write;
  reg                 i_MEM_word_enable;
  reg                 i_MEM_halfword_enable;
  reg                 i_MEM_byte_enable;
  reg                 i_MEM_branch;
  reg                 i_MEM_zero;
  reg  [NB_PC-1:0]    i_MEM_branch_addr;
  reg  [NB_ADDR-1:0]  i_MEM_alu_result;
  reg  [NB_DATA-1:0]  i_MEM_write_data;
  reg  [NB_REG-1:0]   i_MEM_selected_reg;
  reg                 i_MEM_last_register_ctrl;
  reg  [NB_PC-1:0]    i_MEM_pc;
  
  wire [NB_DATA-1:0]  o_MEM_mem_data;
  wire [NB_REG-1:0]   o_MEM_selected_reg;
  wire [NB_ADDR-1:0]  o_MEM_alu_result;
  wire [NB_PC-1:0]    o_MEM_branch_addr;
  wire                o_MEM_branch_zero;
  wire                o_MEM_reg_write;
  wire                o_MEM_mem_to_reg;
  wire                o_MEM_last_register_ctrl;
  wire [NB_PC-1:0]    o_MEM_pc; 

  MEMORY 
  #(
    .NB_ADDR(NB_ADDR),
    .NB_DATA(NB_DATA),
    .NB_PC(NB_PC),
    .NB_REG(NB_REG)
  )
  MEM_stage_1 (
    .i_clock(i_clock),
    .i_MEM_reg_write(i_MEM_reg_write),
    .i_MEM_mem_to_reg(i_MEM_mem_to_reg),
    .i_MEM_mem_read(i_MEM_mem_read),
    .i_MEM_mem_write(i_MEM_mem_write),
    .i_MEM_word_enable(i_MEM_word_enable),
    .i_MEM_halfword_enable(i_MEM_halfword_enable),
    .i_MEM_byte_enable(i_MEM_byte_enable),
    .i_MEM_branch(i_MEM_branch),
    .i_MEM_zero(i_MEM_zero),
    .i_MEM_branch_addr(i_MEM_branch_addr),
    .i_MEM_alu_result(i_MEM_alu_result),
    .i_MEM_write_data(i_MEM_write_data),
    .i_MEM_selected_reg(i_MEM_selected_reg),
    .i_MEM_last_register_ctrl(i_MEM_last_register_ctrl),
    .i_MEM_pc(i_MEM_pc),
    .o_MEM_mem_data(o_MEM_mem_data),
    .o_MEM_selected_reg(o_MEM_selected_reg),
    .o_MEM_alu_result(o_MEM_alu_result),
    .o_MEM_branch_addr(o_MEM_branch_addr),
    .o_MEM_branch_zero(o_MEM_branch_zero),
    .o_MEM_reg_write(o_MEM_reg_write),
    .o_MEM_mem_to_reg(o_MEM_mem_to_reg),
    .o_MEM_last_register_ctrl(o_MEM_last_register_ctrl),
    .o_MEM_pc(o_MEM_pc)
  );

  initial begin
    i_clock = 0;
    i_MEM_reg_write     = 0;
    i_MEM_mem_to_reg    = 0;
    i_MEM_mem_read      = 0;
    i_MEM_mem_write     = 0;
    i_MEM_word_enable       = 0;
    i_MEM_halfword_enable   = 0;
    i_MEM_byte_enable       = 0;
    i_MEM_branch        = 0;
    i_MEM_zero          = 0;
    i_MEM_branch_addr   = 32'd0;
    i_MEM_alu_result    = 32'd0;
    i_MEM_write_data    = 32'd0;
    i_MEM_selected_reg  = 5'd0;
    i_MEM_last_register_ctrl      = 1'b0;
    i_MEM_pc      = 32'b0;
    
    #20
    
    i_MEM_mem_write     = 1;
    
    i_MEM_byte_enable       = 1;
    i_MEM_alu_result    = 32'd10;
    i_MEM_write_data    = 32'd14;
    
    #20
    
    i_MEM_byte_enable       = 0;
    i_MEM_word_enable       = 1;
    i_MEM_alu_result    = 32'd0;
    i_MEM_write_data    = 32'd257;
    
    #20
    i_MEM_mem_write     = 0;
    i_MEM_mem_read      = 1;
    
    i_MEM_word_enable       = 0;
    i_MEM_halfword_enable   = 1;
    i_MEM_alu_result    = 32'd3;
    
    #20
  
//    i_clock = 0;
//    i_MEM_reg_write = 1'b0;
//    i_MEM_mem_to_reg  = 1'b0;
//    i_mem_read_flag = 1'b0;
//    i_MEM_mem_write = 1'b0;
//    i_MEM_branch = 1'b0;
//    i_MEM_zero = 1'b0;
    
//    #40

//    #40
//    i_MEM_branch = 1'b0;
//    i_MEM_zero = 1'b1;
//    i_MEM_branch_addr = 32'hf;
//    $display("[$display]time=%0t ->  i_MEM_branch=%b, i_MEM_zero=%b, i_MEM_branch_addr=%b, o_MEM_branch_zero=%b, o_MEM_branch_addr=%b",
//                         $time, i_MEM_branch, i_MEM_zero, i_MEM_branch_addr, o_MEM_branch_zero, o_MEM_branch_addr);
//    $strobe("[$strobe]time=%0t ->  i_MEM_branch=%b, i_MEM_zero=%b, i_MEM_branch_addr=%b, o_MEM_branch_zero=%b, o_MEM_branch_addr=%b",
//                         $time, i_MEM_branch, i_MEM_zero, i_MEM_branch_addr, o_MEM_branch_zero, o_MEM_branch_addr);
//    #40
//    i_MEM_branch = 1'b1;
//    i_MEM_zero = 1'b1;
//    i_MEM_branch_addr = 32'hf;
//    $display("[$display]time=%0t ->  i_MEM_branch=%b, i_MEM_zero=%b, i_MEM_branch_addr=%b, o_MEM_branch_zero=%b, o_MEM_branch_addr=%b",
//                         $time, i_MEM_branch, i_MEM_zero, i_MEM_branch_addr, o_MEM_branch_zero, o_MEM_branch_addr);
//    $strobe("[$strobe]time=%0t ->  i_MEM_branch=%b, i_MEM_zero=%b, i_MEM_branch_addr=%b, o_MEM_branch_zero=%b, o_MEM_branch_addr=%b",
//                         $time, i_MEM_branch, i_MEM_zero, i_MEM_branch_addr, o_MEM_branch_zero, o_MEM_branch_addr);
//    #40
//    $display("Testing WRITING memory data");
//    i_MEM_alu_result = 32'h4; // addr 4
//    i_MEM_mem_write = 1'b1;   // flag de escritura
//    i_write_data = 32'hf0f0;  // Data que se escribe
    
//    $display("[$display]time=%0t -> i_MEM_alu_result=%b, i_MEM_mem_write=%b, i_write_data=%b, o_MEM_mem_data=%b, o_MEM_alu_result=%b",
//                         $time, i_MEM_alu_result, i_MEM_mem_write, i_write_data, o_MEM_mem_data, o_MEM_alu_result);
//    $strobe("[$strobe]time=%0t -> i_MEM_alu_result=%b, i_MEM_mem_write=%b, i_write_data=%b, o_MEM_mem_data=%b, o_MEM_alu_result=%b",
//                         $time, i_MEM_alu_result, i_MEM_mem_write, i_write_data, o_MEM_mem_data, o_MEM_alu_result);                     

//    #40
//    $display("Testing READING memory data");
//    i_MEM_alu_result = 32'h4; // addr 4
//    i_MEM_mem_write = 1'b0;
//    i_mem_read_flag = 1'b1; 
//    $display("[$display]time=%0t -> i_MEM_alu_result=%b, i_MEM_mem_write=%b, i_write_data=%b, o_MEM_mem_data=%b, o_MEM_alu_result=%b",
//                        $time, i_MEM_alu_result, i_MEM_mem_write, i_write_data, o_MEM_mem_data, o_MEM_alu_result);
//    $strobe("[$strobe]time=%0t -> i_MEM_alu_result=%b, i_MEM_mem_write=%b, i_write_data=%b, o_MEM_mem_data=%b, o_MEM_alu_result=%b",
//                      $time, i_MEM_alu_result, i_MEM_mem_write, i_write_data, o_MEM_mem_data, o_MEM_alu_result);                     
    
//    #40
//    i_MEM_selected_reg = 5'h4;
//    $display("Selected reg");
//    $display("[$display]time=%0t -> i_MEM_selected_reg=%b, o_MEM_selected_reg=%b", i_MEM_selected_reg, o_MEM_selected_reg);
//    $strobe("[$display]time=%0t -> i_MEM_selected_reg=%b, o_MEM_selected_reg=%b", i_MEM_selected_reg, o_MEM_selected_reg);

    $finish;
  end

  always #5 i_clock = ~i_clock;

endmodule
