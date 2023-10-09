`include "parameters.vh"

module latch_MEM_WB
	#(
		parameter NB_DATA = 32,
		parameter NB_REG  = 5,
		parameter NB_WB_CTRL = 3,
		parameter NB_MEM_TO_REG = 2
	)
	(
		input wire 						i_clock,
		input wire 						i_reset,
		input wire 						i_enable_pipe,
		input wire 						i_halt_detected,
		input wire [NB_DATA-1:0] 		i_mem_data,
		input wire [NB_DATA-1:0] 		i_alu_result,
		input wire [`ADDRWIDTH-1:0] 	i_pc,
		input wire [NB_DATA-1:0] 		i_data_inm, //dato a escribir en registro (LUI) 
		input wire [NB_WB_CTRL-1:0] 	i_WB_control,
		input wire [NB_REG-1:0] 		i_write_register,
	
		output wire [NB_REG-1:0] 		o_write_register,
		output wire [NB_MEM_TO_REG-1:0] o_mem_to_reg,
		output wire [NB_DATA-1:0] 		o_mem_data,
		output wire [NB_DATA-1:0] 		o_alu_result,
		output wire [`ADDRWIDTH-1:0] 	o_pc,
		output wire [NB_DATA-1:0] 		o_inm_ext,
		output wire 					o_reg_write,
		output wire 					o_halt_detected	
	
	);

	reg [NB_MEM_TO_REG-1:0] mem_to_reg;
	reg [NB_REG-1:0] 		write_reg;
	reg 					reg_write;
	reg [NB_DATA-1:0] 		mem_data_reg;
	reg [NB_DATA-1:0]		alu_result_reg;
	reg [NB_DATA-1:0]		inm_ext_reg;
	reg [`ADDRWIDTH-1:0] 	pc_reg;
	reg 					halt_detected;

	assign o_halt_detected 	= halt_detected;
	assign o_mem_to_reg     = mem_to_reg;
	assign o_reg_write      = reg_write;
	assign o_write_register = write_reg;
	assign o_mem_data       = mem_data_reg;
	assign o_alu_result     = alu_result_reg;
	assign o_pc             = pc_reg;
	assign o_inm_ext        = inm_ext_reg;

	always @(negedge i_clock)
		begin
			if (i_reset)
				begin
					halt_detected  <= 1'b0;
					mem_to_reg     <= 2'b0;
					reg_write      <= 1'b0;
					write_reg      <= 5'b0;
					mem_data_reg   <= 32'b0;
					alu_result_reg <= 32'b0;
					pc_reg         <= 32'b0;
					inm_ext_reg    <= 32'b0;
				end
			else
				begin
					if (i_enable_pipe)
						begin
							halt_detected  <= i_halt_detected;
							mem_to_reg     <= i_WB_control[1:0];
							reg_write      <= i_WB_control[2];
							write_reg      <= i_write_register;
							mem_data_reg   <= i_mem_data;
							alu_result_reg <= i_alu_result;
							pc_reg         <= i_pc;
							inm_ext_reg    <= i_data_inm;
						end
					else
						begin
							halt_detected  <= halt_detected;
							mem_to_reg     <= mem_to_reg;
							reg_write      <= reg_write;
							write_reg      <= write_reg;
							mem_data_reg   <= mem_data_reg;
							alu_result_reg <= alu_result_reg;
							pc_reg         <= pc_reg;
							inm_ext_reg    <= inm_ext_reg;
						end
				end

		end
endmodule
