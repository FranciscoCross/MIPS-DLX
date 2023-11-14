`timescale 1ns / 1ps

module EX_MEM_reg#(
        parameter NB_PC       = 32,
        parameter NB_REG      = 5
    )
    (
        input                   i_clock,
        input                   i_reset,
        input                   i_pipeline_enable, // DEBUG UNIT
        input                   i_flush,           // UNIT STALL:  1 -> Flush control signals 0 -> !flush
        input                   i_signed,
        input                   i_reg_write,
        input                   i_mem_to_reg,
        input                   i_mem_read,
        input                   i_mem_write,
        input                   i_branch,
        input [NB_PC-1:0]       i_branch_addr,
        input                   i_zero,
        input [NB_PC-1:0]       i_alu_result,
        input [NB_PC-1:0]       i_data_b,
        input [NB_REG-1:0]      i_selected_reg,
        input                   i_byte_enable,
        input                   i_halfword_enable,
        input                   i_word_enable,
        input                   i_last_register_ctrl,
        input [NB_PC-1:0]       i_pc,
        input                   i_halt,
        input                   i_jump,
        input                   i_jr_jalr,

        output                  o_signed,
        output                  o_reg_write,
        output                  o_mem_to_reg,
        output                  o_mem_read,
        output                  o_mem_write,
        output                  o_branch,
        output [NB_PC-1:0]      o_branch_addr,
        output                  o_zero,
        output [NB_PC-1:0]      o_alu_result,
        output [NB_PC-1:0]      o_data_b,
        output [NB_REG-1:0]     o_selected_reg,
        output                  o_byte_enable,
        output                  o_halfword_enable,
        output                  o_word_enable,
        output                  o_last_register_ctrl,
        output [NB_PC-1:0]      o_pc,
        output                  o_halt,
        output                  o_jump,
        output                  o_jr_jalr
    );
    
    reg                 signed_flag;
    reg                 reg_write;
    reg                 mem_to_reg;
    reg                 mem_read;
    reg                 mem_write;
    reg                 branch;
    reg [NB_PC-1:0]     branch_addr;
    reg                 zero;
    reg [NB_PC-1:0]     alu_result;
    reg [NB_PC-1:0]     data_b;
    reg [NB_REG-1:0]    selected_reg;
    reg                 byte_enable;
    reg                 halfword_enable;
    reg                 word_enable;
    reg                 last_register_ctrl;
    reg [NB_PC-1:0]     pc;  
    reg                 halt;
    reg                 jump;
    reg                 jr_jalr;

    always @(negedge i_clock) begin
        if(i_reset) begin
            signed_flag             <= 1'b0;
            reg_write               <= 1'b0;
            mem_to_reg              <= 1'b0;
            mem_read                <= 1'b0;
            mem_write               <= 1'b0;
            branch                  <= 1'b0;
            branch_addr             <= 32'b0;
            zero                    <= 1'b0;
            alu_result              <= 32'b0;
            data_b                  <= 32'b0;
            selected_reg            <= 5'b0;
            byte_enable             <= 1'b0;
            halfword_enable         <= 1'b0;
            word_enable             <= 1'b0;
            last_register_ctrl      <= 1'b0;
            pc                      <= 32'b0;
            halt                    <= 1'b0;
            jump                    <= 1'b0;
            jr_jalr                 <= 1'b0;
        end
        else begin
            if(i_pipeline_enable) begin
                if(i_flush)begin
                    signed_flag             <= 1'b0;
                    reg_write               <= 1'b0;
                    mem_to_reg              <= 1'b0;
                    mem_read                <= 1'b0;
                    mem_write               <= 1'b0;
                    branch                  <= 1'b0;
                    branch_addr             <= i_branch_addr;
                    zero                    <= 1'b0;
                    alu_result              <= i_alu_result;
                    data_b                  <= i_data_b;
                    selected_reg            <= i_selected_reg;
                    byte_enable             <= 1'b0;
                    halfword_enable         <= 1'b0;
                    word_enable             <= 1'b0;
                    last_register_ctrl      <= 1'b0;
                    pc                      <= i_pc;
                    halt                    <= 1'b0;
                    jump                    <= 1'b0;
                    jr_jalr                 <= 1'b0;
                end
                else begin
                    signed_flag             <= i_signed;
                    reg_write               <= i_reg_write;
                    mem_to_reg              <= i_mem_to_reg;
                    mem_read                <= i_mem_read;
                    mem_write               <= i_mem_write;
                    branch                  <= i_branch;
                    branch_addr             <= i_branch_addr;
                    zero                    <= i_zero;
                    alu_result              <= i_alu_result;
                    data_b                  <= i_data_b;
                    selected_reg            <= i_selected_reg;
                    byte_enable             <= i_byte_enable;
                    halfword_enable         <= i_halfword_enable;
                    word_enable             <= i_word_enable;
                    last_register_ctrl      <= i_last_register_ctrl;
                    pc                      <= i_pc;
                    halt                    <= i_halt;
                    jump                    <= i_jump;
                    jr_jalr                 <= i_jr_jalr;
                end
            end
            else begin
                signed_flag             <= signed_flag;
                reg_write               <= reg_write;
                mem_to_reg              <= mem_to_reg;
                mem_read                <= mem_read;
                mem_write               <= mem_write;
                branch                  <= branch;
                branch_addr             <= branch_addr;
                zero                    <= zero;
                alu_result              <= alu_result;
                data_b                  <= data_b;
                selected_reg            <= selected_reg;
                byte_enable             <= byte_enable;
                halfword_enable         <= halfword_enable;
                word_enable             <= word_enable;
                last_register_ctrl      <= last_register_ctrl;
                pc                      <= pc;
                halt                    <= halt;
                jump                    <= jump;
                jr_jalr                 <= jr_jalr;
            end
        end
    end

    assign o_signed                 = signed_flag;
    assign o_reg_write              = reg_write;
    assign o_mem_to_reg             = mem_to_reg;
    assign o_mem_read               = mem_read;
    assign o_mem_write              = mem_write;
    assign o_branch                 = branch;
    assign o_branch_addr            = branch_addr;
    assign o_zero                   = zero;
    assign o_alu_result             = alu_result;
    assign o_data_b                 = data_b;
    assign o_selected_reg           = selected_reg;
    assign o_byte_enable            = byte_enable;
    assign o_halfword_enable        = halfword_enable;
    assign o_word_enable            = word_enable;
    assign o_last_register_ctrl     = last_register_ctrl;
    assign o_pc                     = pc;
    assign o_halt                   = halt;
    assign o_jump                   = jump;
    assign o_jr_jalr                = jr_jalr;
    
endmodule
