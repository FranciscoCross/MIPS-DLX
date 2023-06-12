`timescale 1ns / 1ps

`include "parameters.vh"

module dmem
 #(
    parameter NB_DATA = 32 
  )
  (
    input wire i_clk,
    input wire i_mem_enable, 

    input wire [`ADDRWIDTH-1:0] i_addr,
    input wire [NB_DATA-1:0] i_data,

    input wire i_read,
    input wire i_write,
   
    output wire [NB_DATA-1:0] o_data
  );
  
    reg [NB_DATA-1:0] RAM[`N_ELEMENTS-1:0];
    reg [NB_DATA-1:0] data_reg = {NB_DATA{1'b0}};
     
    assign o_data = data_reg;
    //Para Inicializar la memoria en cero
    generate
      integer i;		
      initial 
      begin
        data_reg = 0;
        RAM[0] = {NB_DATA{1'b0}};
        for (i = 1; i < 128; i = i + 1)
            RAM[i] = {NB_DATA{1'b0}}; 
      end
    endgenerate
    
  always @(posedge i_clk)
    begin
      if (i_mem_enable)
        begin
            if (i_write)
                RAM[i_addr] <= i_data;
        end
      else
        RAM[i_addr] <= RAM[i_addr];
    end

  always @(posedge i_clk)
    begin
      if (i_mem_enable)
        begin          
          if (i_read)
            data_reg <= RAM[i_addr];
          else
            data_reg <= 32'bz;
        end
    end

endmodule
