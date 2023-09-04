`timescale 1ns / 1ps
`include "parameters.vh"

//This just connects every module together

module FETCH#(
    parameter NB_INST = 32,
    parameter NB_DATA = `ADDRWIDTH,
    parameter MEM_SIZEB = `N_ELEMENTS
    )(
    input i_clk,
    input i_reset,
    input i_enable,
    input wire i_debug_unit,
    input i_Mem_WEn,
    input i_Mem_REn,
    input [NB_INST - 1:0] i_Mem_Data,
    input [1:0] i_PCsrc,
    input wire [NB_DATA-1:0] i_addr_register,
    input wire [NB_DATA-1:0] i_addr_branch,
    input wire [NB_DATA-1:0] i_addr_jump,
    input wire i_jump_or_branch,
    input wire [`ADDRWIDTH-1:0] i_wr_addr, // enviado por debug_unit para cargar instruccion
    
    output [NB_INST - 1:0] o_instruction,
    output [NB_DATA - 1:0] o_PCAddr,
    output [NB_DATA - 1:0] o_next_PCAddr
    );
    //-------------------------------------------------
    //Debug Unit
    wire [`ADDRWIDTH-1:0] wire_address_debug;
    wire [`ADDRWIDTH-1:0] wire_pc;
    wire [NB_DATA-1:0] wire_address_jump_pc;
    wire [NB_DATA-1:0] wire_input_pc;
    wire [NB_INST-1:0] wire_instr;

    //Program counter
    wire [NB_DATA - 1:0] i_addr_pc;
    wire [NB_DATA - 1:0] o_addr_pc;
      
    //PC Addr
    wire [NB_DATA - 1:0] nextAddr_pc; 
    
    //Instruction memory
    reg imem_en_wr;
    reg imem_en_rd;

    wire neg_enable;
    //-------------------------------------------------
    initial begin
        imem_en_wr = 0;
        imem_en_rd = 1;
    end

    assign o_PCAddr = wire_pc;
    assign o_next_PCAddr = nextAddr_pc;

    not(neg_enable, i_enable);

    mux2#(.NB_DATA(`ADDRWIDTH)) mux_address_mem
	(
		.i_A(wire_pc), //0
		.i_B(i_wr_addr),    //1
		.i_SEL(i_debug_unit),
		.o_OUT(wire_address_debug)
	);

    //Address de entrada al Program Counter
    mux2#(.NB_DATA(NB_DATA)) mux_src_PC  
	(
		.i_A(nextAddr_pc),
		.i_B(wire_address_jump_pc),
		.i_SEL(i_jump_or_branch),
		.o_OUT(wire_input_pc)
	);
    
    
    //No es necesario en el salto retardado
    mux2#(.NB_DATA(NB_INST)) mux_input_reg_IF_ID
	(
		.i_A(wire_instr),//0
		.i_B(32'hF8000000),//1: NOP
		.i_SEL(1'b0), //jump_or_branch
		.o_OUT(o_instruction)
	);
    

    mux3#(.NB_DATA(NB_DATA)) mux_addr_branch_jump
	(
		.i_A(i_addr_register), //00
		.i_B(i_addr_branch), //01
		.i_C(i_addr_jump), //10
		.i_SEL(i_PCsrc),
		.o_OUT(wire_address_jump_pc)
	);
    
    pc #(
        .NB_DATA (NB_DATA)
    ) 
    inst_pc(
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_enable(neg_enable),
        .i_addr(wire_input_pc),
        .o_addr(wire_pc)
    );

    pc_add #(
        .NB_DATA (NB_DATA)
    ) 
    inst_pc_add(
        .i_nAddr(wire_pc),
        .o_nAddr(nextAddr_pc)
    );
    
    
    imem #(
        .NB_INST(NB_INST),
        .MEM_SIZEB(MEM_SIZEB)
    )
    instancia_imem(
        .i_clk(i_clk),
        .i_enable(neg_enable),
        .i_reset(i_reset),
        .i_en_write(i_Mem_WEn),
        .i_en_read(i_Mem_REn),
        .i_addr(wire_address_debug),
        .i_data(i_Mem_Data),
        .o_data(wire_instr)
    );

endmodule
