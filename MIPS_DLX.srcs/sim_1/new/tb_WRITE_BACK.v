`timescale 1ns / 1ps

module tb_WRITE_BACK;

  parameter NB_DATA = 32;
  parameter NB_MEM_TO_REG = 2;
  parameter ADDRWIDTH = 10;

  reg [NB_DATA-1:0] i_mem_data;
  reg [NB_DATA-1:0] i_alu_result;
  reg [`ADDRWIDTH-1:0] i_pc;
  reg [NB_DATA-1:0] i_inm_ext;
  reg [NB_MEM_TO_REG-1:0] i_mem_to_reg;
  wire [NB_DATA-1:0] o_data;

  WRITE_BACK #(
    .NB_DATA(NB_DATA),
    .NB_MEM_TO_REG(NB_MEM_TO_REG)
  ) WRITE_BACK (
    .i_mem_data(i_mem_data),
    .i_alu_result(i_alu_result),
    .i_pc(i_pc),
    .i_inm_ext(i_inm_ext),
    .i_mem_to_reg(i_mem_to_reg),
    .o_data(o_data)
  );

  initial begin
    // Inicializar las entradas
    i_mem_data = 0;
    i_alu_result = 0;
    i_pc = 0;
    i_inm_ext = 0;
    i_mem_to_reg = 0;

    // Inicio de la simulación
    #10;

    // Test 1
    $display("Test 1");
    i_mem_data = 32'hABCDEF01;
    i_alu_result = 32'h12345678;
    i_pc = 10'b0000000000;
    i_inm_ext = 32'h87654321;
    i_mem_to_reg = 2'b01; // Memoria a registro
    #10;

    // Test 2
    $display("Test 2");
    i_mem_data = 32'h98765432;
    i_alu_result = 32'h87654321;
    i_pc = 10'b1111111111;
    i_inm_ext = 32'hABCDEF01;
    i_mem_to_reg = 2'b10; // PC a registro
    #10;

    // Finalizar simulación
    $finish;
  end

endmodule
