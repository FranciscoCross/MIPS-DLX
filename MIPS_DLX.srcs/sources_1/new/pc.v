`timescale 1ns / 1ps
`include "parameters.vh"

/*
Saves the input addres in an internal register and outputs it.
*/
module pc#(
    parameter NB_ADDRESS = `ADDRWIDTH
    )(
    input i_clk,
    input i_reset,
    input i_enable,
    input[NB_ADDRESS - 1:0] i_addr,
    input[NB_ADDRESS - 1:0] o_addr
    );
    
    reg [NB_ADDRESS-1:0] reg_addr;

    always @(posedge i_clk)
    begin
        if(i_reset)
            reg_addr <= {NB_ADDRESS{1'b0}};
        else
            begin
                if(i_enable)
                    reg_addr <= i_addr;
                else 
                    reg_addr <= reg_addr;
            end
    end
    assign o_addr = reg_addr;
endmodule
