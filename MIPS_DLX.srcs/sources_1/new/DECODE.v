`include "parameters.vh"

module DECODE
	#(
		parameter NB_DATA       = 32,		
		parameter NB_EX_CTRL    = 7,
		parameter NB_MEM_CTRL   = 6,
		parameter NB_WB_CTRL    = 3,		
		parameter NB_OPCODE     = 6,
		parameter NB_REG        = 5				
	)
	(
		input wire i_clock,
		input wire i_reset,    

		
		input wire  i_ctrl_read_debug_reg,
		input wire [NB_DATA-1:0] i_instruction,		
		input wire [NB_DATA-1:0] i_data_rw,
		input wire [NB_REG-1:0] i_write_register,

		input wire i_reg_write,		
		input wire [`ADDRWIDTH-1:0] i_pc,

		input wire [NB_REG-1:0] i_addr_debug_unit,

		input wire [NB_REG-1:0] i_EX_write_register, // write_register
		input wire [NB_REG-1:0] i_EX_rt, //usado por hazard detection
		input wire i_ID_EX_mem_read, //viene del latch ID_EX
		input wire i_EX_reg_write,
		input wire i_forward_A, //forward branch
		input wire i_forward_B,
		input wire [NB_DATA-1:0] i_data_forward_EX_MEM,


		output wire [NB_REG-1:0]    o_rs,
        output wire [NB_REG-1:0]    o_rt,
        output wire [NB_REG-1:0]    o_rd,

		output wire [NB_DATA-1:0]   o_data_ra,
		output wire [NB_DATA-1:0]   o_data_rb,
		output wire [NB_REG-1:0]    o_shamt,
		output wire [NB_DATA-1:0]   o_inm_ext,
		output wire [NB_OPCODE-1:0] o_function, 

		output wire [1:0] o_pc_src,	

		output wire o_branch_or_jump,
		
		output wire [`ADDRWIDTH-1:0] o_addr_register, 
		output wire [`ADDRWIDTH-1:0] o_addr_branch,
		output wire [`ADDRWIDTH-1:0] o_addr_jump,

		output wire o_pc_write,
		output wire o_IF_ID_write,	

		output wire [NB_DATA-1:0] o_data_reg_debug_unit,

		output wire [NB_EX_CTRL-1:0] o_EX_control,
		output wire [NB_MEM_CTRL-1:0] o_M_control, 
		output wire [NB_WB_CTRL-1:0] o_WB_control,
		output wire o_halt

	);
    wire wire_halt_detected;
    wire is_equal; 
    wire wire_stall; // se usa para ver si son iguales o no los registros fuentes para los branch
    wire wire_beq; 
    wire wire_bne; 
    wire wire_jump;
    
	wire [NB_REG-1:0]       wire_reg_dest; 
    wire [NB_REG-1:0]       wire_addres_reg_debug;
	wire [NB_DATA-1:0]      wire_inm_ext;
	wire [NB_DATA-1:0]      data_ra_branch;
	wire [NB_DATA-1:0]      data_rb_branch;
	wire [NB_WB_CTRL-1:0]   wire_WB_control;
	wire [NB_EX_CTRL-1:0]   wire_EX_control;
	wire [NB_MEM_CTRL-1:0]  wire_M_control;
	wire [NB_DATA-1:0]      reg_data_ra, reg_data_rb;
	

    assign o_rs =                   i_instruction[`RS_BIT];
	assign o_rt =                   i_instruction[`RT_BIT];
	assign o_rd =                   i_instruction[`RD_BIT];
	assign o_shamt =                i_instruction[`SHAMT_BIT];
	assign o_inm_ext =              wire_inm_ext;
	assign o_function =             i_instruction[`FUNC_BIT];
	assign o_branch_or_jump =       ((wire_beq && is_equal) | (wire_bne && !is_equal) | wire_jump);
	assign o_addr_register  =       reg_data_ra[`ADDRWIDTH-1:0];
	assign o_halt =                 wire_halt_detected;
	assign o_data_reg_debug_unit =  reg_data_ra;
	assign o_data_ra =              reg_data_ra;
	assign o_data_rb =              reg_data_rb;
	assign o_addr_jump =            i_pc + i_instruction[`ADDRWIDTH-1:0];
	assign o_EX_control =           (wire_stall) ? {NB_EX_CTRL{1'b0}} : wire_EX_control;
	assign o_M_control =            (wire_stall) ? {NB_MEM_CTRL{1'b0}} : wire_M_control;
	assign o_WB_control =           (wire_stall) ? {NB_WB_CTRL{1'b0}} : wire_WB_control;

	unit_hazard unit_hazard
	(
		.i_ID_rs(i_instruction[`RS_BIT]),
		.i_ID_rt(i_instruction[`RT_BIT]),
		.i_EX_reg_write(i_EX_reg_write),
		.i_EX_write_register(i_EX_write_register),
		.i_EX_rt(i_EX_rt),
		.i_ID_EX_mem_read(i_ID_EX_mem_read),		
		.i_halt(wire_halt_detected),
		.o_stall(wire_stall),
		.o_pc_write(o_pc_write),
		.o_IF_ID_write(o_IF_ID_write)
	);

	unit_branch unit_branch
	(
		.i_pc(i_pc),
		.i_inm_ext(wire_inm_ext[`ADDRWIDTH-1:0]),

		.i_data_ra(data_ra_branch),
		.i_data_rb(data_rb_branch),

		.o_is_equal(is_equal),
		.o_branch_address(o_addr_branch)
	);	
	mux2 #(.NB_DATA(NB_REG)) mux_read_debug
	(
		.i_A(i_addr_debug_unit),
		.i_B(i_instruction[`RS_BIT]),
		.i_SEL(i_ctrl_read_debug_reg),
		.o_OUT(wire_addres_reg_debug)
	);

	bank_register banco_registros
	(
		.i_clock(i_clock),
		.i_reset(i_reset),		
		//.enable_i(enable_i),
		
		.i_rw(i_reg_write),		
		
		.i_addr_ra(wire_addres_reg_debug),
		.i_addr_rb(i_instruction[`RT_BIT]),

		.i_addr_rw(i_write_register),
		.i_data_rw(i_data_rw),
		
		.o_data_ra(reg_data_ra),
		.o_data_rb(reg_data_rb)
		
	);
	
	unit_control unidad_de_control
	(		
		.i_op_code(i_instruction[`OP_CODE]),
        .i_function(i_instruction[`FUNC_BIT]),
        .o_EX_control(wire_EX_control),
        .o_M_control(wire_M_control),
        .o_WB_control(wire_WB_control),
		.o_pc_src(o_pc_src),

		.o_beq(wire_beq),
		.o_bne(wire_bne),
		.o_jump(wire_jump),


		.o_halt_detected(wire_halt_detected)		

	);
	ext_signo ext_signo
	(
		.i_unextended(i_instruction[`INM_BIT]),
		.o_extended(wire_inm_ext)
	);		

	mux2#(.NB_DATA(NB_DATA)) mux_reg_A
	(
		.i_A(i_data_forward_EX_MEM_i), 
		.i_B(reg_data_ra),
		.i_SEL(i_forward_A),
		.o_OUT(data_ra_branch)
	);

	mux2#(.NB_DATA(NB_DATA)) mux_reg_B
	(
		.i_A(i_data_forward_EX_MEM_i), 
		.i_B(reg_data_rb),
		.i_SEL(i_forward_B),
		.o_OUT(data_rb_branch)
	);

endmodule

