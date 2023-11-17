`timescale 1ns / 1ps

module TOP_for_debug#(
        parameter BYTE          = 8,
        parameter DWORD         = 32,
        parameter ADDR          = 5,
        parameter NB_MEM_DEPTH  = 8,
        parameter RB_ADDR       = 5,
        parameter NB_STATE      = 10
    )
    (
        input                 i_clock,
        input                 i_reset,
        input                 i_clock_reset,
        input                 i_rx_done,
        input                 i_tx_done,
        input   [BYTE-1:0]    i_rx_data,

        output                o_halt,
        output [NB_STATE-1:0] o_state,
        output [BYTE-1:0]     o_tx_data,
        output                o_tx_start
    );

   wire clk_wiz;
    
   clk_wiz_0 clk_wizard
     (
     .clk_out1(clk_wiz),
     .reset(i_clock_reset), 
     .locked(),
     .clk_in1(i_clock)
     );


    wire                step_flag;
    wire                halt;
    wire                mem_enable;
    wire                read_memory_data_from_du;
    wire                mem_read_enable;
    wire [DWORD-1:0]    mem_data;
    wire [ADDR-1:0]     mem_addr;
    wire                rb_enable;
    wire                rb_read_enable;
    wire [DWORD-1:0]    rb_data;
    wire [RB_ADDR-1:0]  rb_addr;
    wire                im_enable;
    wire                im_write_enable;
    wire                im_read_enable;
    wire [BYTE-1:0]     im_addr;
    wire [BYTE-1:0]     im_data;
    wire                unit_control_enable;
    wire                pc_enable;
    wire [DWORD-1:0]    pc;
    wire [NB_STATE-1:0] state;
    wire                PIPELINE_enable;

    debug_unit debug_unit
    (
        .i_clock(clk_wiz), // 50 MHz
        .i_reset(i_reset),
        .i_halt(halt),
        .i_rx_done(i_rx_done),
        .i_tx_done(i_tx_done),
        .i_rx_data(i_rx_data),
        .i_pc_value(pc),
        .i_mem_data(mem_data),
        .i_bank_reg_data(rb_data),
        .o_instru_mem_data(im_data),
        .o_instru_mem_addr(im_addr),
        .o_rb_addr(rb_addr),
        .o_mem_data_addr(mem_addr),
        .o_tx_data(o_tx_data),
        .o_tx_start(o_tx_start),
        .o_instru_mem_write_enable(im_write_enable),
        .o_instru_mem_read_enable(im_read_enable),
        .o_instru_mem_enable(im_enable),
        .o_rb_read_enable(rb_read_enable),
        .o_rb_enable(rb_enable),
        .o_mem_data_enable(mem_enable),
        .o_mem_data_read_enable(mem_read_enable),
        .o_mem_data_debug_unit(read_memory_data_from_du),
        .o_unit_control_enable(unit_control_enable),
        .o_pc_enable(pc_enable),
        .o_state(state),
        .o_pipeline_enable(PIPELINE_enable)
    );

    

    PIPELINE PIPELINE
    (
        .i_clock(clk_wiz), // 50 MHz
        .i_pc_enable(pc_enable),
        .i_pc_reset(i_reset),
        .i_read_enable(im_read_enable),
        .i_ID_reset(i_reset),
        .i_reset_forward_stall(i_reset),
        .i_pipeline_enable(PIPELINE_enable),
        .i_MEM_debug_unit_flag(read_memory_data_from_du),
        .i_instru_mem_enable(im_enable),
        .i_instru_mem_write_enable(im_write_enable),
        .i_instru_mem_data(im_data),
        .i_instru_mem_addr(im_addr),
        .i_bank_register_enable(rb_enable),
        .i_bank_register_read_enable(rb_read_enable),
        .i_bank_register_addr(rb_addr),
        .i_mem_data_enable(mem_enable),
        .i_mem_data_read_enable(mem_read_enable),
        .i_mem_data_read_addr(mem_addr),
        .i_unit_control_enable(unit_control_enable),
        .o_halt(halt),
        .o_bank_register_data(rb_data),
        .o_mem_data_data(mem_data),
        .o_last_pc(pc)
    );
    
    assign o_state      = state;
    assign o_halt       = halt;
    
endmodule

