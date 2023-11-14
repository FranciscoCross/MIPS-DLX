`timescale 1ns / 1ps

module alu#(
        parameter NB_REG    = 32,
        parameter NB_ALU_CTRLI = 4
    )    
    (
        input signed [NB_REG-1 : 0]         i_A,
        input signed [NB_REG-1 : 0]         i_B,
        input       [NB_ALU_CTRLI-1 : 0]    i_alu_ctrl, // codigo de operacion que viene de la alu_control
        output                              o_zero,
        output reg signed [NB_REG-1 : 0]    o_result 
    );
   
    always@(*) begin
        case(i_alu_ctrl)
            4'h0 : begin
                o_result =   i_B << i_A;      // SLL Shift left logical (r1<<r2) y SLLV
            end
            4'h1 : begin
                o_result =   i_B >> i_A;      // SRL Shift right logical (r1>>r2) y SRLV
            end
            4'h2 : begin
                o_result =   i_B >>> i_A;     // SRA  Shift right arithmetic (r1>>>r2) y SRAV
            end
            4'h3 : begin
                o_result =   i_A + i_B;       // ADD Sum (r1+r2)
            end
            4'h4 : begin
                o_result =   i_A - i_B;       // SUB Substract (r1-r2)
            end
            4'h5 : begin
                o_result =   i_A & i_B;       // AND Logical and (r1&r2)
            end
            4'h6 : begin
                o_result =   i_A | i_B;       // OR Logical or (r1|r2)
            end
            4'h7 : begin
                o_result =   i_A ^ i_B;       // XOR Logical xor (r1^r2)
            end
            4'h8 : begin
                o_result = ~(i_A | i_B);      // NOR Logical nor ~(r1|r2)
            end
            4'h9 : begin 
                o_result =   i_A < i_B;       // SLT Compare (r1<r2)
            end
            4'ha : begin
                o_result =   i_B << 16;       // SLL16
            end
            4'hb : begin
                o_result =   i_A != i_B;      // BEQ: Invertida porque AND a la entrada espera un 1 para saltar
            end
            4'hc : begin
                o_result =   i_A == i_B;      // BNEQ: Invertida 
            end
            default : begin 
                o_result =  {NB_REG{1'b0}};
            end
        endcase
    end
    
    assign o_zero = o_result == 0;
       
endmodule