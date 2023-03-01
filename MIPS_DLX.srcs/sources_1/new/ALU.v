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
        parameter N_BITS = 8,
        parameter N_BITS_OP = 4
    )(
       //Port definition
       input wire[N_BITS - 1 : 0] i_A, //[ : ] range of bits
       input wire[N_BITS - 1 : 0] i_B,
       input wire[N_BITS_OP - 1 : 0] i_OP, //ALU OPERATION
       output reg[N_BITS - 1 : 0] o_RES
    );
    
    always @(*)
    begin
        case (i_OP)
            `ADD:
                o_RES = (i_A + i_B);
            `SUB:
                o_RES = (i_A - i_B);
            `AND:
                o_RES = (i_A & i_B);
            `OR:
                o_RES = (i_A | i_B);
            `XOR:
                o_RES = (i_A ^ i_B);
            `SRA: //Shift Right Arithmetic, fills with the sign (1 if negative, 0 if positive)
                o_RES = (i_A >>> i_B);
            `SRL: //Shift Rigth Logical, fills with 0
                o_RES = (i_A >> i_B);
            `NOR:
                o_RES = ~(i_A | i_B);
            default:
                o_RES = 0;
        endcase
    end 
   
endmodule
