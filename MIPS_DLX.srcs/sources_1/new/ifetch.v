`timescale 1ns / 1ps
`include "parameters.vh"

//This just connects every module together

module ifetch#(
    parameter NB_ADDRESS = `ADDRWIDTH
    )(
    input i_clk,
    input i_enable,
    input i_reset,
    input i_branch
    );
    //-------------------------------------------------
    //Program counter
    wire [NB_ADDRESS - 1:0] i_addr_pc;
    wire [NB_ADDRESS - 1:0] o_addr_pc;  
    //Instruction memory
    reg imem_en_wr = 0;
    reg imem_en_rd = 1;
    reg [NB_ADDRESS - 1:0] imem_data = 0;  
    wire [NB_ADDRESS - 1:0] pc_add;        //Next address
    wire[NB_ADDRESS - 1:0] o_instruction;
    
    //Multiplexor
    wire [NB_ADDRESS - 1:0] o_addr_pc;  

    //-------------------------------------------------
    pc #(
        .NB_ADDRESS (NB_ADDRESS)
        ) inst_pc
    (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_enable(i_enable),
        .i_addr(o_addr_pc),
        .o_addr()
    );

    imem #(
        .NB_DATA(NB_ADDRESS)
    )
    instancia_imem(
        .i_clk(i_clk),
        .i_en_write(imem_en_wr),
        .i_en_read(imem_en_rd),
        .i_addr(o_addr_pc),
        .i_data(imem_data),
        .o_data(o_instruction)
    );

    mux2 #(
        .NB_DATA(NB_ADDRESS)
    )
    instancia_mux2(
        .i_SEL(i_branch),
        .i_A(pc_add),
        .i_B(o_instruction),
        .o_OUT(i_addr_pc)
    );
    
endmodule
