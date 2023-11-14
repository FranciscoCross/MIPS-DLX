`timescale 1ns / 1ps

module tb_ID();

  // Parameters
  parameter  NB_PC_CONSTANT = 3;
  parameter  NB_INST        = 32;
  parameter  NB_PC          = 32;
  parameter  NB_DATA        = 32;
  parameter  NB_REG         = 5;
  parameter  NB_OPCODE      = 6;

  // Ports
  reg                   i_clock;
  reg                   i_ID_reset;
  reg                   i_ID_enable;
  reg [NB_INST-1:0]     i_ID_inst;
  reg [NB_PC-1:0]       i_ID_pc;
  reg [NB_DATA-1:0]     i_ID_write_data;
  reg [NB_REG-1:0]      i_ID_write_reg;
  reg                   i_ID_reg_write;
  
  wire                  o_ID_reg_dest;
  wire [NB_OPCODE-1:0]  o_ID_alu_op;
  wire                  o_ID_alu_src;
  wire                  o_ID_mem_read;
  wire                  o_ID_mem_write;
  wire                  o_ID_branch;
  wire                  o_ID_reg_write;
  wire                  o_ID_jump;
  wire                  o_ID_halt;
  wire [NB_PC-1:0]      o_ID_jump_addr;
  wire [NB_DATA-1:0]    o_ID_data_a;
  wire [NB_DATA-1:0]    o_ID_data_b;
  wire [NB_PC-1:0]      o_ID_immediate;
  wire [NB_DATA-1:0]    o_ID_shamt; // TODO: testear que salga con 32b 
  wire [NB_REG-1:0]     o_ID_rt;
  wire [NB_REG-1:0]     o_ID_rd;
  wire [NB_PC-1:0]      o_ID_pc;
  wire                  o_byte_enable;
  wire                  o_halfword_enable;
  wire                  o_word_enable;

//  $monitor("time=%t -> inst=%b, data_A=%b, data_B=%b, immed=%b, rt=%b, rd=%b, jmp_addr=%b", $time, i_ID_inst, o_ID_data_a, o_ID_data_b, o_ID_immediate, o_ID_rt, o_ID_rd, o_ID_jump_addr);

  initial begin
    i_clock         = 1'b0;
    i_ID_reset      = 1'b1;
    i_ID_enable     = 1'b0;
    i_ID_inst       = {NB_INST{1'b0}};
    i_ID_pc         = {NB_PC{1'b0}};
    i_ID_write_data = {NB_DATA{1'b0}};
    i_ID_write_reg  = {NB_REG{1'b0}};
    i_ID_reg_write  = 1'b0; // Don't WB bank register
    // $s0=16, $s1=17, $s2=18
//    #40
//    $write("\n");
//    $display("Testing add $s0,$s1,$s2");
//    i_ID_reset  = 1'b0;
//    i_ID_enable = 1'b1;
//    i_ID_inst   = 32'b00000010001100101000000000100000; // add $s0,$s1,$s2;

//    #40
//    $write("\n");
//    $display("Testing addu $s0,$s1,$s2");
//    i_ID_inst = 32'b00000010001100101000000000100001; // addu $s0,$s1,$s2;

//    #40
//    $write("\n");
//    $display("Testing sub $s0,$s1,$s2");
//    i_ID_inst = 32'b00000010001100101000000000100010; // sub $s0,$s1,$s2;

//    #40
//    $write("\n");
//    $display("Testing and $s0,$s1,$s2");
//    i_ID_inst = 32'b00000010001100101000000000100100; // and $s0,$s1,$s2;

//    #40
//    $write("\n");
//    $display("Testing nor $s0,$s1,$s2");
//    i_ID_inst = 32'b00000010001100101000000000100111; // nor $s0,$s1,$s2;

//    #40
//    $write("\n");
//    $display("Testing or $s0,$s1,$s2");
//    i_ID_inst = 32'b00000010001100101000000000100101; // or $s0,$s1,$s2;

//    #40
//    $write("\n");
//    $display("Testing xor $s0,$s1,$s2");
//    i_ID_inst = 32'b00000010001100101000000000100110; // xor $s0,$s1,$s2;

//    #40
//    $write("\n");
//    $display("Testing slt $s0,$s1,$s2");
//    i_ID_inst = 32'b00000010001100101000000000101010; // slt $s0,$s1,$s2;

    #40
    $write("\n");
    $display("Testing j 255;");
    i_ID_inst = 32'b00111110000000000000000011111111; // J

    #40
    $write("\n");
    $display("Testing jal 255;");
    i_ID_inst = 32'b00101010000100010000000011111111; // JAL
    
    #40
    $write("\n");
    $display("Testing jr $s0");
    i_ID_inst = 32'b00000010000000000000000000001000; // jr $s0;

    #40
    $write("\n");
    $display("Testing jalr $s0");
    i_ID_inst = 32'b00000010000000000000000000001001; // jalr $s0;

//    #40
//    $write("\n");
//    $display("Testing lb $s0,2($t0);");
//    i_ID_inst = 32'b10000010000010000000000000000010;

//    #40
//    $write("\n");
//    $display("Testing sw $s0,-2($t0);");
//    i_ID_inst = 32'b10101110000010001111111111111110;

//    #40
//    $write("\n");
//    $display("Testing addi $s0,$s1,255;");
//    i_ID_inst = 32'b00100010000100010000000011111111;

//    #40
//    $write("\n");
//    $display("Testing lui $s0,255;");
//    i_ID_inst = 32'b00111110000000000001111111100000;

    #40
    $write("\n");
    $display("Testing beq $s0,$s1,255;");
    i_ID_inst = 32'b00010010000100010000000011111111;
    
    #40
    $write("\n");
    $display("Testing sll");
    i_ID_inst = 32'b00000000000100011000000011000000;
    
    #40
    $write("\n");
    $display("Testing sll");
    i_ID_inst = 32'b00000000000100011000000011000000;
    
    #200
    $finish;
    
  end

  always #10 i_clock = ~i_clock;

  DECODE ID_instance(
    .i_clock(i_clock),
    .i_ID_reset(i_ID_reset),
    .i_ID_enable(i_ID_enable),
    .i_ID_inst(i_ID_inst),
    .i_ID_pc(i_ID_pc),
    .i_ID_write_data(i_ID_write_data),
    .i_ID_write_reg(i_ID_write_reg),
    .o_ID_reg_dest(o_ID_reg_dest),
    .o_ID_alu_op(o_ID_alu_op),
    .o_ID_alu_src(o_ID_alu_src),
    .o_ID_mem_read(o_ID_mem_read),
    .o_ID_mem_write(o_ID_mem_write),
    .o_ID_branch(o_ID_branch),
    .o_ID_reg_write(o_ID_reg_write),
    .o_ID_jump(o_ID_jump),
    .o_ID_halt(o_ID_halt),
    .o_ID_jump_addr(o_ID_jump_addr),
    .o_ID_data_a(o_ID_data_a),
    .o_ID_data_b(o_ID_data_b),
    .o_ID_immediate (o_ID_immediate),
    .o_ID_shamt(o_ID_shamt),
    .o_ID_rt(o_ID_rt),
    .o_ID_rd(o_ID_rd),
    .o_ID_pc(o_ID_pc),
    .o_ID_byte_enable(o_byte_enable),
    .o_ID_halfword_enable(o_halfword_enable),
    .o_ID_word_enable(o_word_enable)
  );

endmodule
