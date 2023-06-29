`timescale 1ns / 1ps

module unit_forward_tb;

  // Parámetros del Test Bench
  parameter NB_REG = 5;

  // Señales de entrada y salida del Test Bench
  reg [NB_REG-1:0] i_ID_EX_rs;
  reg [NB_REG-1:0] i_ID_EX_rt;
  reg [NB_REG-1:0] i_EX_MEM_write_reg;
  reg [NB_REG-1:0] i_MEM_WB_write_reg;
  reg i_EX_MEM_reg_write;
  reg i_MEM_WB_reg_write;
  wire [1:0] o_forward_A;
  wire [1:0] o_forward_B;

  // Instancia del módulo unit_forward
  unit_forward #(.NB_REG(NB_REG)) dut (
    .i_ID_EX_rs(i_ID_EX_rs),
    .i_ID_EX_rt(i_ID_EX_rt),
    .i_EX_MEM_write_reg(i_EX_MEM_write_reg),
    .i_MEM_WB_write_reg(i_MEM_WB_write_reg),
    .i_EX_MEM_reg_write(i_EX_MEM_reg_write),
    .i_MEM_WB_reg_write(i_MEM_WB_reg_write),
    .o_forward_A(o_forward_A),
    .o_forward_B(o_forward_B)
  );

  // Inicialización de señales de entrada
  initial begin
    // Señales de entrada para la prueba 1
    i_ID_EX_rs = 3'b001;
    i_ID_EX_rt = 3'b010;
    i_EX_MEM_write_reg = 3'b010;
    i_MEM_WB_write_reg = 3'b100;
    i_EX_MEM_reg_write = 1'b1;
    i_MEM_WB_reg_write = 1'b0;

    // Ejecución de la prueba 1
    #10; // Retardo para permitir que el circuito responda

    // Señales de salida esperadas para la prueba 1
    if (o_forward_A !== 2'b10) begin
      $display("Prueba 1 fallida: o_forward_A incorrecto");
    end
    if (o_forward_B !== 2'b00) begin
      $display("Prueba 1 fallida: o_forward_B incorrecto");
    end

    // Señales de entrada para la prueba 2
    i_ID_EX_rs = 3'b100;
    i_ID_EX_rt = 3'b011;
    i_EX_MEM_write_reg = 3'b110;
    i_MEM_WB_write_reg = 3'b100;
    i_EX_MEM_reg_write = 1'b0;
    i_MEM_WB_reg_write = 1'b1;

    // Ejecución de la prueba 2
    #10; // Retardo para permitir que el circuito responda

    // Señales de salida esperadas para la prueba 2
    if (o_forward_A !== 2'b00) begin
      $display("Prueba 2 fallida: o_forward_A incorrecto");
    end
    if (o_forward_B !== 2'b01) begin
      $display("Prueba 2 fallida: o_forward_B incorrecto");
    end

    // Finalización de la simulación
    $finish;
  end

endmodule

