`timescale 1ns / 1ps
`include "parameters.vh"
module alu_control#(
        parameter   NB_FCODE        = 6,
        parameter   NB_OPCODE       = 6,
        parameter   NB_ALU_CTRLI    = 4
        
    )
    (
        input      [NB_FCODE-1     : 0] i_funct_code, // Codigo de funcion para instrucciones tipo R
        input      [NB_OPCODE-1    : 0] i_alu_op,     // opcode
        output reg [NB_ALU_CTRLI-1 : 0] o_alu_ctrl,   // Senial que indica a la ALU que tipo de operacion ejecutar
        output reg                      o_shamt_ctrl, // Senial de MUX: 0 -> shamt  1 -> data_a
        output reg                      o_last_register_ctrl    // Senial que selecciona registro last_register para que se guarde el PC
    );
    
    always@(*) begin
        // Inicializacion para que no se produzca un inferred latch
        o_alu_ctrl = 4'h00;
        o_shamt_ctrl = 1'b0;
        o_last_register_ctrl = 1'b0;

        case(i_alu_op)
            `RTYPE_OPCODE: begin
                case(i_funct_code)
                        `SLL_FCODE   : begin
                            o_alu_ctrl = 4'h00;
                            o_shamt_ctrl = 1'b0; // Elige shamt
                            o_last_register_ctrl = 1'b0;
                        end 
                        `SRL_FCODE   : begin
                            o_alu_ctrl = 4'h01;
                            o_shamt_ctrl = 1'b0; // Elige shamt
                            o_last_register_ctrl = 1'b0;
                        end
                        `SRA_FCODE   : begin
                            o_alu_ctrl = 4'h02;
                            o_shamt_ctrl = 1'b0; // Elige shamt
                            o_last_register_ctrl = 1'b0;
                        end
                        `SLLV_FCODE  : begin
                            o_alu_ctrl = 4'h00;
                            o_shamt_ctrl = 1'b1; // Elige data_a (rs)
                            o_last_register_ctrl = 1'b0;
                        end
                        `SRLV_FCODE  : begin
                            o_alu_ctrl = 4'h01;
                            o_shamt_ctrl = 1'b1; // Elige data_a (rs)
                            o_last_register_ctrl = 1'b0;
                        end
                        `SRAV_FCODE  : begin
                            o_alu_ctrl = 4'h02;
                            o_shamt_ctrl = 1'b1; // Elige data_a (rs)
                            o_last_register_ctrl = 1'b0;
                        end
                        `ADD_FCODE   : begin
                            o_alu_ctrl = 4'h03;
                            o_shamt_ctrl = 1'b1; // Elige data_a
                            o_last_register_ctrl = 1'b0;
                        end
                        `ADDU_FCODE  : begin
                            o_alu_ctrl = 4'h03;
                            o_shamt_ctrl = 1'b1; // Elige data_a
                            o_last_register_ctrl = 1'b0;
                        end
                        `SUB_FCODE   : begin
                            o_alu_ctrl = 4'h04;
                            o_shamt_ctrl = 1'b1; // Elige data_a
                            o_last_register_ctrl = 1'b0;
                        end
                        `SUBU_FCODE  : begin
                            o_alu_ctrl = 4'h04;
                            o_shamt_ctrl = 1'b1; // Elige data_a
                            o_last_register_ctrl = 1'b0;
                        end
                        `AND_FCODE   : begin
                            o_alu_ctrl = 4'h05;
                            o_shamt_ctrl = 1'b1; // Elige data_a
                            o_last_register_ctrl = 1'b0;
                        end
                        `OR_FCODE    : begin
                            o_alu_ctrl = 4'h06;
                            o_shamt_ctrl = 1'b1; // Elige data_a
                            o_last_register_ctrl = 1'b0;
                        end
                        `XOR_FCODE   : begin
                            o_alu_ctrl = 4'h07;
                            o_shamt_ctrl = 1'b1; // Elige data_a
                            o_last_register_ctrl = 1'b0;
                        end
                        `NOR_FCODE   : begin
                            o_alu_ctrl = 4'h08;
                            o_shamt_ctrl = 1'b1; // Elige data_a
                            o_last_register_ctrl = 1'b0;
                        end
                        `SLT_FCODE   : begin
                            o_alu_ctrl = 4'h09;
                            o_shamt_ctrl = 1'b1; // Elige data_a
                            o_last_register_ctrl = 1'b0;
                        end
                        `JALR_FCODE  : begin
                            o_alu_ctrl = 4'h00;
                            o_shamt_ctrl = 1'b0;
                            o_last_register_ctrl = 1'b1;
                        end
                        default     : begin
                            o_alu_ctrl = o_alu_ctrl;
                            o_shamt_ctrl = o_shamt_ctrl;
                            o_last_register_ctrl = o_last_register_ctrl;
                        end                      
                endcase
            end       
            `LB_OPCODE   : begin
                o_alu_ctrl = 4'h03;  // INSTRUCCION ITYPE - ADDI -> ADD de ALU
                o_shamt_ctrl = 1'b1; // Elige data_a
                o_last_register_ctrl = 1'b0;
            end
            `LH_OPCODE   : begin
                o_alu_ctrl = 4'h03;
                o_shamt_ctrl = 1'b1; // Elige data_a
                o_last_register_ctrl = 1'b0;
            end
            `LW_OPCODE   : begin
                o_alu_ctrl = 4'h03;
                o_shamt_ctrl = 1'b1; // Elige data_a
                o_last_register_ctrl = 1'b0;
            end
            `LWU_OPCODE  : begin
                o_alu_ctrl = 4'h03;
                o_shamt_ctrl = 1'b1; // Elige data_a
                o_last_register_ctrl = 1'b0;
            end
            `LBU_OPCODE  : begin
                o_alu_ctrl = 4'h03;
                o_shamt_ctrl = 1'b1; // Elige data_a
                o_last_register_ctrl = 1'b0;
            end
            `LHU_OPCODE  : begin
                o_alu_ctrl = 4'h03;
                o_shamt_ctrl = 1'b1; // Elige data_a
                o_last_register_ctrl = 1'b0;
            end
            `SB_OPCODE   : begin
                o_alu_ctrl = 4'h03;
                o_shamt_ctrl = 1'b1; // Elige data_a
                o_last_register_ctrl = 1'b0;
            end
            `SH_OPCODE   : begin
                o_alu_ctrl = 4'h03;
                o_shamt_ctrl = 1'b1; // Elige data_a
                o_last_register_ctrl = 1'b0;
            end
            `SW_OPCODE   : begin
                o_alu_ctrl = 4'h03;
                o_shamt_ctrl = 1'b1; // Elige data_a
                o_last_register_ctrl = 1'b0;
            end
            `ADDI_OPCODE : begin
                o_alu_ctrl = 4'h03;
                o_shamt_ctrl = 1'b1; // Elige data_a
                o_last_register_ctrl = 1'b0;
            end
            `ANDI_OPCODE : begin
                o_alu_ctrl = 4'h05;
                o_shamt_ctrl = 1'b1; // Elige data_a
                o_last_register_ctrl = 1'b0;
            end
            `ORI_OPCODE  : begin
                o_alu_ctrl = 4'h06;
                o_shamt_ctrl = 1'b1; // Elige data_a
                o_last_register_ctrl = 1'b0;
            end
            `XORI_OPCODE : begin
                o_alu_ctrl = 4'h07;
                o_shamt_ctrl = 1'b1; // Elige data_a
                o_last_register_ctrl = 1'b0;
            end
            `LUI_OPCODE  : begin
                o_alu_ctrl = 4'h0a;
                o_shamt_ctrl = 1'b1; // Elige data_a
                o_last_register_ctrl = 1'b0;
            end
            `SLTI_OPCODE : begin
                o_alu_ctrl = 4'h09;
                o_shamt_ctrl = 1'b1; // Elige data_a
                o_last_register_ctrl = 1'b0;
            end
            `BEQ_OPCODE  : begin
                o_alu_ctrl = 4'h0b;
                o_shamt_ctrl = 1'b1; // Elige data_a
                o_last_register_ctrl = 1'b0;
            end
            `BNE_OPCODE  : begin
                o_alu_ctrl = 4'h0c;
                o_shamt_ctrl = 1'b1; // Elige data_a
                o_last_register_ctrl = 1'b0;
            end
            `JAL_OPCODE  : begin
                o_alu_ctrl = 4'h00;
                o_shamt_ctrl = 1'b1;
                o_last_register_ctrl = 1'b1;
            end
            default     : begin
                o_alu_ctrl = o_alu_ctrl;
                o_shamt_ctrl = o_shamt_ctrl;
                o_last_register_ctrl = o_last_register_ctrl;
            end
        endcase
    end
    
endmodule