`timescale 1ns / 1ps
`include "parameters.vh"

module tb_unit_branch(

    );

    localparam NB_DATA = 32;	
    
    reg clk = 0;
    reg [`ADDRWIDTH-1:0] PC;
    reg [`ADDRWIDTH-1:0] INM_EXT;
    reg [NB_DATA-1:0] DATA_RA;
    reg [NB_DATA-1:0] DATA_RB;
    wire IS_EQUAL;
    wire [`ADDRWIDTH-1:0] BRANCH_ADDRESS;


    unit_branch inst_unit_branch
    (
        .i_pc(PC),
		.i_inm_ext(INM_EXT),
        .i_data_ra(DATA_RA),
		.i_data_rb(DATA_RB),
		.o_is_equal(IS_EQUAL),
		.o_branch_address(BRANCH_ADDRESS)   
    );
    
    always #1 clk = ~clk; // # < timeunit > delay
    initial begin
        #0
        PC = 0;
        INM_EXT = 0;
        DATA_RA = 1;
        DATA_RB = 0;
        #10
        PC = 10;
        INM_EXT = 0;
        DATA_RA = 1;
        DATA_RB = 0;
        #10
        PC = 10;
        INM_EXT = 5;
        DATA_RA = 1;
        DATA_RB = 1;
        #10
        PC = 12;
        INM_EXT = 0;
        DATA_RA = 0;
        DATA_RB = 1;
        #10
        $finish;
    end
endmodule
