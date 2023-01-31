module shift_left_2
	#(
		parameter NB_DATA_1 = 26,
		parameter NB_DATA_2 = 28
	)
	(
		input wire [NB_DATA_1-1:0] i_data_to_shift,
		output wire [NB_DATA_2-1:0] o_data_to_shift	
	);

    assign o_data_to_shift = i_data_to_shift << 2; 
    
endmodule