`timescale 1ns / 1ps

module WRITE_BACK_tb;

  // Parameters
  localparam  NB_DATA = 32;
  localparam  NB_REG  = 5;
  localparam  NB_PC   = 32;

  // Ports
  reg                 i_WB_reg_write = 0;
  reg                 i_WB_mem_to_reg = 0;
  reg [NB_DATA-1:0]   i_WB_mem_data;
  reg [NB_DATA-1:0]   i_WB_alu_result;
  reg [NB_REG-1:0]    i_WB_selected_reg;
  reg                 i_WB_last_register_ctrl;
  reg [NB_PC-1:0]     i_pc;

  wire                o_WB_reg_write;
  wire [NB_DATA-1:0]  o_WB_selected_data;
  wire [NB_REG-1:0]   o_WB_selected_reg;

  WRITE_BACK 
  #(
    .NB_DATA(NB_DATA),
    .NB_REG(NB_REG),
    .NB_PC(NB_PC)
  )
  WRITE_BACK(
    .i_WB_reg_write(i_WB_reg_write),
    .i_WB_mem_to_reg(i_WB_mem_to_reg),
    .i_WB_mem_data(i_WB_mem_data),
    .i_WB_alu_result(i_WB_alu_result),
    .i_WB_selected_reg(i_WB_selected_reg),
    .o_WB_reg_write(o_WB_reg_write),
    .o_WB_selected_data(o_WB_selected_data),
    .o_WB_selected_reg ( o_WB_selected_reg)
  );

  initial begin
    i_clock = 0;
    i_WB_reg_write  = 1'b0;
    i_WB_mem_to_reg = 1'b0;
    i_WB_last_register_ctrl   = 1'b0;
    i_WB_pc         = 32'b0;

    #40
    $display("Testing MUX. Eleccion B alu");
    i_WB_mem_data = 32'haa;
    i_WB_alu_result = 32'hbb;
    $display("[display] time=%t -> i_MEM_mem_data=%h, i_MEM_alu_result=%h, o_WB_selected_data=%h", $time, i_MEM_mem_data, i_MEM_alu_result, o_WB_selected_data);
    $strobe("[strobe] time=%t -> i_MEM_mem_data=%h, i_MEM_alu_result=%h, o_WB_selected_data=%h", $time, i_MEM_mem_data, i_MEM_alu_result, o_WB_selected_data);

    #40
    $display("Testing MUX. Eleccion A mem_data");
    i_WB_mem_to_reg = 1'b1;
    
    $display("[display] time=%t -> i_MEM_mem_data=%h, i_MEM_alu_result=%h, o_WB_selected_data=%h", $time, i_MEM_mem_data, i_MEM_alu_result, o_WB_selected_data);
    $strobe("[strobe] time=%t -> i_MEM_mem_data=%h, i_MEM_alu_result=%h, o_WB_selected_data=%h", $time, i_MEM_mem_data, i_MEM_alu_result, o_WB_selected_data);


    $finish;
  end

  always #10 clock = ~clock;


endmodule
