`timescale 1ns / 1ps

//`define N_ELEMENTS 128
//`define ADDRWIDTH $clog2(`N_ELEMENTS)

module imem#(
    parameter MEM_SIZEB = 128, //Set memory size in bits
    parameter NB_DATA = 32
    )
    (
    input i_clk,
    input i_reset,
    input i_en_write,
    input i_en_read,
    input [$clog2(MEM_SIZEB) - 1 : 0] i_addr,
    input [NB_DATA - 1  :  0] i_data,
    output [NB_DATA - 1 :  0] o_data
    );
    
    reg [NB_DATA-1 : 0] MEM[MEM_SIZEB - 1 : 0];  //Register of memory 
    reg [NB_DATA-1 : 0] data;             //Local variable to store the latest register pointed at
      
    always @(posedge i_clk)
        begin
            if(i_en_write)
              MEM[i_addr] <= i_data;
            else if(i_en_read)
              data <= MEM[i_addr];
           else
              data <= data; //Any case show latest instruction
        end
    assign o_data = data;
    	    // Inicializacion de registros.
	generate
    integer i;		
		initial
	    for (i = 0; i < MEM_SIZEB; i = i + 1)
        MEM[i] = 32'd0; 
	endgenerate
endmodule
