`timescale 1ns / 1ps

module adder#(
        parameter NB = 32
    )
    (
        input   [NB-1:0] i_A,
        input   [NB-1:0] i_B,
        
        output  [NB-1:0] o_result
    );
    
    assign o_result = i_A + i_B;
    
endmodule