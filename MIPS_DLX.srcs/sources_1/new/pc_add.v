`include "parameters.vh"

module pc_add
	#(
		parameter NB_DATA = `ADDRWIDTH
	)
	(
		input wire [NB_DATA-1:0] i_nAddr,
		output wire [NB_DATA-1:0] o_nAddr
	);

	assign o_nAddr = i_nAddr + {{NB_DATA-1{1'b0}}, 1'b1};

endmodule