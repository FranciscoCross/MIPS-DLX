`timescale 1ns / 1ps
`include "parameters.vh"

module unit_control#(
        parameter   NB_OPCODE       = 6,
        parameter   NB_FUNCT        = 6
    )
    (   input                       i_clock,
        input                       i_enable,
        input                       i_reset,        // Necesario para flush en controls hazard
        input [NB_OPCODE-1:0]       i_opcode,
        input [NB_FUNCT-1:0]        i_funct,
        input                       i_flush_unit_ctrl,     // from STALL UNIT
        
        output reg                  o_signed,
        output reg                  o_reg_dest,     // EX
        output reg [NB_OPCODE-1:0]  o_alu_op,       // EX REG?
        output reg                  o_alu_src,      // EX
        output reg                  o_mem_read,     // MEM
        output reg                  o_mem_write,    // MEM
        output reg                  o_branch,       // MEM
        output reg                  o_reg_write,    // WB
        output reg                  o_mem_to_reg,   // WB
        output reg                  o_jump,
        output reg                  o_byte_enable,
        output reg                  o_halfword_enable,
        output reg                  o_word_enable,
        output reg                  o_jr_jalr,      // Hacia register bank
        output reg                  o_halt           // END OF PROGRAM
    );

    always@(posedge i_clock) begin
        if(i_reset) begin
            o_alu_op            <= {NB_OPCODE{1'b0}};
            o_signed            <= 1'b0;
            o_reg_dest          <= 1'b0;
            o_alu_src           <= 1'b0;
            o_mem_read          <= 1'b0;
            o_mem_write         <= 1'b0;
            o_branch            <= 1'b0;
            o_reg_write         <= 1'b0;
            o_mem_to_reg        <= 1'b0;
            o_jump              <= 1'b0;
            o_jr_jalr           <= 1'b0;
            o_byte_enable       <= 1'b0;
            o_halfword_enable   <= 1'b0;
            o_word_enable       <= 1'b0;
            o_halt              <= 1'b0;
        end
        if(i_enable) begin
            if(!i_flush_unit_ctrl) begin
                o_alu_op <= i_opcode;
                case(i_opcode)
                    `RTYPE_OPCODE:begin
                        o_signed            <= 1'b0;
                        o_reg_dest          <= 1'b1; // rd
                        o_alu_src           <= 1'b0; // rt
                        o_mem_read          <= 1'b0; // no accede a mem
                        o_mem_write         <= 1'b0; // no accede a mem
                        o_branch            <= 1'b0; // no es branch
                        o_reg_write         <= 1'b1; // escribe en bank register
                        o_mem_to_reg        <= 1'b0; // read salida ALU
                        o_jump              <= 1'b0;
                        o_byte_enable       <= 1'b0;
                        o_halfword_enable   <= 1'b0;
                        o_word_enable       <= 1'b0;
                        o_halt              <= 1'b0;

                        if((i_funct == `JALR_FUNCT) || (i_funct == `JR_FUNCT)) begin
                            o_jr_jalr <= 1'b1; // Ambas escriben en el PC=$rs
                        end
                        else begin
                            o_jr_jalr <= 1'b0;
                        end

                    end
                    `BEQ_OPCODE, `BNE_OPCODE:begin
                        o_signed            <= 1'b0;
                        o_reg_dest          <= 1'b0; // X
                        o_alu_src           <= 1'b0; // rt
                        o_mem_read          <= 1'b0; // no accede a mem
                        o_mem_write         <= 1'b0; // no accede a mem
                        o_branch            <= 1'b1; // es branch
                        o_reg_write         <= 1'b0; // no escribe en bank register
                        o_mem_to_reg        <= 1'b0; // X
                        o_jump              <= 1'b0;
                        o_byte_enable       <= 1'b0;
                        o_halfword_enable   <= 1'b0;
                        o_word_enable       <= 1'b0;
                        o_jr_jalr           <= 1'b0;
                        o_halt              <= 1'b0;
                    end
                    `ADDI_OPCODE, `SLTI_OPCODE, `ANDI_OPCODE, `ORI_OPCODE, `XORI_OPCODE, `LUI_OPCODE:begin
                        o_signed            <= 1'b0;
                        o_reg_dest          <= 1'b0; // rt
                        o_alu_src           <= 1'b1; // immediate
                        o_mem_read          <= 1'b0; // no accede a mem
                        o_mem_write         <= 1'b0; // no accede a mem
                        o_branch            <= 1'b0; // no es branch
                        o_reg_write         <= 1'b1; // escribe en bank register
                        o_mem_to_reg        <= 1'b0; // read salida ALU
                        o_jump              <= 1'b0;
                        o_byte_enable       <= 1'b0;
                        o_halfword_enable   <= 1'b0;
                        o_word_enable       <= 1'b0;
                        o_jr_jalr           <= 1'b0;
                        o_halt              <= 1'b0;
                    end
                    `LB_OPCODE:begin
                        o_signed            <= 1'b1;
                        o_reg_dest          <= 1'b0; // rt
                        o_alu_src           <= 1'b1; // immediate
                        o_mem_read          <= 1'b1; // read mem
                        o_mem_write         <= 1'b0; // no write mem
                        o_branch            <= 1'b0; // no es branch
                        o_reg_write         <= 1'b1; // escribe en rt
                        o_mem_to_reg        <= 1'b1; // read salida data memory
                        o_jump              <= 1'b0;
                        o_byte_enable       <= 1'b1;
                        o_halfword_enable   <= 1'b0;
                        o_word_enable       <= 1'b0;
                        o_jr_jalr           <= 1'b0;
                        o_halt              <= 1'b0;
                    end
                    `LH_OPCODE:begin
                        o_signed            <= 1'b1;
                        o_reg_dest          <= 1'b0; // rt
                        o_alu_src           <= 1'b1; // immediate
                        o_mem_read          <= 1'b1; // read mem
                        o_mem_write         <= 1'b0; // no write mem
                        o_branch            <= 1'b0; // no es branch
                        o_reg_write         <= 1'b1; // escribe en rt
                        o_mem_to_reg        <= 1'b1; // read salida data memory
                        o_jump              <= 1'b0;
                        o_byte_enable       <= 1'b0;
                        o_halfword_enable   <= 1'b1;
                        o_word_enable       <= 1'b0;
                        o_jr_jalr           <= 1'b0;
                        o_halt              <= 1'b0;
                    end
                    `LHU_OPCODE:begin
                        o_signed            <= 1'b0;
                        o_reg_dest          <= 1'b0; // rt
                        o_alu_src           <= 1'b1; // immediate
                        o_mem_read          <= 1'b1; // read mem
                        o_mem_write         <= 1'b0; // no write mem
                        o_branch            <= 1'b0; // no es branch
                        o_reg_write         <= 1'b1; // escribe en rt
                        o_mem_to_reg        <= 1'b1; // read salida data memory
                        o_jump              <= 1'b0;
                        o_byte_enable       <= 1'b0;
                        o_halfword_enable   <= 1'b1;
                        o_word_enable       <= 1'b0;
                        o_jr_jalr           <= 1'b0;
                        o_halt              <= 1'b0;
                    end
                    `LW_OPCODE:begin
                        o_signed            <= 1'b1;
                        o_reg_dest          <= 1'b0; // rt
                        o_alu_src           <= 1'b1; // immediate
                        o_mem_read          <= 1'b1; // read mem
                        o_mem_write         <= 1'b0; // no write mem
                        o_branch            <= 1'b0; // no es branch
                        o_reg_write         <= 1'b1; // escribe en rt
                        o_mem_to_reg        <= 1'b1; // read salida data memory
                        o_jump              <= 1'b0;
                        o_byte_enable       <= 1'b0;
                        o_halfword_enable   <= 1'b0;
                        o_word_enable       <= 1'b1;
                        o_jr_jalr           <= 1'b0;
                        o_halt              <= 1'b0;
                    end
                    `LWU_OPCODE:begin
                        o_signed            <= 1'b0;
                        o_reg_dest          <= 1'b0; // rt
                        o_alu_src           <= 1'b1; // immediate
                        o_mem_read          <= 1'b1; // read mem
                        o_mem_write         <= 1'b0; // no write mem
                        o_branch            <= 1'b0; // no es branch
                        o_reg_write         <= 1'b1; // escribe en rt
                        o_mem_to_reg        <= 1'b1; // read salida data memory
                        o_jump              <= 1'b0;
                        o_byte_enable       <= 1'b0;
                        o_halfword_enable   <= 1'b0;
                        o_word_enable       <= 1'b1;
                        o_jr_jalr           <= 1'b0;
                        o_halt              <= 1'b0;
                    end
                    `LBU_OPCODE:begin
                        o_signed            <= 1'b0;
                        o_reg_dest          <= 1'b0; // rt
                        o_alu_src           <= 1'b1; // immediate
                        o_mem_read          <= 1'b1; // read mem
                        o_mem_write         <= 1'b0; // no write mem
                        o_branch            <= 1'b0; // no es branch
                        o_reg_write         <= 1'b1; // escribe en rt
                        o_mem_to_reg        <= 1'b1; // read salida data memory
                        o_jump              <= 1'b0;
                        o_byte_enable       <= 1'b1;
                        o_halfword_enable   <= 1'b0;
                        o_word_enable       <= 1'b0;
                        o_jr_jalr           <= 1'b0;
                        o_halt              <= 1'b0;
                    end
                    `SB_OPCODE:begin
                        o_signed            <= 1'b0;
                        o_reg_dest          <= 1'b0; // rt
                        o_alu_src           <= 1'b1; // immediate
                        o_mem_read          <= 1'b0; // no read mem
                        o_mem_write         <= 1'b1; // write mem
                        o_branch            <= 1'b0; // no es branch
                        o_reg_write         <= 1'b0; // escribe en rt
                        o_mem_to_reg        <= 1'b0; // X
                        o_jump              <= 1'b0;
                        o_byte_enable       <= 1'b1;
                        o_halfword_enable   <= 1'b0;
                        o_word_enable       <= 1'b0;
                        o_jr_jalr           <= 1'b0;
                        o_halt              <= 1'b0;
                    end
                    `SH_OPCODE:begin
                        o_signed            <= 1'b0;
                        o_reg_dest          <= 1'b0; // rt
                        o_alu_src           <= 1'b1; // immediate
                        o_mem_read          <= 1'b0; // no read mem
                        o_mem_write         <= 1'b1; // write mem
                        o_branch            <= 1'b0; // no es branch
                        o_reg_write         <= 1'b0; // escribe en rt
                        o_mem_to_reg        <= 1'b0; // X
                        o_jump              <= 1'b0;
                        o_byte_enable       <= 1'b0;
                        o_halfword_enable   <= 1'b1;
                        o_word_enable       <= 1'b0;
                        o_jr_jalr           <= 1'b0;
                        o_halt              <= 1'b0;
                    end
                    `SW_OPCODE:begin
                        o_signed            <= 1'b0;
                        o_reg_dest          <= 1'b0; // rt
                        o_alu_src           <= 1'b1; // immediate
                        o_mem_read          <= 1'b0; // no read mem
                        o_mem_write         <= 1'b1; // write mem
                        o_branch            <= 1'b0; // no es branch
                        o_reg_write         <= 1'b0; // escribe en rt
                        o_mem_to_reg        <= 1'b0; // X
                        o_jump              <= 1'b0;
                        o_byte_enable       <= 1'b0;
                        o_halfword_enable   <= 1'b0;
                        o_word_enable       <= 1'b1;
                        o_jr_jalr           <= 1'b0;
                        o_halt              <= 1'b0;
                    end
                    `J_OPCODE:begin
                        o_signed            <= 1'b0;
                        o_reg_dest          <= 1'b0; // rt
                        o_alu_src           <= 1'b0; // immediate
                        o_mem_read          <= 1'b0; // no read mem
                        o_mem_write         <= 1'b0; // no write mem
                        o_branch            <= 1'b0; // no es branch
                        o_reg_write         <= 1'b0; // escribe en rt
                        o_mem_to_reg        <= 1'b0; // X
                        o_jump              <= 1'b1;
                        o_byte_enable       <= 1'b0;
                        o_halfword_enable   <= 1'b0;
                        o_word_enable       <= 1'b0;
                        o_jr_jalr           <= 1'b0;
                        o_halt              <= 1'b0;
                    end
                    `JAL_OPCODE:begin
                        o_signed            <= 1'b0;
                        o_reg_dest          <= 1'b0; // rt
                        o_alu_src           <= 1'b0; // immediate
                        o_mem_read          <= 1'b0; // no read mem
                        o_mem_write         <= 1'b0; // no write mem
                        o_branch            <= 1'b0; // no es branch
                        o_reg_write         <= 1'b1; // escribe en rt
                        o_mem_to_reg        <= 1'b0; // X
                        o_jump              <= 1'b1; // TODO: ver si se necesta señal que haga $ra=PC+1
                        o_byte_enable       <= 1'b0;
                        o_halfword_enable   <= 1'b0;
                        o_word_enable       <= 1'b0;
                        o_jr_jalr           <= 1'b0;
                        o_halt              <= 1'b0;
                    end
                    `HALT_OPCODE:begin
                        o_signed            <= 1'b0;
                        o_reg_dest          <= 1'b0; // rt
                        o_alu_src           <= 1'b0; // immediate
                        o_mem_read          <= 1'b0; // no read mem
                        o_mem_write         <= 1'b0; // no write mem
                        o_branch            <= 1'b0; // no es branch
                        o_reg_write         <= 1'b0; // escribe en rt
                        o_mem_to_reg        <= 1'b0; // X
                        o_jump              <= 1'b0; // dont jump
                        o_byte_enable       <= 1'b0;
                        o_halfword_enable   <= 1'b0;
                        o_word_enable       <= 1'b0;
                        o_jr_jalr           <= 1'b0;
                        o_halt              <= 1'b1; // END OF PROGRAM
                    end
                    default: begin
                        o_signed            <= 1'b0;
                        o_reg_dest          <= 1'b0; // rt
                        o_alu_src           <= 1'b0; // immediate
                        o_mem_read          <= 1'b0; // no read mem
                        o_mem_write         <= 1'b0; // no write mem
                        o_branch            <= 1'b0; // no es branch
                        o_reg_write         <= 1'b0; // escribe en rt
                        o_mem_to_reg        <= 1'b0; // X
                        o_jump              <= 1'b0; // dont jump
                        o_byte_enable       <= 1'b0;
                        o_halfword_enable   <= 1'b0;
                        o_word_enable       <= 1'b0;
                        o_jr_jalr           <= 1'b0;
                        o_halt              <= 1'b0; // END OF PROGRAM
                    end
                endcase
            end
            else begin
                    // flush from UNIT STALL
                    o_signed            <= 1'b0;
                    o_reg_dest          <= 1'b0; // rt
                    o_alu_src           <= 1'b0; // immediate
                    o_mem_read          <= 1'b0; // no read mem
                    o_mem_write         <= 1'b0; // no write mem
                    o_branch            <= 1'b0; // no es branch
                    o_reg_write         <= 1'b0; // escribe en rt
                    o_mem_to_reg        <= 1'b0; // X
                    o_jump              <= 1'b0; // dont jump
                    o_byte_enable       <= 1'b0;
                    o_halfword_enable   <= 1'b0;
                    o_word_enable       <= 1'b0;
                    o_jr_jalr           <= 1'b0;
                    o_halt              <= 1'b0; // END OF PROGRAM
            end
        end
    end
endmodule
    