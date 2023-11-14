`timescale 1ns / 1ps

module MEMORY#(
        parameter NB_ADDR       = 32,
        parameter NB_DATA       = 32,
        parameter NB_PC         = 32,
        parameter NB_MEM_ADDR   = 5,
        parameter MEMORY_WIDTH  = 32,
        parameter NB_REG        = 5
    )
    (
        input                       i_clock,
        input                       i_debug_unit_flag,          // Flag de read y addr para DEBUG UNIT
        input                       i_signed,                   // Indica si es signado o no
        input                       i_memory_data_enable,       // Enable Mem data          DEBUG UNIT
        input                       i_memory_data_read_enable,  // Enable Memory Read       DEBUG UNIT
        input [NB_MEM_ADDR-1:0]     i_memory_data_read_addr,    // Addr for data to read    DEBUG UNIT
        input                       i_reg_write,                // WB for write register
        input                       i_mem_to_reg,               // WB for mem to reg
        input                       i_mem_read,                 // read data memory flag
        input                       i_mem_write,                // write data memory flag
        input                       i_complete_word,              // Indica si es completa la palabra 32 bits
        input                       i_halfword_enable,          // Indica si es media palabra 16 bits
        input                       i_byte_enable,              // Indica que es solo 8 bits
        input                       i_branch,                   // branch 
        input                       i_zero,                     // zero flag 
        input [NB_PC-1:0]           i_branch_addr,              // addr for branch
        input [NB_ADDR-1:0]         i_alu_result,               // alu result
        input [NB_DATA-1:0]         i_write_data,               // data to write in data memory 
        input [NB_REG-1:0]          i_selected_reg,             // WB register RD or RT
        input                       i_last_register_ctrl,       // Cuando se usa el ultimo REG para almacenar la direccion o PC
        input [NB_PC-1:0]           i_pc,
        input                       i_halt,

        output [NB_DATA-1:0]        o_mem_data,                 // to REG BANK or DEBUG UNIT
        output [NB_DATA-1:0]        o_read_dm,
        output [NB_REG-1:0]         o_selected_reg,             // WB register (rd or rt)
        output [NB_ADDR-1:0]        o_alu_result,               // only for R type and stores (never loads)
        output [NB_PC-1:0]          o_branch_addr,              // PC = o_branch_addr
        output                      o_branch_zero,              // FETCH mux selector
        output                      o_reg_write,                // WB stage flag
        output                      o_mem_to_reg,               // WB stage flag
        output                      o_last_register_ctrl,
        output [NB_PC-1:0]          o_pc,
        output                      o_halt);

    wire [NB_DATA-1:0]      write_data;
    wire [NB_DATA-1:0]      read_data;

    wire [NB_MEM_ADDR-1:0]   addr;
    wire                     mem_read;
    wire                     mem_write;

    select_mode select_mode
    (
        .i_debug_unit_flag(i_debug_unit_flag),
        .i_memory_data_read_enable(i_memory_data_read_enable),
        .i_memory_data_read_addr(i_memory_data_read_addr),
        .i_mem_read(i_mem_read),
        .i_mem_write(i_mem_write),
        .i_alu_result(i_alu_result[NB_MEM_ADDR-1:0]),

        .o_addr(addr),
        .o_mem_read(mem_read),
        .o_mem_write(mem_write)
    );

    mem_controller mem_controller
    (
        .i_signed(i_signed),
        .i_write(mem_write),
        .i_read(mem_read),
        .i_word_size({i_complete_word,i_halfword_enable,i_byte_enable}),
        .i_write_data(i_write_data),
        .i_read_data(read_data),       // from MEM to reg/debug
        
        .o_write_data(write_data),     // write to MEM
        .o_read_data(o_mem_data)
    ); 

    mem_data mem_data
    (
        .i_clock(i_clock),
        .i_enable(i_memory_data_enable),
        .i_write(mem_write),
        .i_read(mem_read),
        .i_read_addr(addr),
        .i_write_data(write_data),
        
        .o_read_data(read_data)
    ); 
    
    // FETCH
    assign o_branch_zero = i_zero & i_branch;
    assign o_branch_addr = i_branch_addr;

    // WB
    assign o_alu_result             = i_alu_result;
    assign o_selected_reg           = i_selected_reg; 
    assign o_reg_write              = i_reg_write;
    assign o_mem_to_reg             = i_mem_to_reg;
    assign o_last_register_ctrl     = i_last_register_ctrl;
    assign o_pc                     = i_pc;
    assign o_halt                   = i_halt;

    // DEBUG UNIT
    assign o_read_dm        = read_data;

endmodule