`timescale 1ns / 1ps
`include "parameters.vh"
/*
El módulo tiene cuatro puertos, 
i_A e i_B son entradas que usan en la operacion, 
i_OP Entrada que describe que operacion necesita hacer la ALU
o_RES Salida del resultado de la operación realizada por la ALU.
*/
module ALU
    #( //For Parameters
        parameter N_BITS = 32,
        parameter N_BITS_OP = 4
    )(
       //Port definition
       input wire signed [N_BITS - 1 : 0] i_A, //[ : ] range of bits
       input wire signed [N_BITS - 1 : 0] i_B,
       input wire[N_BITS_OP - 1 : 0] i_OP, //ALU OPERATION
       output reg signed [N_BITS - 1 : 0] o_RES
    );
    
    always @(*)
    begin
        case (i_OP)
            `SRL : 
                O_RES = B >> A;
            `SRA : 
                O_RES = B >>> A;
            `ADD : 
                O_RES = A + B; 
            `SUB : 
                O_RES = A - B;
            `AND : 
                O_RES = A & B; 
            `OR  : 
                O_RES = A | B; 
            `XOR : 
                O_RES = A ^ B;       
            `NOR : 
                O_RES = ~(A | B);
            `SLT:  
                O_RES = A < B;
            `LUI:  
                O_RES = B << 16;
            `SLL: 
                O_RES = B << A;
            default:
                o_RES = 32'b0;
            
        endcase
    end 
   
endmodule
