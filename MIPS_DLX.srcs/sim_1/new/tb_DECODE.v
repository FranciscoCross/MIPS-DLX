`timescale 1ns / 1ps

module tb_DECODE;

  reg i_clock;
  reg i_reset;
  reg i_ctrl_read_debug_reg;
  reg [31:0] i_instruction;
  reg [31:0] i_data_rw;
  reg [4:0] i_write_register;
  reg i_reg_write;
  reg [31:0] i_pc;
  reg [4:0] i_addr_debug_unit;
  reg [4:0] i_EX_write_register;
  reg [4:0] i_EX_rt;
  reg i_ID_EX_mem_read;
  reg i_EX_reg_write;
  reg i_forward_A;
  reg i_forward_B;
  reg [31:0] i_data_forward_EX_MEM_i;
  
  wire [4:0] o_rs;
  wire [4:0] o_rt;
  wire [4:0] o_rd;
  wire [31:0] o_data_ra;
  wire [31:0] o_data_rb;
  wire [4:0] o_shamt;
  wire [31:0] o_inm_ext;
  wire [5:0] o_function;
  wire [1:0] o_pc_src;
  wire o_branch_or_jump;
  wire [9:0] o_addr_register;
  wire [9:0] o_addr_branch;
  wire [9:0] o_addr_jump;
  wire o_pc_write;
  wire o_IF_ID_write;
  wire [31:0] o_data_reg_debug_unit;
  wire [6:0] o_EX_control;
  wire [5:0] o_M_control;
  wire [2:0] o_WB_control;
  wire o_halt;

  DECODE DECODE (
    .i_clock(i_clock),
    .i_reset(i_reset),
    .i_ctrl_read_debug_reg(i_ctrl_read_debug_reg),
    .i_instruction(i_instruction),
    .i_data_rw(i_data_rw),
    .i_write_register(i_write_register),
    .i_reg_write(i_reg_write),
    .i_pc(i_pc),
    .i_addr_debug_unit(i_addr_debug_unit),
    .i_EX_write_register(i_EX_write_register),
    .i_EX_rt(i_EX_rt),
    .i_ID_EX_mem_read(i_ID_EX_mem_read),
    .i_EX_reg_write(i_EX_reg_write),
    .i_forward_A(i_forward_A),
    .i_forward_B(i_forward_B),
    .i_data_forward_EX_MEM(i_data_forward_EX_MEM_i),
    .o_rs(o_rs),
    .o_rt(o_rt),
    .o_rd(o_rd),
    .o_data_ra(o_data_ra),
    .o_data_rb(o_data_rb),
    .o_shamt(o_shamt),
    .o_inm_ext(o_inm_ext),
    .o_function(o_function),
    .o_pc_src(o_pc_src),
    .o_branch_or_jump(o_branch_or_jump),
    .o_addr_register(o_addr_register),
    .o_addr_branch(o_addr_branch),
    .o_addr_jump(o_addr_jump),
    .o_pc_write(o_pc_write),
    .o_IF_ID_write(o_IF_ID_write),
    .o_data_reg_debug_unit(o_data_reg_debug_unit),
    .o_EX_control(o_EX_control),
    .o_M_control(o_M_control),
    .o_WB_control(o_WB_control),
    .o_halt(o_halt)
  );

  initial begin
    // Inicialización de entradas
    i_clock = 0;
    i_reset = 0;
    i_ctrl_read_debug_reg = 0;
    i_instruction = 32'h00000000;
    i_data_rw = 32'h00000000;
    i_write_register = 5'b00000;
    i_reg_write = 0;
    i_pc = 32'h00000000;
    i_addr_debug_unit = 5'b00000;
    i_EX_write_register = 5'b00000;
    i_EX_rt = 5'b00000;
    i_ID_EX_mem_read = 0;
    i_EX_reg_write = 0;
    i_forward_A = 0;
    i_forward_B = 0;
    i_data_forward_EX_MEM_i = 32'h00000000;

    // Generación de señales de reloj
    forever #5 i_clock = ~i_clock;
  end

  always @(posedge i_clock) begin
    // Testbench
    if ($time == 0) begin
      // Configuración de las entradas para la instrucción de carga (LW)
      i_instruction = 32'h8C410000;  // LW $1, 0($2)
      i_data_rw = 32'h00000000;
      i_write_register = 5'b00010;  // $2
      i_reg_write = 1;
      i_pc = 32'h00000000;
      i_addr_debug_unit = 5'b00000;
      i_EX_write_register = 5'b00000;
      i_EX_rt = 5'b00000;
      i_ID_EX_mem_read = 0;
      i_EX_reg_write = 0;
      i_forward_A = 0;
      i_forward_B = 0;
      i_data_forward_EX_MEM_i = 32'h00000000;
    end

    // Añadir más casos de prueba aquí

    if ($time == 100) begin
      // Finalizar simulación
      $finish;
    end
  end

endmodule
