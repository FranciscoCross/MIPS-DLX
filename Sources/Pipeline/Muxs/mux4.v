`include "parameters.vh"

module mux4
	#(
		parameter NB_DATA = `ADDRWIDTH,
        parameter NB_SEL = 2
	)
    (
        input [NB_SEL-1:0] i_SEL,
        input [NB_DATA-1:0] i_A,
        input [NB_DATA-1:0] i_B,
        input [NB_DATA-1:0] i_C,
        input [NB_DATA-1:0] i_D,
        output [NB_DATA-1:0] o_OUT
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
            2'b11:
                out = i_D;
        endcase
    end
    
    assign o_OUT = out;
    
endmodule