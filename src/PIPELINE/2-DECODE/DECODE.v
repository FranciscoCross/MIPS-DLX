`timescale 1ns / 1ps
`include "parameters.vh"
module DECODE#(
        parameter NB_PC_CONSTANT    = 3,
        parameter NB_INST           = 32,
        parameter NB_PC             = 32,
        parameter NB_DATA           = 32,
        parameter NB_REG            = 5, 
        parameter NB_OPCODE         = 6
    )
    (
        input                       i_clock,
        input                       i_pipeline_enable,
        input                       i_reset,
        input                       i_unit_control_enable,      // Debug Unit
        input                       i_rb_enable,                // Debug Unit
        input                       i_rb_read_enable,           // Debug Unit
        input [NB_REG-1:0]          i_rb_read_addr,             // Debug Unit
        input [NB_INST-1:0]         i_inst,
        input [NB_PC-1:0]           i_pc,
        input [NB_DATA-1:0]         i_write_data,               // from WB, data to write
        input [NB_REG-1:0]          i_write_reg,                // from WB, addr to write
        input                       i_reg_write,                // from unit_control, en write reg
        input                       i_flush_unit_ctrl,
        
        output                      o_signed,
        output                      o_reg_dest,                 // EX, signal
        output [NB_OPCODE-1:0]      o_alu_op,                   // EX, signal
        output                      o_alu_src,                  // EX, signal
        output                      o_mem_read,                 // MEM, signal
        output                      o_mem_write,                // MEM, signal
        output                      o_branch,                   // MEM, signal
        output                      o_reg_write,                // WB, signal
        output                      o_mem_to_reg,               // WB, signal
        output                      o_jump,                     // DECODE, signal
        output                      o_halt,
        output                      o_jr_jalr,                  // FETCH
        output [NB_PC-1:0]          o_jump_addr,  
        output [NB_DATA-1:0]        o_data_a,
        output [NB_DATA-1:0]        o_data_b,
        output [NB_PC-1:0]          o_immediate,                // immediate 32b / function code
        output [NB_DATA-1:0]        o_shamt,
        output [NB_REG-1:0]         o_rt,
        output [NB_REG-1:0]         o_rd,
        output [NB_REG-1:0]         o_rs,
        output [NB_PC-1:0]          o_pc,
        output                      o_byte_enable,
        output                      o_halfword_enable,
        output                      o_word_enable
    );

    wire                jr_jalr; // Para que register bank lea el last_register

    bank_register bank_register
    (
        .i_clock(i_clock),
        .i_enable(i_rb_enable),             // Debug Unit
        .i_read_enable(i_rb_read_enable),   // Debug Unit
        .i_read_addr(i_rb_read_addr),       // Debug Unit
        .i_reset(i_reset),
        .i_reg_write(i_reg_write),          // Señal de control RegWrite proveniente de WB
        .i_read_reg_a(i_inst[25:21]),
        .i_read_reg_b(i_inst[20:16]), 
        .i_write_reg(i_write_reg),          // addr 5b
        .i_write_data(i_write_data),        // Data 32b
        .o_data_a(o_data_a),
        .o_data_b(o_data_b)
    );


    unit_control unit_control
    (
        .i_clock(i_clock),
        .i_enable(i_unit_control_enable),           // Debug Unit
        .i_reset(i_reset),                          // Necesario para flush en controls hazard
        .i_opcode(i_inst[31:26]),
        .i_funct(i_inst[5:0]),
        .i_flush_unit_ctrl(i_flush_unit_ctrl),      // STALL UNIT: 0 -> señales normales 1 -> flush
        .o_reg_dest(o_reg_dest),                    // EX
        .o_signed(o_signed),
        .o_alu_op(o_alu_op),                        // EX REG?
        .o_alu_src(o_alu_src),                      // EX
        .o_mem_read(o_mem_read),                    // MEM
        .o_mem_write(o_mem_write),                  // MEM
        .o_branch(o_branch),                        // MEM
        .o_reg_write(o_reg_write),                  // WB
        .o_mem_to_reg(o_mem_to_reg),                // WB
        .o_jump(o_jump),
        .o_byte_enable(o_byte_enable),
        .o_halfword_enable(o_halfword_enable),
        .o_word_enable(o_word_enable),
        .o_jr_jalr(jr_jalr),             // FETCH
        .o_halt(o_halt)
    );

    ext_sign ext_sign
    (
        .i_data(i_inst[15:0]),
        .o_data(o_immediate)
    );
    
    extend extend(.i_data(i_inst[10:6]),
                  .o_data(o_shamt));

    concat_module concat_module
    (
        .i_clock(i_clock),
        .i_reset(i_reset),
        .i_enable(i_pipeline_enable),
        .i_inst(i_inst[25:0]),                           
        .i_next_pc(i_pc[31:28]),          // PC+1[31:28]                
        .o_jump_addr(o_jump_addr)
    );
    
    // TODO: Agregar wires intermedios
    assign o_rd = i_inst[15:11];
    assign o_rt = i_inst[20:16];
    assign o_rs = i_inst[25:21];
    assign o_pc = i_pc;
    assign o_jr_jalr = jr_jalr;

endmodule 