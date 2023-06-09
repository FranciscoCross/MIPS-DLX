`include "parameters.vh"

module tb_PIPELINE;

	// Inputs
	reg clock;
	reg i_reset;
	reg [NB_DATA-1:0] i_inst_load;
	reg [NB_DATA-1:0] i_addr_inst_load;
	reg i_en_write;
	reg i_en_read;
	reg i_enable_mem;
	reg i_enable_pipe;
	reg i_debug_unit;
	reg [NB_REG-1:0] i_addr_debug_unit;
	reg [`ADDRWIDTH-1:0] i_addr_mem_debug_unit;
	reg i_ctrl_read_debug_reg;
	reg i_ctrl_wr_debug_mem;
	reg i_ctrl_addr_debug_mem;

	// Outputs
	wire o_bit_sucio;
	wire [NB_DATA-1:0] o_data_send_pc;
	wire [NB_DATA-1:0] o_data_reg_debug_unit;
	wire [NB_DATA-1:0] o_data_mem_debug_unit;
	wire [N_BITS-1:0] o_count_cycles;
	wire o_halt;

	// Instantiate the pipeline module
	pipeline pipeline (
		.clock(clock),
		.i_reset(i_reset),
		.i_inst_load(i_inst_load),
		.i_addr_inst_load(i_addr_inst_load),
		.i_en_write(i_en_write),
		.i_en_read(i_en_read),
		.i_enable_mem(i_enable_mem),
		.i_enable_pipe(i_enable_pipe),
		.i_debug_unit(i_debug_unit),
		.i_addr_debug_unit(i_addr_debug_unit),
		.i_addr_mem_debug_unit(i_addr_mem_debug_unit),
		.i_ctrl_read_debug_reg(i_ctrl_read_debug_reg),
		.i_ctrl_wr_debug_mem(i_ctrl_wr_debug_mem),
		.i_ctrl_addr_debug_mem(i_ctrl_addr_debug_mem),
		.o_bit_sucio(o_bit_sucio),
		.o_data_send_pc(o_data_send_pc),
		.o_data_reg_debug_unit(o_data_reg_debug_unit),
		.o_data_mem_debug_unit(o_data_mem_debug_unit),
		.o_count_cycles(o_count_cycles),
		.o_halt(o_halt)
	);

	// Clock generation
	always #5 clock = ~clock;

	// Initialize inputs
	initial begin
		clock = 0;
		i_reset = 0;
		i_inst_load = 0;
		i_addr_inst_load = 0;
		i_en_write = 0;
		i_en_read = 0;
		i_enable_mem = 0;
		i_enable_pipe = 0;
		i_debug_unit = 0;
		i_addr_debug_unit = 0;
		i_addr_mem_debug_unit = 0;
		i_ctrl_read_debug_reg = 0;
		i_ctrl_wr_debug_mem = 0;
		i_ctrl_addr_debug_mem = 0;

		// Add stimulus here

		#100 $finish; // End the simulation after 100 time units
	end

	// Add testbench logic here

endmodule
