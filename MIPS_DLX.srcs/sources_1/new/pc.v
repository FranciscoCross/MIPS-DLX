`timescale 1ns / 1ps
`include "parameters.vh"

/*
Saves the input addres in an internal register and outputs it.
*/
module pc#(
    parameter NB_DATA = `ADDRWIDTH
    )(
    input wire i_clk,
    input wire i_reset,
    input wire i_enable,
    input wire [NB_DATA - 1:0] i_addr,
    output wire [NB_DATA - 1:0] o_addr
    );
    
    reg [NB_DATA-1:0] reg_addr;

    initial begin
        reg_addr <= {NB_DATA{1'b0}};
    end

    always @(negedge i_clk)
    begin
        if(i_reset)
            reg_addr <= {NB_DATA{1'b0}};
        else
            begin
                if(i_enable)
                    reg_addr <= i_addr;
                else 
                begin
                    $display("PC %d disabled", reg_addr);
                    
                end
            end
    end
    always @(posedge i_enable)
    begin
        $display("PC %d enabled", reg_addr);
        reg_addr <= i_addr;
    end

    always @(negedge i_enable)
    begin
        $display("PC %d disabled", reg_addr);
        if(reg_addr > 0)
            reg_addr <= reg_addr - 1 ;
    end
    
    assign o_addr = reg_addr;
endmodule
