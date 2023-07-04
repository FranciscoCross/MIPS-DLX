`timescale 1ns / 1ps

//`define N_ELEMENTS 128
//`define ADDRWIDTH $clog2(`N_ELEMENTS)

module imem#(
    parameter NB_INST = 32,
    parameter MEM_SIZEB = 128 //Set memory size in bits
    )
    (
    input wire i_clk,
    input wire i_enable,
    input wire i_reset,
    input wire i_en_write,
    input wire i_en_read,
    input wire [$clog2(MEM_SIZEB) - 1 : 0] i_addr,
    input wire [NB_INST - 1  :  0] i_data,
    output wire [NB_INST - 1 :  0] o_data
    );
    
    reg [NB_INST-1 : 0] MEM[MEM_SIZEB - 1 : 0];  //Register of memory 
    reg [NB_INST-1 : 0] data;             //Local variable to store the latest register pointed at
    reg [NB_INST-1 : 0] reg_addr;
  	generate
    integer i;		
		initial begin
	    for (i = 0; i < MEM_SIZEB; i = i + 1)
        MEM[i] <= 32'b11111000000000000000000000000000; //NOP 
    end
	endgenerate

   initial 
      begin
         data = {NB_INST{1'b0}}; 
         reg_addr = 0;
      end


   always @(posedge i_clk)
      begin
         reg_addr <= i_addr;
      end


    always @(posedge i_clk)
        begin
           if(i_reset)
              data = MEM[0];
           else if(i_en_write)
              MEM[i_addr] = i_data;          
           else
              data = data; //Any case show latest instruction
        end
   always @(negedge i_clk)
      begin
         if(i_enable)
         begin
            if(i_en_read)
               data = MEM[reg_addr];            
            else 
               data = data; //Any case show latest instruction
         end
      end
    assign o_data = data;
    	    // Inicializacion de registros.

endmodule
