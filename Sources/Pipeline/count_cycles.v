module count_cycles
	#(
		parameter NB_COUNT = 8
	)
	(
		input wire i_clock,
		input wire i_reset,
		input wire i_en_count,

		output wire [NB_COUNT-1:0] o_count_cycles

	);
	reg [NB_COUNT-1:0] count_cycles_reg;

	assign o_count_cycles = count_cycles_reg;
	initial begin
		count_cycles_reg = 0;
	end
	always @(posedge i_clock)
		begin
			if (i_reset)
				count_cycles_reg <= 8'b0;
			else
				if (i_en_count)
					begin
						count_cycles_reg <= count_cycles_reg + 1;
					end
				else
					count_cycles_reg <= count_cycles_reg;

		end


endmodule 