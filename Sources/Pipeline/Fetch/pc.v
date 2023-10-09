`timescale 1ns / 1ps
`include "parameters.vh"

/*
Saves the input addres in an internal register and outputs it.
*/
module pc#(
    parameter NB_DATA = `ADDRWIDTH
    )(
    input wire                  i_clock,
    input wire                  i_reset,
    input wire                  i_enable,
    input wire [NB_DATA - 1:0]  i_addr,
    output wire [NB_DATA - 1:0] o_addr
    );
    
    reg [NB_DATA-1:0] reg_addr;

    initial begin
        reg_addr <= {NB_DATA{1'b0}};
    end

    always @(negedge i_clock)
    begin
        if(i_reset)
            reg_addr <= {NB_DATA{1'b0}};
        else
            begin
                if(i_enable)
                    reg_addr <= reg_addr;
                else 
                    reg_addr <= i_addr;
                    
            end
    end
    
    assign o_addr = reg_addr;
endmodule
