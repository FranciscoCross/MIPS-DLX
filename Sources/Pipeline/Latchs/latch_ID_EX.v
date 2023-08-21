`include "parameters.vh"

module latch_ID_EX
	#(
		parameter NB_DATA = 32,
		parameter NB_REG  = 5,
		parameter NB_FUNCTION = 6,
		parameter NB_EX_CTRL  = 7,
		parameter NB_MEM_CTRL = 6,
		parameter NB_WB_CTRL  = 3
	)
	(
		input wire i_clock,   
		input wire i_reset,
		input wire i_enable,
		input wire i_halt_detected,
		input wire [`ADDRWIDTH-1:0] i_pc,
		input wire [NB_REG-1:0]	i_rs, 
		input wire [NB_REG-1:0] i_rt, 
		input wire [NB_REG-1:0] i_rd,
		input wire [NB_REG-1:0]	i_shamt,

		input wire [NB_FUNCTION-1:0] i_function,
		input wire [NB_DATA-1:0] i_data_ra,
		input wire [NB_DATA-1:0] i_data_rb,
		input wire [NB_DATA-1:0] i_inm_ext,

		input wire [NB_EX_CTRL-1:0] i_EX_control,
		input wire [NB_MEM_CTRL-1:0] i_M_control,
		input wire [NB_WB_CTRL-1:0] i_WB_control,

		output wire [NB_DATA-1:0] o_data_ra,
		output wire [NB_DATA-1:0] o_data_rb,
		output wire [NB_DATA-1:0] o_inm_ext,

		output wire [NB_REG-1:0] o_shamt,

		output wire [`ADDRWIDTH-1:0] o_pc,
		output wire [NB_REG-1:0] o_rs, 
		output wire [NB_REG-1:0] o_rt, 
		output wire [NB_REG-1:0] o_rd,

		output wire [NB_FUNCTION-1:0] o_function,
		
		output wire [NB_EX_CTRL-1:0] o_EX_control,
		output wire [NB_MEM_CTRL-1:0] o_M_control,
		output wire [NB_WB_CTRL-1:0] o_WB_control,

		output wire o_halt_detected	
	);

	reg [`ADDRWIDTH-1:0] pc_reg;
	reg [NB_DATA-1:0] data_ra_reg; 
	reg [NB_DATA-1:0] data_rb_reg; 
	reg [NB_DATA-1:0] inm_ext_reg;
	
	reg [NB_REG-1:0] rs_reg; 
	reg [NB_REG-1:0] rt_reg; 
	reg [NB_REG-1:0] rd_reg; 
	reg [NB_REG-1:0] shamt_reg;

	reg [NB_FUNCTION-1:0] function_reg;
	reg halt_detected;
	reg [NB_EX_CTRL-1:0] EX_control_reg;
	reg [NB_MEM_CTRL-1:0] M_control_reg;
	reg [NB_WB_CTRL-1:0] WB_control_reg;


	assign o_halt_detected = halt_detected;

	initial begin
		pc_reg     	 	= {`ADDRWIDTH{1'b0}};
		data_ra_reg  	= 0;
		data_rb_reg  	= 0;
		inm_ext_reg  	= 0;
		shamt_reg    	= 0;
		function_reg	= 0;
		rs_reg			= 0;
		rt_reg 			= 0;
		rd_reg 			= 0;
		EX_control_reg	= 0;
		M_control_reg	= 0;
		WB_control_reg	= 0;
		halt_detected	= 0;
	end


	always @(negedge i_clock)
		begin
			if (i_reset)
				begin 
					pc_reg     	 <= {`ADDRWIDTH{1'b0}};
					data_ra_reg  <= 32'b0;
					data_rb_reg  <= 32'b0;
					inm_ext_reg  <= 32'b0;
					shamt_reg    <= 5'b0;
					function_reg <= 6'b0;

				end
			else
				begin
					if (i_enable)
						begin
							halt_detected <= i_halt_detected;
						    pc_reg        <= i_pc;
							data_ra_reg   <= i_data_ra;
							data_rb_reg   <= i_data_rb;
							inm_ext_reg   <= i_inm_ext;
							shamt_reg     <= i_shamt;
							function_reg  <= i_function;
						end
					else
						begin
							halt_detected <= halt_detected;
							pc_reg 	  <= pc_reg;
							data_ra_reg   <= data_ra_reg;
							data_rb_reg   <= data_rb_reg;
							inm_ext_reg   <= inm_ext_reg;
							shamt_reg     <= shamt_reg;
							function_reg  <= function_reg;
						end
				end
		end	

	always @(negedge i_clock)
		begin
			if (i_reset)
				begin
					rs_reg <= 5'b0;
					rt_reg <= 5'b0;
					rd_reg <= 5'b0;
				end
			else
				begin
					if (i_enable)
						begin
							rs_reg <= i_rs;
							rt_reg <= i_rt;
							rd_reg <= i_rd;
						end	
					else
						begin
							rs_reg <= rs_reg;
							rt_reg <= rt_reg;
							rd_reg <= rd_reg;
						end
				end
		end


	always @(negedge i_clock)
		begin
			if (i_reset)
				begin
					EX_control_reg <= 7'b0;
					M_control_reg  <= 6'b0;
					WB_control_reg <= 3'b0;
				end				
			else
				begin
					if (i_enable)
						begin
							EX_control_reg <= i_EX_control;
							M_control_reg  <= i_M_control;
							WB_control_reg <= i_WB_control;
						end
					else
						begin
							EX_control_reg <= EX_control_reg;
							M_control_reg  <= M_control_reg;
							WB_control_reg <= WB_control_reg;			
						end
				end				
		end

	assign o_pc    = pc_reg;
	assign o_data_ra = data_ra_reg;
	assign o_data_rb = data_rb_reg;
	assign o_inm_ext = inm_ext_reg;

	assign o_function = function_reg;
	assign o_shamt    = shamt_reg;

	assign o_rs      = rs_reg;
	assign o_rt      = rt_reg;
	assign o_rd      = rd_reg;

	assign o_EX_control = EX_control_reg;
	assign o_M_control = M_control_reg;
	assign o_WB_control = WB_control_reg;


endmodule 