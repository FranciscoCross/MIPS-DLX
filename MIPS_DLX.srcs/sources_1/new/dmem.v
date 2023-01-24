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
    
    initial
        begin
            RAM[0]  <= 8'h00000001; // Data 0
            RAM[1]  <= 8'h00000002; // Data 1
            RAM[2]  <= 8'h00000003; // Data 2
            RAM[3]  <= 8'h00000004; // Data 3
            RAM[4]  <= 8'h00000005; // Data 4
            RAM[5]  <= 8'h00000006; // Data 5
            RAM[6]  <= 8'h00000007; // Data 6
            RAM[7]  <= 8'h00000008; // Data 7
            RAM[8]  <= 8'h00000009; // Data 8
            RAM[9]  <= 8'h0000000A; // Data 9
            RAM[10] <= 8'h0000000B; // Data 10
        end


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
