`timescale 1ns / 1ps

//`define N_ELEMENTS 128
//`define ADDRWIDTH $clog2(`N_ELEMENTS)

module imem#(
    parameter NB_INST = 32,
    parameter MEM_SIZEB = 128 //Set memory size in bits
    )
    (
    input wire i_clk,
    input wire i_reset,
    input wire i_en_write,
    input wire i_en_read,
    input wire [$clog2(MEM_SIZEB) - 1 : 0] i_addr,
    input wire [NB_INST - 1  :  0] i_data,
    output wire [NB_INST - 1 :  0] o_data
    );
    
    reg [NB_INST-1 : 0] MEM[MEM_SIZEB - 1 : 0];  //Register of memory 
    reg [NB_INST-1 : 0] data;             //Local variable to store the latest register pointed at
    
  	generate
    integer i;		
		initial begin
		MEM[0] <= {NB_INST{1'b0}}; 
	    for (i = 1; i < MEM_SIZEB; i = i + 1)
        MEM[i] <= i; 
    end
	endgenerate

    initial begin
      data <= {NB_INST{1'b0}}; 
    end

    always @(posedge i_clk)
        begin
           if(i_reset)
              data = MEM[0];
           else if(i_en_write)
              MEM[i_addr] = i_data;
           else if(i_en_read)
              data = MEM[i_addr];            
           else//if(!i_en_write && !i_en_read) 
              data = data; //Any case show latest instruction
        end
    assign o_data = data;
    	    // Inicializacion de registros.

endmodule
