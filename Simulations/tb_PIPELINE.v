`timescale 1ns / 1ps
`include "parameters.vh"
module tb_PIPELINE;

  // Inputs
  localparam NB_REG = 5;
  reg clock;
  reg i_reset;
  reg [32-1:0] i_inst_load;
  reg [`ADDRWIDTH-1:0] i_addr_inst_load;
  reg i_en_write;
  reg i_en_read;
  reg i_enable_mem;
  reg i_enable_pipe;
  reg i_debug_unit;
  reg [NB_REG-1:0] i_addr_debug_unit;
  reg [`ADDRWIDTH-1:0] i_addr_mem_debug_unit;
  reg i_ctrl_read_debug_reg;
  reg i_ctrl_wr_debug_mem;
  reg i_ctrl_addr_debug_mem;
  // Declaración del arreglo de instrucciones
  reg [31:0] instrucciones [0:10];
  reg read_du = 0; 

  // Outputs
  wire [`ADDRWIDTH-1:0] o_data_send_pc;
  wire [31:0] o_data_reg_debug_unit;
  wire [31:0] o_data_mem_debug_unit;
  wire [`ADDRWIDTH-1:0] o_count_cycles;
  wire o_halt;
  integer i;

  // Instantiate the pipeline module
  pipeline pipeline (
    .clock(clock),
    .i_reset(i_reset),
    .i_inst_load(i_inst_load),
    .i_addr_inst_load(i_addr_inst_load),
    .i_en_write(i_en_write),
    .i_en_read(i_en_read),
    .i_enable_mem(i_enable_mem),
    .i_read_du(read_du),
    .i_enable_pipe(i_enable_pipe),
    .i_debug_unit(i_debug_unit),
    .i_addr_debug_unit(i_addr_debug_unit),
    .i_addr_mem_debug_unit(i_addr_mem_debug_unit),
    .i_ctrl_read_debug_reg(i_ctrl_read_debug_reg),
    .i_ctrl_wr_debug_mem(i_ctrl_wr_debug_mem),
    .i_ctrl_addr_debug_mem(i_ctrl_addr_debug_mem),
    .o_data_send_pc(o_data_send_pc),
    .o_data_reg_debug_unit(o_data_reg_debug_unit),
    .o_data_mem_debug_unit(o_data_mem_debug_unit),
    .o_count_cycles(o_count_cycles),
    .o_halt(o_halt)
  );


  // Clock generation
  always #1 clock = ~clock;

  // Initialize inputs
  initial begin
    clock = 0;
    i_reset = 0;
    i_inst_load = 0;
    i_addr_inst_load = 0;
    i_en_write = 0;
    i_en_read = 0;
    read_du = 0;
    i_enable_mem = 0;
    i_enable_pipe = 0;
    i_debug_unit = 0;
    i_addr_debug_unit = 0;
    i_addr_mem_debug_unit = 0;
    i_ctrl_read_debug_reg = 0;
    i_ctrl_wr_debug_mem = 0;
    i_ctrl_addr_debug_mem = 0;
    
    #2 i_reset = 1; // Apply reset
    #2 i_reset = 0; // Deassert reset
  
    //CARGAR UNA INSTRUCCION
    #2
    i_debug_unit = 1;
    
    //---------------------------------------------------
    //i_addr_inst_load = i_addr_inst_load + 1;
    #2
    i_inst_load = 32'b00111100000000010000000000001010;  // lui R1, 10
    #2
    i_en_write = 1;
    #2
    i_en_write = 0;
    i_inst_load = 0;
    //---------------------------------------------------
    #2
    i_addr_inst_load = i_addr_inst_load + 1;
    #2    
    i_inst_load = 32'b00111100000000100000000000010100; //lui R2, 20 
    #2
    i_en_write = 1;
    #2
    i_en_write = 0;
    i_inst_load = 0;
    //---------------------------------------------------
    #2
    i_addr_inst_load = i_addr_inst_load + 1;
    #2    
    i_inst_load = 32'b00111100000000110000000000011110; //lui R3, 30
    #2
    i_en_write = 1;
    #2
    i_en_write = 0;
    i_inst_load = 0;
    //--------------------------------------------------- 
    #2
    i_addr_inst_load = i_addr_inst_load + 1;
    #2    
    i_inst_load = 32'b00000000001000100010000000100001; //addu R4, R1, R2
    #2
    i_en_write = 1;
    #2
    i_en_write = 0;
    i_inst_load = 0;
    
    //--------------------------------------------------- 
    
    #2
    i_addr_inst_load = i_addr_inst_load + 1;
    #2    
    i_inst_load = 32'b00010000011001000000000000000111; //beq R3, R4, 3
    #2
    i_en_write = 1;
    #2
    i_en_write = 0;
    i_inst_load = 0;    
    //--------------------------------------------------- 
    
    #2
    i_addr_inst_load = i_addr_inst_load + 1;
    #2    
    i_inst_load = 32'b00100000000000110000000000001010; //addi R3, 10
    #2
    i_en_write = 1;
    #2
    i_en_write = 0;
    i_inst_load = 0;
    //--------------------------------------------------- 
    #2
    i_addr_inst_load = i_addr_inst_load + 1;
    #2    
    i_inst_load = 32'b00001000000000000000000000001000; //j 1
    #2
    i_en_write = 1;
    #2
    i_en_write = 0;
    i_inst_load = 0;
    //---------------------------------------------------     
    #2
    i_addr_inst_load = i_addr_inst_load + 1;
    #2    
    i_inst_load = 32'b00100000000000110000000000001010; //addi R3, 10
    #2
    i_en_write = 1;
    #2
    i_en_write = 0;
    i_inst_load = 0;
        //--------------------------------------------------- 
    #2
    i_addr_inst_load = i_addr_inst_load + 1;
    #2    
    i_inst_load = 32'b10001100000001010000000000000000; //lw R5, 0(0)
    #2
    i_en_write = 1;
    #2
    i_en_write = 0;
    i_inst_load = 0;
        //--------------------------------------------------- 
    #2
    i_addr_inst_load = i_addr_inst_load + 1;
    #2    
    i_inst_load = 32'b10101100000001000000000000000001; //sw R4, 1(0)
    #2
    i_en_write = 1;
    #2
    i_en_write = 0;
    i_inst_load = 0;
        //--------------------------------------------------- 
    #2
    i_addr_inst_load = i_addr_inst_load + 1;
    #2    
    i_inst_load = 32'b11111100000000000000000000000000; //halt
    #2
    i_en_write = 1;
    #2
    i_en_write = 0;
    i_inst_load = 0;

    #2
    i_addr_inst_load = i_addr_inst_load + 1;
    i_debug_unit = 0;   
    //FIN DE CARGA DE INSTRUCCIONES
    #2
    i_enable_pipe = 1;
    i_en_read = 1;
    #200 $finish; // End simulation
  end

endmodule


/*
lui R1, 10
lui R2, 20
lui R3, 30
addu R4, R1, R2
beq R3, R4, 2
j 0
addi R3, 10
lw R5, 0(0)
sw R4, 1(0)
halt

00111100000000010000000000001010
00111100000000100000000000010100
00111100000000110000000000011110
00000000001000100010000000100001
00010000011001000000000000000010
00001000000000000000000000000000
00100000000000110000000000001010
10001100000001010000000000000000
10101100000001000000000000000001
11111100000000000000000000000000
*/








