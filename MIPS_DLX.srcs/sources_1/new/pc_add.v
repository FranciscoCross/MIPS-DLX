`include "parameters.vh"

module pc_add
	#(
		parameter NB_DATA = `ADDRWIDTH
	)
	(
		input wire i_clk,
		input wire i_enable,
		input wire [NB_DATA-1:0] i_nAddr,
		output wire [NB_DATA-1:0] o_nAddr
	);

    reg [NB_DATA-1  :0] PC_reg;
	initial begin
		PC_reg = 0;
	end

	assign o_nAddr = PC_reg;

    always @(posedge i_clk)
    begin
		if(i_enable)
			PC_reg <= i_nAddr + 1;
		else 
			PC_reg <= 0;
	end

endmodule