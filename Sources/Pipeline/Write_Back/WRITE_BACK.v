`include "parameters.vh"

module WRITE_BACK
	#(
		parameter NB_DATA = 32,
		parameter NB_MEM_TO_REG = 2
	)
	(
		input wire i_clock,
		input wire i_reset,
		input wire [NB_DATA-1:0] i_mem_data,
		input wire [NB_DATA-1:0] i_alu_result,
		input wire [`ADDRWIDTH-1:0] i_pc,
		input wire [NB_DATA-1:0] i_inm_ext, // LUI
		input wire [NB_MEM_TO_REG-1:0] i_mem_to_reg,
		output wire [NB_DATA-1:0] o_data
	);

	wire [NB_DATA-1:0] wire_data;
	reg [NB_DATA-1:0] reg_data;

	assign o_data = reg_data;

	initial begin
		reg_data = 0;
	end
	always @(posedge i_clock)
	begin
		if(i_reset)
		begin
			reg_data <= 0;
		end
		else
		begin
			reg_data <= wire_data;
		end
	end

	mux4#(.NB_DATA(NB_DATA)) mux_write_back
	(
		.i_A(i_mem_data), 		//00
		.i_B(i_alu_result), 	//01
		.i_C({{25'b0}, i_pc}), 	//10
		.i_D(i_inm_ext), 		//11
		.i_SEL(i_mem_to_reg),
		.o_OUT(wire_data)
	);

endmodule