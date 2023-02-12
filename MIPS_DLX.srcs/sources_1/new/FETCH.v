`timescale 1ns / 1ps
`include "parameters.vh"

//This just connects every module together

module FETCH#(
    parameter NB_DATA = `ADDRWIDTH,
    parameter MEM_SIZEB = `N_ELEMENTS,
    parameter NB_INST_LEN = 32
    )(
    input i_clk,
    input i_enable,
    input i_reset,

    //Program counter
    input i_PCsrc,
    input i_PCHalt,
    input [NB_DATA - 1:0] i_branch_addr, // enviado por debug_unit para cargar instruccion 			

    //Instruction memory
    input i_Mem_WEn,
    input i_Mem_REn,
    input [NB_INST_LEN - 1:0] i_Mem_Data,
    
    //Outputs
    output [NB_INST_LEN - 1:0] o_instruction,
    output [NB_DATA - 1:0] o_PCAddr
    );
    //-------------------------------------------------

    //Program counter
    wire [NB_DATA - 1:0] i_addr_pc;
    wire [NB_DATA - 1:0] o_addr_pc;
      
    //PC Addr
    wire [NB_DATA - 1:0] o_nAddr_pc; 
    
    //Instruction memory
    reg imem_en_wr = 0;
    reg imem_en_rd = 1;
    wire [NB_INST_LEN - 1:0] o_inst;
 
    //-------------------------------------------------
    assign o_PCAddr = o_nAddr_pc;
    assign o_instruction = o_inst;
    
    pc #(
        .NB_DATA (NB_DATA)
    ) 
    inst_pc(
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_enable(i_PCHalt),
        .i_addr(i_addr_pc),
        .o_addr(o_addr_pc)
    );

    pc_add #(
        .NB_DATA (NB_DATA)
    ) 
    inst_pc_add(
        .i_nAddr(o_addr_pc),
        .o_nAddr(o_nAddr_pc)
    );
    
    mux2 #(
        .NB_DATA(NB_DATA)
    )
    instancia_mux2(
        .i_SEL(i_PCsrc),
        .i_A(o_nAddr_pc),
        .i_B(i_branch_addr),
        .o_OUT(i_addr_pc)
    );
    
    imem #(
        .NB_DATA(NB_INST_LEN),
        .MEM_SIZEB(MEM_SIZEB)
    )
    instancia_imem(
        .i_clk(i_clk),
        .i_en_write(i_Mem_WEn),
        .i_en_read(i_Mem_REn),
        .i_addr(o_addr_pc),
        .i_data(i_Mem_Data),
        .o_data(o_inst)
    );


    /*
    //TODO: Para el branching
    mux3 #(
        .NB_DATA(NB_DATA)
    )
    instancia_mux3(
        .i_SEL(i_branch),
        .i_A(pc_add),
        .i_B(o_instruction),
        .i_C(o_instruction),
        .o_OUT(i_addr_pc)
    );
    */
endmodule
