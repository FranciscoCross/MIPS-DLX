`timescale 1ns / 1ps
`include "parameters.vh"

module mux2
	#(
		parameter NB_DATA = `ADDRWIDTH
	)
    (
    input i_SEL,
    input [NB_DATA-1:0] i_A,
    input [NB_DATA-1:0] i_B,
    output [NB_DATA-1:0] o_OUT
    );

    assign o_OUT = (i_SEL) ? i_A : i_B;

endmodule