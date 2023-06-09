`timescale 1ns / 1ps

module tb_MEMORIA;

  parameter NB_DATA = 32;
  parameter NB_MEM_CTRL = 6;
  parameter ADDRWIDTH = 10;

  reg i_clock;
  reg i_reset;
  reg i_enable_mem;
  reg [NB_MEM_CTRL-1:0] i_MEM_control;
  reg [`ADDRWIDTH-1:0] i_alu_result;
  reg [NB_DATA-1:0] i_data_write;
  reg [`ADDRWIDTH-1:0] i_addr_mem_debug_unit;
  reg i_ctrl_addr_debug_mem;
  reg i_ctrl_wr_debug_mem;
  wire o_bit_sucio;
  wire [NB_DATA-1:0] o_data_mem_debug_unit;
  wire [NB_DATA-1:0] o_mem_data;

  integer i;

  MEMORIA #(
    .NB_DATA(NB_DATA),
    .NB_MEM_CTRL(NB_MEM_CTRL)
  ) MEMORIA (
    .i_clock(i_clock),
    .i_reset(i_reset),
    .i_enable_mem(i_enable_mem),
    .i_MEM_control(i_MEM_control),
    .i_alu_result(i_alu_result),
    .i_data_write(i_data_write),
    .i_addr_mem_debug_unit(i_addr_mem_debug_unit),
    .i_ctrl_addr_debug_mem(i_ctrl_addr_debug_mem),
    .i_ctrl_wr_debug_mem(i_ctrl_wr_debug_mem),
    .o_bit_sucio(o_bit_sucio),
    .o_data_mem_debug_unit(o_data_mem_debug_unit),
    .o_mem_data(o_mem_data)
  );

  initial begin
    // Inicializar las entradas
    i_clock = 0;
    i_reset = 0;
    i_enable_mem = 0;
    i_MEM_control = 0;
    i_alu_result = 0;
    i_data_write = 0;
    i_addr_mem_debug_unit = 0;
    i_ctrl_addr_debug_mem = 0;
    i_ctrl_wr_debug_mem = 0;

    // Inicio de la simulación
    #10;

    // Test 1
    $display("Test 1");
    i_clock = 1;
    i_reset = 1;
    i_enable_mem = 1;
    i_MEM_control = 6'b000001; // Lectura
    i_alu_result = 10'b0000000000; // Dirección de memoria
    i_data_write = 0;
    i_addr_mem_debug_unit = 10'b0000000000;
    i_ctrl_addr_debug_mem = 0;
    i_ctrl_wr_debug_mem = 0;

    #10;

    // Test 2
    $display("Test 2");
    i_clock = 0;
    i_reset = 0;
    i_enable_mem = 1;
    i_MEM_control = 6'b000010; // Escritura
    i_alu_result = 10'b0000000000; // Dirección de memoria
    i_data_write = 32'h12345678; // Dato a escribir
    i_addr_mem_debug_unit = 10'b0000000000;
    i_ctrl_addr_debug_mem = 0;
    i_ctrl_wr_debug_mem = 0;

    #10;

    // Finalizar simulación
    $finish;
  end

endmodule
