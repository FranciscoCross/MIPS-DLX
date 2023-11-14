`timescale 1ns / 1ps
module TOP#(
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
        input                 i_uart_debug_unit_rx,

        output                o_uart_debug_unit_tx,
        output                o_halt,
        output                o_locked,
        output [NB_STATE-1:0] o_state
    );

   wire clk_wiz;
    
   clk_wiz_0 clk_wizard
     (
     // Clock out ports  
     .clk_out1(clk_wiz),
     // Status and control signals               
     .reset(i_clock_reset), 
     .locked(o_locked),
    // Clock in ports
     .clk_in1(i_clock)
     );

    wire                im_read_enable;
    wire                halt;
    wire                uart_debug_unit_rx_done;
    wire                uart_debug_unit_tx_done;
    wire                uart_debug_unit_tx;
    wire                uart_debug_unit_tx_start;
    wire [BYTE-1:0]     uart_debug_unit_to_send;
    wire [BYTE-1:0]     uart_debug_unit_received;
    wire                mem_enable;
    wire                read_mem_data_from_du;
    wire                mem_read_enable;
    wire [DWORD-1:0]    mem_data;
    wire [ADDR-1:0]     mem_addr;
    wire                rb_enable;
    wire                rb_read_enable;
    wire [DWORD-1:0]    rb_data;
    wire [RB_ADDR-1:0]  rb_addr;
    wire                im_enable;
    wire                im_write_enable;
    wire [BYTE-1:0]     im_addr;
    wire [BYTE-1:0]     im_data;
    wire                unit_control_enable;
    wire                pc_enable;
    wire [DWORD-1:0]    pc;
    wire [NB_STATE-1:0] state;
    wire                pipeline_enable;

    debug_unit debug_unit
    (
        .i_clock(clk_wiz),
        .i_reset(i_reset),
        .i_halt(halt),
        .i_rx_done(uart_debug_unit_rx_done),
        .i_tx_done(uart_debug_unit_tx_done),
        .i_rx_data(uart_debug_unit_received),
        .i_pc_value(pc),
        .i_mem_data(mem_data),
        .i_bank_reg_data(rb_data),
        .o_instru_mem_data(im_data),
        .o_instru_mem_addr(im_addr),
        .o_rb_addr(rb_addr),
        .o_mem_data_addr(mem_addr),
        .o_tx_data(uart_debug_unit_to_send),
        .o_tx_start(uart_debug_unit_tx_start),
        .o_instru_mem_write_enable(im_write_enable),
        .o_instru_mem_read_enable(im_read_enable),
        .o_instru_mem_enable(im_enable),
        .o_rb_read_enable(rb_read_enable),
        .o_rb_enable(rb_enable),
        .o_mem_data_enable(mem_enable),
        .o_mem_data_read_enable(mem_read_enable),
        .o_mem_data_debug_unit(read_mem_data_from_du),
        .o_unit_control_enable(unit_control_enable),
        .o_pc_enable(pc_enable),
        .o_state(state),
        .o_pipeline_enable(pipeline_enable)
    );
    
    UART UART_debug_unit
    (
        .i_clock(clk_wiz),
        .i_reset(i_reset),
        .i_rx(i_uart_debug_unit_rx),
        .i_tx_data(uart_debug_unit_to_send),
        .i_tx_start(uart_debug_unit_tx_start),
        .o_rx_data(uart_debug_unit_received),
        .o_rx_done_tick(uart_debug_unit_rx_done),
        .o_tx(uart_debug_unit_tx),
        .o_tx_done_tick(uart_debug_unit_tx_done)
    );

    PIPELINE PIPELINE
    (
        .i_clock(clk_wiz), 
        .i_pc_enable(pc_enable),
        .i_pc_reset(i_reset),
        .i_read_enable(im_read_enable),
        .i_ID_reset(i_reset),
        .i_reset_forward_stall(i_reset),
        .i_pipeline_enable(pipeline_enable),
        .i_MEM_debug_unit_flag(read_mem_data_from_du),
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
    
    assign o_state              = state;
    assign o_uart_debug_unit_tx = uart_debug_unit_tx;
    assign o_halt               = halt;

    
endmodule

