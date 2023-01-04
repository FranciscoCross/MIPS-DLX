`timescale 1ns / 1ps

module tb_alu_control;
    localparam NB_FUNCTION = 6;
    localparam NB_ALU_OP = 3;
    localparam NB_OP_ALU = 4;
    localparam NB_DATA = 8;
        
    reg [NB_FUNCTION-1:0] i_function;
    reg [NB_ALU_OP-1:0]   i_alu_op;
    reg [NB_DATA - 1 : 0] A;
    reg [NB_DATA - 1 : 0] B;

    wire [3:0] cod_op_alu;
    wire[NB_DATA - 1 : 0] RES;

    //for clock pulse
    reg clk = 0;
    
    //Instancio alu_control
    alu_control inst_alu_control
    (
        .i_function(i_function),
        .i_alu_op(i_alu_op),
        .o_alu_op(cod_op_alu)
    );
    
    //Instancio ALU
    ALU inst_ALU
    ( 
        .i_A(A),
        .i_B(B),
        .i_OP(cod_op_alu),
        .o_RES(RES)
    );
    
    always #1 clk = ~clk; // # < timeunit > delay
       initial begin
        #0
        clk = 1;
        A = 0;
        B = 0;
        i_alu_op = 0;
        i_function = 0;
        #10
        A = 3;
        B = 3;
        //R TYPE Instruction
        i_alu_op = `R_ALUCODE;
        //Set ALU fcn
        i_function = `ADDU_FUNCTION;
        #10
        $finish;
        end
endmodule