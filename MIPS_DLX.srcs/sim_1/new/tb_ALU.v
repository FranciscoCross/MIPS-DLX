`timescale 1ns / 1ps
`include "parameters.vh"

module tb_ALU;
    localparam NB_DATA = 8;
    localparam NB_OP = 4;
    //Inputs and outputs declaration
    reg[NB_DATA - 1 : 0] A;
    reg[NB_DATA - 1 : 0] B;
    reg[NB_OP - 1 : 0] OP;
    //for clock pulse
    reg clk;
    
    wire[NB_DATA - 1 : 0] RES;
    
    //Instancio ALU
    ALU #( //Modul definition with own parameters
        .N_BITS (NB_DATA)
    )
    instancia_ALU( //Instance name
        .i_A(A),
        .i_B(B),
        .i_OP(OP),
        .o_RES(RES)
    );
    
    //Create a clock
    always #1 clk = ~clk; // # < timeunit > delay
    
    //Initial block will only excecute once.
    initial
    begin
    //For value (wire and reg) change saving 
    $dumpfile("tb_alu.vcd");
    //Specify variables to be dumped, w/o any argument it dumps all variables 
    $dumpvars;
    #0
    clk = 1;
    A = 0;
    B = 0;
    OP = 0;
    #10
    A = 0;
    B = 0;    
    OP = 0;
    #10
    A = 5;
    B = 5;    
    OP = `ADD; //ADD, expected 10
    #10
    A = 5;
    B = 10;    
    OP = `SUB; //SUB, expected -5
    #10
    A = 8'b00011111;
    B = 8'b11111000;    
    OP = `AND; //AND,  expected 00011000
    #10
    A = 8'b00011111;
    B = 8'b11111000;    
    OP = `OR; //OR, expected 11111111
    #10
    A = 8'b00011000;
    B = 8'b10011011;    
    OP = `XOR; //XOR, expected 100000011
    #10
    A = 8'b00011000;
    B = 2;    
    OP = `SRA; //SRA, expected 00000110
    #10
    A = 8'b00011000;
    B = 2;    
    OP = `SRL; //SRL, , expected 00000110
    #10
    A = 8'b00001111;
    B = 8'b00010100;    
    OP = `NOR; //NOR, expected 1110000
    #10
    $finish;
    
    end
    
endmodule
