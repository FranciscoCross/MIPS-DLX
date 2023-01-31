module unit_jump
	#(
		parameter NB_DATA = 32,
		parameter NB_JUMP = 26
	)
	(
		input wire [NB_JUMP-1:0] i_data_to_shift,
		input wire [3:0] i_pc_4,

		output wire [NB_DATA-1:0] o_jump_address
	);
	
	wire [NB_JUMP+1:0] conex_data_to_shift;

	shift_left_2 shift_left_2
	(
		.i_data_to_shift(i_data_to_shift),
		.o_data_to_shift(conex_data_to_shift)
	);

	assign o_jump_address = {i_pc_4, conex_data_to_shift};

endmodule