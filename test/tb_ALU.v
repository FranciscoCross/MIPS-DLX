`timescale 1ns / 1ps

module tb_ALU;
    localparam N_BITS = 8;
    //Inputs and outputs declaration
    reg[N_BITS - 1 : 0] A;
    reg[N_BITS - 1 : 0] B;
    reg[N_BITS - 1 : 0] OP;
    //for clock pulse
    reg clk;
    
    wire[N_BITS - 1 : 0] RES;
    
    //Instancio ALU
    ALU #( //Modul definition with own parameters
        .N_BITS (N_BITS)
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
    OP = 6'b100000; //ADD, expected 10
    #10
    A = 5;
    B = 10;    
    OP = 6'b100010; //SUB, expected -5
    #10
    A = 8'b00011111;
    B = 8'b11111000;    
    OP = 6'b100100; //AND,  expected 00011000
    #10
    A = 8'b00011111;
    B = 8'b11111000;    
    OP = 6'b100101; //OR, expected 11111111
    #10
    A = 8'b00011000;
    B = 8'b10011011;    
    OP = 6'b100110; //XOR, expected 100000011
    #10
    A = 8'b00011000;
    B = 2;    
    OP = 6'b000011; //SRA, expected 00000110
    #10
    A = 8'b00011000;
    B = 2;    
    OP = 6'b000010; //SRL, , expected 00000110
    #10
    A = 8'b00001111;
    B = 8'b00010100;    
    OP = 6'b100111; //NOR, expected 1110000
    #10
    $finish;
    
    end
    
endmodule
