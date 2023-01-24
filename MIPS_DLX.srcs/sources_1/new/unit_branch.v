`include "parameters.vh"

module unit_branch
	#(
		parameter NB_DATA = 32		
	)
	(
		input wire [`ADDRWIDTH-1:0] i_pc,
		input wire [`ADDRWIDTH-1:0] i_inm_ext,
		input wire [NB_DATA-1:0] i_data_ra,
		input wire [NB_DATA-1:0] i_data_rb,
		output wire o_is_equal,
		output wire [`ADDRWIDTH-1:0] o_branch_address   

	);

	assign o_is_equal = (i_data_ra == i_data_rb) ? 1'b1 : 1'b0;
	assign o_branch_address = i_pc + i_inm_ext;	

endmodule