`include "parameters.vh"

module latch_EX_MEM
	#(
		parameter NB_DATA = 32,
		parameter NB_REG  = 5,
		parameter NB_MEM_CTRL = 6,
		parameter NB_WB_CTRL = 3
	)
	(
		input wire i_clock,
		input wire i_reset,
		input wire i_enable_pipe,
		input wire i_halt_detected,	
		input wire [NB_DATA-1:0] i_alu_result,
		input wire [NB_DATA-1:0] i_data_write, //dato a escribir en memoria
		input wire [NB_DATA-1:0] i_data_inm, //dato a escribir en registro (LUI)
		input wire [NB_REG-1:0] i_write_register,
		input wire [`ADDRWIDTH-1:0] i_pc,

		input wire [NB_MEM_CTRL-1:0] i_MEM_control, //write o read
		input wire [NB_WB_CTRL-1:0] i_WB_control, 
			

		output wire [NB_DATA-1:0] o_alu_result,
		output wire [NB_DATA-1:0] o_data_write, //store
		output wire [NB_DATA-1:0] o_data_inm,
		output wire [NB_REG-1:0] o_write_register,// registro a escribir

		output wire [NB_MEM_CTRL-1:0] o_MEM_control,
		output wire [NB_WB_CTRL-1:0] o_WB_control,		

		output wire [`ADDRWIDTH-1:0] o_pc,
		output wire o_reg_write,
		output wire o_halt_detected	
		
	);

	reg [NB_REG-1:0] write_reg;	
	reg [NB_DATA-1:0] mem_data_reg, alu_result_reg, data_inm_reg;

	reg [NB_MEM_CTRL-1:0] MEM_control_reg;
	reg [NB_WB_CTRL-1:0] WB_control_reg;	
	reg [`ADDRWIDTH-1:0] pc_reg;
	
	reg reg_write, halt_detected;

	assign o_MEM_control    = MEM_control_reg;
	assign o_WB_control     = WB_control_reg;
	assign o_write_register = write_reg;	
	assign o_alu_result     = alu_result_reg;
	assign o_data_write     = mem_data_reg;
	assign o_data_inm       = data_inm_reg;
	assign o_pc             = pc_reg;
	assign o_reg_write      = reg_write;
	
	assign o_halt_detected = halt_detected;

	initial begin
		write_reg = 0;	
		mem_data_reg = 0;
		alu_result_reg = 0;
		data_inm_reg = 0;

		MEM_control_reg = 0;
		WB_control_reg = 0;	
		pc_reg = 0;
		
		reg_write = 0;
		halt_detected = 0;
	end

	always @(negedge i_clock)
		begin
			if (i_reset)
				begin
					MEM_control_reg <= 6'b0;
					WB_control_reg  <= 3'b0;					
					pc_reg          <= {`ADDRWIDTH{1'b0}};				
					write_reg       <= 5'b0;					
					alu_result_reg  <= 32'b0;
					mem_data_reg    <= 32'b0;
					data_inm_reg    <= 32'b0;
					reg_write       <= 1'b0;					
				end
			else
				begin
					if (i_enable_pipe)
						begin
							halt_detected   <= i_halt_detected;
							MEM_control_reg <= i_MEM_control;
							WB_control_reg  <= i_WB_control;					
							pc_reg          <= i_pc;					
							write_reg       <= i_write_register;					
							alu_result_reg  <= i_alu_result;
							mem_data_reg    <= i_data_write;
							data_inm_reg    <= i_data_inm;
							reg_write       <= i_WB_control[2];
						end
					else
						begin
							halt_detected   <= halt_detected;
							MEM_control_reg <= MEM_control_reg;
							WB_control_reg  <= WB_control_reg;					
							pc_reg          <= pc_reg;					
							write_reg       <= write_reg;					
							alu_result_reg  <= alu_result_reg;
							mem_data_reg    <= mem_data_reg;
							data_inm_reg    <= data_inm_reg;
							reg_write       <= reg_write;
						end
				end

		end

endmodule