`timescale 1ns / 1ps

module tb_alu_control;
    localparam NB_FUNCTION = 6;
    localparam NB_ALU_OP = 3;
    localparam NB_OP_ALU = 4;
        
    wire [NB_FUNCTION-1:0]  function_i;
    wire [NB_ALU_OP-1:0]   alu_op_i;
    
    wire [3:0] cod_op_alu;

    //for clock pulse
    reg clk = 0;
    
    //Instancio alu_control
    alu_control inst_alu_control
    (
        .function_i(function_i),
        .alu_op_i(alu_op_i),
        .alu_op_o(cod_op_alu)
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
            EN_W = 1;
            EN_R = 0;
            ADDR_I= 6'b0;
            DATA_I= 32'b1010;
            
            #10
            EN_W = 0;
            EN_R = 1;
            ADDR_I= 6'b0;
            #12
            $finish;
 
        end
endmodule