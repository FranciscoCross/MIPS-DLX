`timescale 1ns / 1ps
`include "parameters.vh"
module tb_FETCH(

    );
    localparam NB_INST = 32;
    localparam NB_DATA = `ADDRWIDTH;
    localparam MEM_SIZEB = `N_ELEMENTS;

    reg clock, i_reset, i_enable_pipe, i_debug_unit, i_en_write, i_en_read, wire_pc_write;
    reg wire_branch_or_jump_IF_ID;

    reg [NB_INST - 1:0] i_inst_load;                //Instruccion a escribir en PC
    reg [NB_DATA - 1:0] i_addr_inst_load;           //Address a escribir en PC 
    reg [NB_DATA - 1:0] wire_pc_src_ID_IF;          //PC source
    reg [NB_DATA - 1:0] wire_addr_reg_ID_IF;        //
    reg [NB_DATA - 1:0] wire_addr_branch_ID_IF;     //
    reg [NB_DATA - 1:0] wire_addr_jump_ID_IF;       //

    wire [NB_INST - 1:0] wire_inst_IF;               //Instruccion de salida
    wire [NB_DATA - 1:0] wire_pc_adder;              //Siguiente address del PC adder

    FETCH instruccion_fetch
	(	
    .i_clk(clock),
    .i_reset(i_reset),
    .i_enable(wire_pc_write&&i_enable_pipe),
    .i_debug_unit(i_debug_unit),
    .i_Mem_WEn(i_en_write),
    .i_Mem_REn(i_en_read),
    .i_Mem_Data(i_inst_load),
    .i_PCsrc(wire_pc_src_ID_IF),
    .i_addr_register(wire_addr_reg_ID_IF),
    .i_addr_branch(wire_addr_branch_ID_IF),
    .i_addr_jump(wire_addr_jump_ID_IF),
    .i_jump_or_branch(wire_branch_or_jump_IF_ID),
    .i_wr_addr(i_addr_inst_load), 
    .o_instruction(wire_inst_IF),
    .o_PCAddr(wire_pc_adder)
	);  

    initial
    begin
        clock <= 0;
        i_reset <= 0;

        i_enable_pipe <= 1; //Habilitamos la pipeline
        i_debug_unit <= 0; //Habilitamos modo debug
        i_en_write <= 0; //Habilitamos escritura
        i_en_read <= 1; //Habilitamos escritura
        wire_pc_write <= 1; //Habilitamos la escritura del PC
        wire_branch_or_jump_IF_ID <= 0;

        //A partir de aca registros con [NB_DATA - 1:0]
        i_inst_load <= 0;                
        i_addr_inst_load <= 0;
     
        wire_pc_src_ID_IF <= 0;         
        wire_addr_reg_ID_IF <= 0;        
        wire_addr_branch_ID_IF <= 0;     
        wire_addr_jump_ID_IF <= 0;              
    end

    always #1 clock = ~clock; // # < timeunit > delay
    initial begin
        #0
        #10
        i_debug_unit = 1;
        i_en_write = 1;
        #4 //Cargar informacion
        i_inst_load = 32'b10001100000000010000000000000000;
        i_addr_inst_load = 1;
        #4
        i_inst_load = 32'b10001100000000010000000000000001;
        i_addr_inst_load = 2;
        #4
        i_inst_load = 32'b10001100000000010000000000000010;
        i_addr_inst_load = 3;
        #4
        i_reset = 1;
        i_debug_unit = 0;
        i_en_write = 0;
        #2 //Desde aca lee con el PC
        i_reset = 0;
        #100
        $finish;
    end

endmodule
