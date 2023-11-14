`timescale 1ns / 1ps

module ID_EX_reg#(
        parameter NB_ALU_OP   = 6,
        parameter NB_IMM      = 32,
        parameter NB_PC       = 32,
        parameter NB_DATA     = 32,
        parameter NB_REG      = 5
    )
    (
        input                    i_clock,
        input                    i_reset,
        input                    i_pipeline_enable,
        input                    i_signed,
        input                    i_reg_write,
        input                    i_mem_to_reg,
        input                    i_mem_read,
        input                    i_mem_write,
        input                    i_branch,
        input                    i_alu_src,
        input                    i_reg_dest,
        input  [NB_ALU_OP-1:0]   i_alu_op,
        input  [NB_PC-1:0]       i_pc,
        input  [NB_DATA-1:0]     i_data_a,
        input  [NB_DATA-1:0]     i_data_b,
        input  [NB_IMM-1:0]      i_immediate,
        input  [NB_DATA-1:0]     i_shamt,
        input  [NB_REG-1:0]      i_rt,
        input  [NB_REG-1:0]      i_rd,
        input  [NB_REG-1:0]      i_rs,
        input                    i_byte_enable,
        input                    i_halfword_enable,
        input                    i_word_enable,
        input                    i_halt,
        input                    i_jump,
        input                    i_jr_jalr,
        
        output                   o_signed,
        output                   o_reg_write,
        output                   o_mem_to_reg,
        output                   o_mem_read,
        output                   o_mem_write,
        output                   o_branch,
        output                   o_alu_src,
        output                   o_reg_dest,
        output [NB_ALU_OP-1:0]   o_alu_op,
        output [NB_PC-1:0]       o_pc,
        output [NB_DATA-1:0]     o_data_a,
        output [NB_DATA-1:0]     o_data_b,
        output [NB_IMM-1:0]      o_immediate,
        output [NB_DATA-1:0]     o_shamt,
        output [NB_REG-1:0]      o_rt,
        output [NB_REG-1:0]      o_rd,
        output [NB_REG-1:0]      o_rs,
        output                   o_byte_enable,
        output                   o_halfword_enable,
        output                   o_word_enable,
        output                   o_halt,
        output                   o_jump,
        output                   o_jr_jalr
    );
    
    reg                 signed_flag;
    reg                 reg_write;
    reg                 mem_to_reg;
    reg                 mem_read;
    reg                 mem_write;
    reg                 branch;
    reg                 alu_src;
    reg                 reg_dest;
    reg [NB_ALU_OP-1:0] alu_op;
    reg [NB_PC-1:0]     pc;
    reg [NB_DATA-1:0]   data_a;
    reg [NB_DATA-1:0]   data_b;
    reg [NB_IMM-1:0]    immediate;
    reg [NB_DATA-1:0]   shamt;
    reg [NB_REG-1:0]    rt;
    reg [NB_REG-1:0]    rd;
    reg [NB_REG-1:0]    rs;
    reg                 byte_enable;
    reg                 halfword_enable;
    reg                 word_enable;
    reg                 halt;
    reg                 jump;
    reg                 jr_jalr;

    always @(negedge i_clock) begin
        if(i_reset) begin
            signed_flag         <= 1'b0;
            reg_write           <= 1'b0;
            mem_to_reg          <= 1'b0;
            mem_read            <= 1'b0;
            mem_write           <= 1'b0;
            branch              <= 1'b0;
            alu_src             <= 1'b0;
            reg_dest            <= 1'b0;
            alu_op              <= 6'b0;
            pc                  <= 32'b0;
            data_a              <= 32'b0;
            data_b              <= 32'b0;
            immediate           <= 32'b0;
            shamt               <= 32'b0;
            rt                  <= 5'b0;
            rd                  <= 5'b0;
            rs                  <= 5'b0;
            byte_enable         <= 1'b0;
            halfword_enable     <= 1'b0;
            word_enable         <= 1'b0;
            halt                <= 1'b0;
            jump                <= 1'b0;
            jr_jalr             <= 1'b0;
        end
        else begin
            if(i_pipeline_enable) begin
                signed_flag         <= i_signed;
                reg_write           <= i_reg_write;
                mem_to_reg          <= i_mem_to_reg;
                mem_read            <= i_mem_read;
                mem_write           <= i_mem_write;
                branch              <= i_branch;
                alu_src             <= i_alu_src;
                reg_dest            <= i_reg_dest;
                alu_op              <= i_alu_op;
                pc                  <= i_pc;
                data_a              <= i_data_a;
                data_b              <= i_data_b;
                immediate           <= i_immediate;
                shamt               <= i_shamt;
                rt                  <= i_rt;
                rd                  <= i_rd;
                rs                  <= i_rs;
                byte_enable         <= i_byte_enable;
                halfword_enable     <= i_halfword_enable;
                word_enable         <= i_word_enable;
                halt                <= i_halt;
                jump                <= i_jump;
                jr_jalr             <= i_jr_jalr;
            end
            else begin
                signed_flag         <= signed_flag;
                reg_write           <= reg_write;
                mem_to_reg          <= mem_to_reg;
                mem_read            <= mem_read;
                mem_write           <= mem_write;
                branch              <= branch;
                alu_src             <= alu_src;
                reg_dest            <= reg_dest;
                alu_op              <= alu_op;
                pc                  <= pc;
                data_a              <= data_a;
                data_b              <= data_b;
                immediate           <= immediate;
                shamt               <= shamt;
                rt                  <= rt;
                rd                  <= rd;
                rs                  <= rs;
                byte_enable         <= byte_enable;
                halfword_enable     <= halfword_enable;
                word_enable         <= word_enable;
                halt                <= halt;
                jump                <= jump;
                jr_jalr             <= jr_jalr;
            end
        end
    end

    assign o_signed             = signed_flag;
    assign o_reg_write          = reg_write;
    assign o_mem_to_reg         = mem_to_reg;
    assign o_mem_read           = mem_read;
    assign o_mem_write          = mem_write;
    assign o_branch             = branch;
    assign o_alu_src            = alu_src;
    assign o_reg_dest           = reg_dest;
    assign o_alu_op             = alu_op;
    assign o_pc                 = pc;
    assign o_data_a             = data_a;
    assign o_data_b             = data_b;
    assign o_immediate          = immediate;
    assign o_shamt              = shamt;
    assign o_rt                 = rt;
    assign o_rd                 = rd;
    assign o_rs                 = rs;
    assign o_byte_enable        = byte_enable;
    assign o_halfword_enable    = halfword_enable;
    assign o_word_enable        = word_enable;
    assign o_halt               = halt;
    assign o_jump               = jump;
    assign o_jr_jalr            = jr_jalr;
    
endmodule
