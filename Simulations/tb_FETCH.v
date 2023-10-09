`timescale 1ns / 1ps
`include "parameters.vh"
module tb_FETCH(

    );
    localparam NB_INST = 32;
    localparam NB_DATA = `ADDRWIDTH;
    localparam MEM_SIZEB = `N_ELEMENTS;

    reg clock, i_reset, i_enable_pipe, i_debug_unit, i_Mem_WEn, i_Mem_REn, wire_pc_write;
    reg i_jump_or_branch;

    reg [NB_INST - 1:0] i_Mem_Data;                //Instruccion a escribir en PC
    reg [NB_DATA - 1:0] i_wr_addr;           //Address a escribir en PC 
    reg [NB_DATA - 1:0] i_PCsrc;          //PC source
    reg [NB_DATA - 1:0] i_addr_register;        //
    reg [NB_DATA - 1:0] i_addr_branch;     //
    reg [NB_DATA - 1:0] i_addr_jump;       //

    wire [NB_INST - 1:0] o_instruction;               //Instruccion de salida
    wire [NB_DATA - 1:0] o_PCAddr;              //Siguiente address del PC adder

    FETCH instruccion_fetch
	(	
    .i_clock(clock),
    .i_reset(i_reset),
    .i_enable(wire_pc_write&&i_enable_pipe),
    .i_debug_unit(i_debug_unit),
    .i_Mem_WEn(i_Mem_WEn),
    .i_Mem_REn(i_Mem_REn),
    .i_Mem_Data(i_Mem_Data),
    .i_PCsrc(i_PCsrc),
    .i_addr_register(i_addr_register),
    .i_addr_branch(i_addr_branch),
    .i_addr_jump(i_addr_jump),
    .i_jump_or_branch(i_jump_or_branch),
    .i_wr_addr(i_wr_addr), 
    .o_instruction(o_instruction),
    .o_PCAddr(o_PCAddr)
	);  

    initial
    begin
        clock <= 0;
        i_reset <= 0;

        i_enable_pipe <= 0; //Habilitamos la pipeline
        i_debug_unit <= 0; //Habilitamos modo debug
        i_Mem_WEn <= 0; //Habilitamos escritura
        i_Mem_REn <= 1; //Habilitamos escritura
        wire_pc_write <= 1; //Habilitamos la escritura del PC
        i_jump_or_branch <= 0;

        //A partir de aca registros con [NB_DATA - 1:0]
        i_Mem_Data <= 0;                
        i_wr_addr <= 0;
     
        i_PCsrc <= 0;         
        i_addr_register <= 0;        
        i_addr_branch <= 0;     
        i_addr_jump <= 0;              
    end

    always #1 clock = ~clock; // # < timeunit > delay
    initial begin
        #0
        #1
        $display("Test 01: Carga de informacion desde debug unit");
        i_debug_unit = 1;
        i_Mem_WEn = 1;
        i_Mem_REn = 0;
        i_jump_or_branch = 0;
        #2 //Cargar informacion
        i_Mem_Data = 32'b00111100000000010000000000001010;
        i_wr_addr = 0;
        #2
        i_Mem_Data = 32'b00111100000000100000000000010100;
        i_wr_addr = 1;
        #2
        i_Mem_Data = 32'b00111100000000110000000000011110;
        i_wr_addr = 2;
        #2
        i_Mem_Data = 32'b00000000001000100010000000100001;
        i_wr_addr = 3;
        #2
        i_Mem_Data = 32'b00010000011001000000000000000111;
        i_wr_addr = 4;
        #2
        i_Mem_Data = 32'b00100000000000110000000000001010;
        i_wr_addr = 5;
        #2
        i_Mem_Data = 32'b00001000000000000000000000001000;
        i_wr_addr = 6;
        #2
        i_Mem_Data = 32'b00100000000000110000000000001010;
        i_wr_addr = 7;
        #2
        i_Mem_Data = 32'b10001100000001010000000000000000;
        i_wr_addr = 8;
        #2
        i_Mem_Data = 32'b10101100000001000000000000000001;
        i_wr_addr = 9;
        #2
        i_Mem_Data = 32'b11111100000000000000000000000000;
        i_wr_addr = 10;
        #2
        i_wr_addr = 11;
        #3
        i_enable_pipe = 1;
        i_debug_unit = 0;
        i_Mem_WEn = 0;
        i_Mem_REn = 1;
        i_Mem_Data = 0;
        i_PCsrc = 0;
        i_addr_register = 0;
        i_addr_branch = 0;
        i_addr_jump = 0;
        i_jump_or_branch = 0;
        #1
        i_addr_branch = 1;
        #2
        i_addr_branch = 12;
        i_addr_jump = 10;
        #2
        i_addr_branch = 23;
        i_addr_jump = 20;
        #2
        i_addr_branch = 34;
        i_addr_jump = 30;
        #1
        i_enable_pipe = 0;
        #1
        i_addr_branch = 38;
        i_addr_jump = 33;
        #1
        i_addr_register = 10;
        #2
        i_enable_pipe = 1;
        #2
        i_PCsrc = 1;
        #1
        i_addr_register = 30;
        i_addr_branch = 13;
        i_addr_jump = 7;
        #1
        i_PCsrc = 0;
        #1
        i_addr_register = 0;
        i_addr_branch = 17;
        i_addr_jump = 10;
        #1
        i_PCsrc = 2;
        #1
        i_addr_branch = 22;
        i_addr_jump = 8;
        #1
        i_PCsrc = 0;
        #1
        i_addr_branch = 15;
        i_addr_jump = 0;
        #2
        i_addr_branch = 9;
        #2
        i_addr_branch = 10;
        #2
        i_addr_branch = 12;
        i_addr_jump = 1;
        #2
        i_addr_branch = 13;
        i_addr_jump = 0;
       
        
        #10
        $finish;
    end

endmodule
