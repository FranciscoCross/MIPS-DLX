`timescale 1ns / 1ps

module ALU
    #( //For Parameters
        parameter N_BITS = 8
    )(
       //Port definition
       input wire[N_BITS - 1 : 0] i_A, //[ : ] range of bits
       input wire[N_BITS - 1 : 0] i_B,
       input wire[N_BITS - 1 : 0] i_OP,
       output reg[N_BITS - 1 : 0] o_RES
    );
    //Local parameter definition
    localparam ADD = 6'b100000;
    localparam SUB = 6'b100010;
    localparam AND = 6'b100100;
    localparam OR  = 6'b100101;
    localparam XOR = 6'b100110;
    localparam SRA = 6'b000011;
    localparam SRL = 6'b000010;
    localparam NOR = 6'b100111;
    
    always @(*) //Sintetizable secuential loop executed on: "event expresion list" . * means on every event
    begin //c++ scope equivalent.
        case (i_OP)
            ADD:
                o_RES = (i_A + i_B);
            SUB:
                o_RES = (i_A - i_B);
            AND:
                o_RES = (i_A & i_B);
            OR:
                o_RES = (i_A | i_B);
            XOR:
                o_RES = (i_A ^ i_B);
            SRA: //Shift Right Arithmetic, fills with the sign (1 if negative, 0 if positive)
                o_RES = (i_A >>> i_B);
            SRL: //Shift Rigth Logical, fills with 0
                o_RES = (i_A >> i_B);
            NOR:
                o_RES = ~(i_A | i_B);
            default:
                o_RES = 0;
        endcase
    end 
   
endmodule
