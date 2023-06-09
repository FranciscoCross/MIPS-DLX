`timescale 1ns / 1ps

module tb_EXECUTE;

  parameter NB_DATA      = 32;
  parameter NB_REG       = 5;
  parameter NB_FUNCTION  = 6;
  parameter NB_ALU_OP    = 3;
  parameter NB_EX_CTRL   = 7;
  parameter NB_OP_ALU    = 4;

  reg [NB_FUNCTION-1:0] i_function;
  reg [NB_DATA-1:0] i_data_ra;
  reg [NB_DATA-1:0] i_data_rb;
  reg [NB_DATA-1:0] i_data_inm;
  reg [NB_REG-1:0] i_shamt;
  reg [NB_REG-1:0] i_rs;
  reg [NB_REG-1:0] i_rt;
  reg [NB_REG-1:0] i_rd;
  reg [NB_EX_CTRL-1:0] i_EX_control;
  reg [NB_REG-1:0] i_EX_MEM_write_reg;
  reg [NB_REG-1:0] i_MEM_WB_write_reg;
  reg i_EX_MEM_reg_write;
  reg i_MEM_WB_reg_write;
  reg [NB_DATA-1:0] i_EX_MEM_result_alu;
  reg [NB_DATA-1:0] i_MEM_WB_data;

  wire [NB_DATA-1:0] o_data_write_mem;
  wire [NB_REG-1:0] o_write_register;
  wire [NB_DATA-1:0] o_result_alu;

  integer i;

  EXECUTE #(
    .NB_DATA(NB_DATA),
    .NB_REG(NB_REG),
    .NB_FUNCTION(NB_FUNCTION),
    .NB_ALU_OP(NB_ALU_OP),
    .NB_EX_CTRL(NB_EX_CTRL),
    .NB_OP_ALU(NB_OP_ALU)
  ) EXECUTE (
    .i_function(i_function),
    .i_data_ra(i_data_ra),
    .i_data_rb(i_data_rb),
    .i_data_inm(i_data_inm),
    .i_shamt(i_shamt),
    .i_rs(i_rs),
    .i_rt(i_rt),
    .i_rd(i_rd),
    .i_EX_control(i_EX_control),
    .i_EX_MEM_write_reg(i_EX_MEM_write_reg),
    .i_MEM_WB_write_reg(i_MEM_WB_write_reg),
    .i_EX_MEM_reg_write(i_EX_MEM_reg_write),
    .i_MEM_WB_reg_write(i_MEM_WB_reg_write),
    .i_EX_MEM_result_alu(i_EX_MEM_result_alu),
    .i_MEM_WB_data(i_MEM_WB_data),
    .o_data_write_mem(o_data_write_mem),
    .o_write_register(o_write_register),
    .o_result_alu(o_result_alu)
  );

  initial begin
    // Inicializar las entradas
    i_function = 0;
    i_data_ra = 0;
    i_data_rb = 0;
    i_data_inm = 0;
    i_shamt = 0;
    i_rs = 0;
    i_rt = 0;
    i_rd = 0;
    i_EX_control = 0;
    i_EX_MEM_write_reg = 0;
    i_MEM_WB_write_reg = 0;
    i_EX_MEM_reg_write = 0;
    i_MEM_WB_reg_write = 0;
    i_EX_MEM_result_alu = 0;
    i_MEM_WB_data = 0;

    // Inicio de la simulación
    #10;

    // Test 1
    $display("Test 1");
    i_function = 6'b000000; // ADD
    i_data_ra = 32'h00000001;
    i_data_rb = 32'h00000002;
    i_data_inm = 0;
    i_shamt = 0;
    i_rs = 0;
    i_rt = 0;
    i_rd = 0;
    i_EX_control = 7'b0010000; // ADD
    i_EX_MEM_write_reg = 0;
    i_MEM_WB_write_reg = 0;
    i_EX_MEM_reg_write = 0;
    i_MEM_WB_reg_write = 0;
    i_EX_MEM_result_alu = 0;
    i_MEM_WB_data = 0;

    #10;

    // Test 2
    $display("Test 2");
    i_function = 6'b100000; // ADD
    i_data_ra = 32'h00000003;
    i_data_rb = 32'h00000004;
    i_data_inm = 0;
    i_shamt = 0;
    i_rs = 0;
    i_rt = 0;
    i_rd = 0;
    i_EX_control = 7'b0010000; // ADD
    i_EX_MEM_write_reg = 0;
    i_MEM_WB_write_reg = 0;
    i_EX_MEM_reg_write = 0;
    i_MEM_WB_reg_write = 0;
    i_EX_MEM_result_alu = 0;
    i_MEM_WB_data = 0;

    #10;

    // Finalizar simulación
    $finish;
  end

endmodule
