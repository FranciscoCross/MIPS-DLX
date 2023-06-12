`include "parameters.vh"

module WRITE_BACK
	#(
		parameter NB_DATA = 32,
		parameter NB_MEM_TO_REG = 2
	)
	(
		input wire [NB_DATA-1:0] i_mem_data,
		input wire [NB_DATA-1:0] i_alu_result,
		input wire [`ADDRWIDTH-1:0] i_pc,
		input wire [NB_DATA-1:0] i_inm_ext, // LUI
		input wire [NB_MEM_TO_REG-1:0] i_mem_to_reg,
		output wire [NB_DATA-1:0] o_data
	);


	mux4#(.NB_DATA(NB_DATA)) mux_write_back
	(
		.i_A(i_mem_data), 
		.i_B(i_alu_result), 
		.i_C({{25'b0}, i_pc}), 
		.i_D(i_inm_ext), 
		.i_SEL(i_mem_to_reg),
		.o_OUT(o_data)
	);

endmodule