`timescale 1ns / 1ps
`include "parameters.vh"
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
    input wire [`ADDRWIDTH - 1 : 0] i_addr,
    input wire [NB_INST - 1  :  0] i_data,
    output wire [NB_INST - 1 :  0] o_data
    );
    
    reg [NB_INST-1 : 0] MEM[MEM_SIZEB - 1 : 0];  //Register of memory 
    reg [NB_INST-1 : 0] data;             //Local variable to store the latest register pointed at
    reg [`ADDRWIDTH-1 : 0] reg_addr;

   generate
        integer reg_index;
        initial
            for (reg_index = 0; reg_index < MEM_SIZEB; reg_index = reg_index + 1)
                MEM[reg_index] = 32'b11111000000000000000000000000000;
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

   //Write
    always @(posedge i_clk)
        begin
           if(i_reset)
              data = MEM[0];
           else if(i_en_write)
              MEM[i_addr] = i_data;          
           else
              data = data; //Any case show latest instruction
        end
   //Read
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

   always @(negedge i_enable)
   begin
      if(i_en_read)
         if(reg_addr > 0)
         data = MEM[reg_addr-1];    
   end

   always @(posedge i_enable)
   begin
      if(i_en_read)
         data = MEM[reg_addr];    
   end
   
   assign o_data = data;
    	    // Inicializacion de registros.

endmodule
