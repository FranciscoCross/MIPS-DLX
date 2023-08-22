`timescale 1ns / 1ps
`include "parameters.vh"

module mux3
	#(
		parameter NB_DATA = `ADDRWIDTH,
		parameter NB_SEL = 2
	)
    (
        input wire [NB_SEL-1:0] i_SEL,
        input wire [NB_DATA-1:0] i_A,
        input wire [NB_DATA-1:0] i_B,
        input wire [NB_DATA-1:0] i_C,
        output wire [NB_DATA-1:0] o_OUT
    );
    
    reg [NB_DATA-1:0] out;
    
    always @(*)
    begin
        case (i_SEL)
            2'b00:
                out = i_A;
            2'b01:
                out = i_B;
            2'b10:
                out = i_C;
            default:
                out = i_A;
        endcase
    end
    
    assign o_OUT = out;
    
endmodule