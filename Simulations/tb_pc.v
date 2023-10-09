`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.01.2023 22:13:32
// Design Name: 
// Module Name: tb_pc
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_pc;
    localparam NB_DATA = 32;
       
    reg clk = 0;
    reg [NB_DATA -1 : 0] i_addr;
    reg enable = 1;
    reg reset = 0;
    
    wire [NB_DATA -1 : 0] o_addr;

    pc #(.NB_DATA (NB_DATA)) inst_pc
    (
        .i_clock(clk),
        .i_reset(reset),
        .i_enable(enable),
        .i_addr(i_addr),
        .o_addr(o_addr)
    );
    
    always  #1 clk = ~clk;
    initial begin
        #0
            clk = 1;
            i_addr = 10;
        #1
            reset = 1;
        #2
            i_addr = 11;    
        #3
            reset = 0;
        #4 
            enable = 0;
        #5 
            i_addr = 12;
        #6
            enable = 1;
        #7 
            i_addr = 13;
        #8  //Overflow test should result in 0xFFFF FFFF
            i_addr = 32'hFFFFFFFF;
        #9
        $finish;
    end
    
    
endmodule
