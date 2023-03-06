`include "parameters.vh"

module latch_IF_ID
	#(
		parameter NB_DATA = 32		
	)
	(
		input wire i_clock,  
		input wire i_enable,		
		input wire [`ADDRWIDTH-1:0] i_pc,
		input wire [NB_DATA-1:0] i_instruction,

		output reg [`ADDRWIDTH-1:0] o_pc,
		output reg [NB_DATA-1:0] o_instruction			
	);
	
	always @(negedge i_clock)
		begin
			if (i_enable)
				begin					
					o_pc          <= i_pc;
					o_instruction <= i_instruction;		
				end
				
			else
				begin
					o_pc <= o_pc;
					o_instruction <= o_instruction;
				end
				
								
		end		
endmodule 