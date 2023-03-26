`include "parameters.vh"

module pipeline
	#(		
		parameter NB_DATA = 32,
		parameter NB_OPCODE = 6,
		parameter NB_FUNCTION = 6,
		parameter NB_REG  = 5,
		parameter NB_EX_CTRL  = 7,
		parameter NB_MEM_CTRL = 6,
		parameter NB_WB_CTRL  = 3,
		parameter N_REGISTER = 32,
		parameter N_BYTES    = 4,
		parameter N_BITS = 8		
	)
	(
		input wire clock,
		input wire i_reset,
		input wire [NB_DATA-1:0] i_inst_load,
		input wire [NB_DATA-1:0] i_addr_inst_load,			
		input wire i_enable_pipe,
		input wire [NB_REG-1:0] i_addr_debug_unit, //addr de registro debug
		input wire i_ctrl_wr_debug_mem, //leyendo para debug mem
		input wire i_ctrl_addr_debug_mem, 
		output wire [NB_DATA-1:0] o_data_send_pc,
		output wire [NB_DATA-1:0] o_data_reg_debug_unit,
		output wire o_halt
	);




	wire [`ADDRWIDTH-1:0]   wire_i_pcF_ID; 
    wire [`ADDRWIDTH-1:0]   wire_i_pcD_EX;
    wire [`ADDRWIDTH-1:0]   wire_pc_EX_MEM; 
    wire [`ADDRWIDTH-1:0]   wire_pc_MEM_WB;
    wire [`ADDRWIDTH-1:0]   wire_pc_WB; 
    wire [`ADDRWIDTH-1:0]   wire_pc_adder;
	wire [NB_DATA-1:0]  wire_inst_IF; 
    wire [NB_DATA-1:0]  wire_inst_IF_ID;


	/* output data stage ID */
	wire [NB_DATA-1:0]  wire_data_ra_ID; 
    wire [NB_DATA-1:0]  wire_data_rb_ID; 
    wire [NB_DATA-1:0]  wire_inm_ext_ID;
    /* output data latch ID-EX */
    wire [NB_DATA-1:0]  wire_data_ra_ID_EX; 
    wire [NB_DATA-1:0]  wire_data_rb_ID_EX; 
    wire [NB_DATA-1:0]  wire_inm_ext_ID_EX;

	wire [NB_EX_CTRL-1:0]   wire_EX_ctrl_ID; 
	wire [NB_MEM_CTRL-1:0]  wire_M_ctrl_ID;
	wire [NB_WB_CTRL-1:0]   wire_WB_ctrl_ID;
	/* signal unit control per stage*/
	/* ------------------------------------------ */
	wire [NB_EX_CTRL-1:0]   wire_EX_ctrl_ID_EX;
	wire [NB_MEM_CTRL-1:0]  wire_M_ctrl_ID_EX;
	wire [NB_WB_CTRL-1:0]   wire_WB_ctrl_ID_EX;
	/* ------------------------------------------ */
	wire [NB_MEM_CTRL-1:0]  wire_M_ctrl_EX_MEM;
	wire [NB_WB_CTRL-1:0]   wire_WB_ctrl_EX_MEM;
	/* ------------------------------------------ */
	wire [NB_MEM_CTRL-1:0]  wire_M_ctrl_MEM;
	wire [NB_WB_CTRL-1:0]   wire_WB_ctrl_MEM_WB;
	/* ------------------------------------------ */


	wire [NB_FUNCTION-1:0]  wire_function_ID_EX;

	/* registros operandos */

	wire [NB_REG-1:0]   wire_rt_ID; 
    wire [NB_REG-1:0]   wire_rs_ID; 
    wire [NB_REG-1:0]   wire_rd_ID;
	wire [NB_REG-1:0]   wire_rt_ID_EX; 
    wire [NB_REG-1:0]   wire_rs_ID_EX; 
    wire [NB_REG-1:0]   wire_rd_ID_EX;

	wire [NB_REG-1:0]   wire_shamt_ID;
	wire [NB_REG-1:0]   wire_shamt_ID_EX;
	wire [NB_REG-1:0]   wire_write_reg_EX;
	wire [NB_FUNCTION-1:0]  wire_function_ID;

	/* Direccion a cargar en PC */

	wire wire_branch_or_jump_IF_ID;

	wire [`ADDRWIDTH-1:0]   wire_addr_reg_ID_IF; 
	wire [`ADDRWIDTH-1:0]   wire_addr_branch_ID_IF;
	wire [`ADDRWIDTH-1:0]   wire_addr_jump_ID_IF;

    /* Instruccion LUI */    
    wire [NB_DATA-1:0]  wire_inm_ext_MEM_WB;
    wire [NB_DATA-1:0]  wire_inm_ext_WB;

    /* STORE */
    wire [NB_DATA-1:0]  wire_write_data_mem_EX_MEM;

	wire [NB_DATA-1:0]  wire_data_write_WB_ID;

	/* wireion entre EX y reg_EX_MEM */
	wire [NB_DATA-1:0]  wire_result_alu_EX;
    wire [NB_DATA-1:0]  wire_result_alu_EX_MEM;

	wire [1:0] wire_pc_src_ID_IF;

	/* wire UNIT FORWARDING EN EX*/
	wire wire_reg_write_MEM_EX;
	wire wire_reg_write_WB_EX;


	/* **************************** */

	wire forw_branch_A, forw_branch_B;

	wire wire_pc_write;

	wire [1:0] wire_mem_to_reg_WB;
	wire [NB_DATA-1:0] wire_alu_result_WB;
	wire [NB_DATA-1:0] wire_write_data_MEM;

	wire [NB_REG-1:0] wire_write_reg_MEM_WB;
	wire [NB_REG-1:0] wire_write_reg_WB_ID; // registro a escribir en ID
	wire [NB_DATA-1:0] wire_mem_data_MEM_WB;
	wire [NB_DATA-1:0] wire_mem_data_WB;

	/* HAZARD */
	wire wire_IF_ID_write;

	/* wireiones halt*/
	wire wire_i_halt_detectedF_ID_EX;
	wire wire_i_halt_detectedD_EX_MEM;
	wire wire_halt_detected_EX_MEM_WB;
    
 	FETCH instruccion_fetch
	(	
    .i_clk(clock),
    .i_reset(i_reset),
    .i_enable(wire_pc_write&&i_enable_pipe),
    .i_debug_unit(i_debug_unit),
    .i_Mem_WEn(i_en_write),
    .i_Mem_REn(i_en_read),
    .i_Mem_Data(i_inst_load),
    .i_PCsrc(wire_pc_src_ID_IF),
    .i_addr_register(wire_addr_reg_ID_IF),
    .i_addr_branch(wire_addr_branch_ID_IF),
    .i_addr_jump(wire_addr_jump_ID_IF),
    .i_jump_or_branch(wire_branch_or_jump_IF_ID),
    .i_wr_addr(i_addr_inst_load), 
    .o_instruction(wire_inst_IF),
    .o_PCAddr(wire_pc_adder)
	);  

	latch_IF_ID IF_ID
	(
		.i_clock(clock),		
		.i_enable(wire_IF_ID_write&&i_enable_pipe),					
		.i_instruction(wire_inst_IF),
		.i_pc(wire_pc_adder),		
		.o_instruction(wire_inst_IF_ID),	
		.o_pc(wire_i_pcF_ID)	

	);
	
	DECODE Decode_stage
	(
		.i_clock(clock),
		.i_reset(i_reset),    
		.i_ctrl_read_debug_reg(i_ctrl_read_debug_reg),
		.i_instruction(wire_inst_IF_ID),		
		.i_data_rw(wire_data_write_WB_ID),
		.i_write_register(wire_write_reg_WB_ID),
		.i_reg_write(wire_reg_write_WB_EX),		
		.i_pc(wire_i_pcF_ID),
		.i_addr_debug_unit(i_addr_debug_unit),
		.i_EX_write_register(wire_write_reg_EX), 
		.i_EX_rt(wire_rt_ID_EX), 
		.i_ID_EX_mem_read(wire_M_ctrl_EX_MEM[5]), 
		.i_EX_reg_write(wire_WB_ctrl_EX_MEM[2]),
		.i_forward_A(forw_branch_A), 
		.i_forward_B(forw_branch_B),
		.i_data_forward_EX_MEM(),
		.o_rs(wire_rs_ID),
        .o_rt(wire_rt_ID),
        .o_rd(wire_rd_ID),
		.o_data_ra(wire_data_ra_ID),
		.o_data_rb(wire_data_rb_ID),
		.o_shamt(wire_shamt_ID),
		.o_inm_ext(wire_inm_ext_ID),
		.o_function(wire_function_ID), 
		.o_pc_src(wire_pc_src_ID_IF),	
		.o_branch_or_jump(wire_branch_or_jump_IF_ID),
		.o_addr_register(wire_addr_reg_ID_IF) ,
		.o_addr_branch(wire_addr_branch_ID_IF),
		.o_addr_jump(wire_addr_jump_ID_IF),
		.o_pc_write(wire_pc_write),
		.o_IF_ID_write(wire_IF_ID_write),	
		.o_data_reg_debug_unit(o_data_reg_debug_unit),
		.o_EX_control(wire_EX_ctrl_ID),
		.o_M_control(wire_M_ctrl_ID), 
		.o_WB_control(wire_WB_ctrl_ID),
		.o_halt(wire_i_halt_detectedF_ID_EX)
	);

 	latch_ID_EX ID_EX
	(
		.i_clock(clock),   
		.i_reset(i_reset),
		.i_enable(i_enable_pipe),
		.i_halt_detected(wire_i_halt_detectedF_ID_EX),
		.i_pc(wire_i_pcF_ID),
		.i_rs(wire_rs_ID), 
		.i_rt(wire_rt_ID), 
		.i_rd(wire_rd_ID),
		.i_shamt(wire_shamt_ID),
		.i_function(wire_function_ID),
		.i_data_ra(wire_data_ra_ID),
		.i_data_rb(wire_data_rb_ID),
		.i_inm_ext(wire_inm_ext_ID),
		.i_EX_control(wire_EX_ctrl_ID),
		.i_M_control(wire_M_ctrl_ID),
		.i_WB_control(wire_WB_ctrl_ID),
	    .o_data_ra(wire_data_ra_ID_EX),
		.o_data_rb(wire_data_rb_ID_EX),
		.o_inm_ext(wire_inm_ext_ID_EX),
		.o_shamt(wire_shamt_ID_EX),
		.o_pc(wire_i_pcD_EX),
		.o_rs(wire_rs_ID_EX), 
		.o_rt(wire_rt_ID_EX), 
		.o_rd(wire_rd_ID_EX),
		.o_function(wire_function_ID_EX),
		.o_EX_control(wire_EX_ctrl_ID_EX),
		.o_M_control(wire_M_ctrl_ID_EX),
		.o_WB_control(wire_WB_ctrl_ID_EX),
		.o_halt_detected(wire_i_halt_detectedD_EX_MEM)	
	);

 	EXECUTE Execute_stage
	(
		.i_function(wire_function_ID_EX),		
		.i_data_ra(wire_data_ra_ID_EX),
		.i_data_rb(wire_data_rb_ID_EX),
		.i_data_inm(wire_inm_ext_ID_EX),
		.i_shamt(wire_shamt_ID_EX),
		.i_rs(wire_rs_ID_EX), 
        .i_rt(wire_rt_ID_EX),
        .i_rd(wire_rd_ID_EX),
		.i_EX_control(wire_EX_ctrl_ID_EX),
		.i_EX_MEM_write_reg(wire_write_reg_MEM_WB),
		.i_MEM_WB_write_reg(wire_write_reg_WB_ID),
		.i_EX_MEM_reg_write(wire_reg_write_MEM_EX), 
		.i_MEM_WB_reg_write(wire_reg_write_WB_EX),
		.i_EX_MEM_result_alu(wire_result_alu_EX_MEM),
		.i_MEM_WB_data(wire_data_write_WB_ID),
		.o_data_write_mem(wire_write_data_mem_EX_MEM),
		.o_write_register(wire_write_reg_EX),
		.o_result_alu(wire_result_alu_EX)
    ); 

	latch_EX_MEM reg_EX_MEM
	(
		.i_clock(clock),
		.i_reset(i_reset),
		.i_enable_pipe(i_enable_pipe),
		.i_halt_detected(wire_i_halt_detectedD_EX_MEM),
		.i_WB_control(wire_WB_ctrl_EX_MEM),
		.i_MEM_control(wire_M_ctrl_EX_MEM),
		.i_alu_result(wire_result_alu_EX), //salida de la ALU de la etapa EX		
		.i_data_inm(wire_inm_ext_ID_EX), //LUI
		.i_data_write(wire_write_data_mem_EX_MEM), //store	
		.i_pc(wire_pc_EX_MEM),		
		.i_write_register(wire_write_reg_EX), //registro a escribir
	
		.o_WB_control(wire_WB_ctrl_MEM_WB),
		.o_MEM_control(wire_M_ctrl_MEM),
		.o_write_register(wire_write_reg_MEM_WB), //registro a escribir
		.o_pc(wire_pc_MEM_WB),
		.o_alu_result(wire_result_alu_EX_MEM),	
		.o_data_write(wire_write_data_MEM), 
		.o_data_inm(wire_inm_ext_MEM_WB), //dato inmediato a escribir en memoria	*/
		.o_halt_detected(wire_halt_detected_EX_MEM_WB),
		.o_reg_write(wire_reg_write_MEM_EX)
	);

	MEMORIA memory_stage
	(
		.i_clock(clock),
		.i_reset(i_reset),
		.i_enable_mem(i_enable_mem),
		.i_alu_result(wire_result_alu_EX_MEM[`ADDRWIDTH-1:0]),
		.i_MEM_control(wire_M_ctrl_MEM),
		.i_data_write(wire_write_data_MEM),

		.i_addr_mem_debug_unit(i_addr_mem_debug_unit),
		.i_ctrl_addr_debug_mem(i_ctrl_addr_debug_mem),
		.i_ctrl_wr_debug_mem(i_ctrl_wr_debug_mem),
		.o_bit_sucio(o_bit_sucio),
		.o_data_mem_debug_unit(o_data_mem_debug_unit),
		.o_mem_data(wire_mem_data_MEM_WB)	

	);

	latch_MEM_WB latch_MEM_WB
	(
		.i_clock(clock),
		.i_reset(i_reset),
		.i_enable_pipe(i_enable_pipe),
		.i_halt_detected(wire_halt_detected_EX_MEM_WB),
		.i_WB_control(wire_WB_ctrl_MEM_WB),


		.i_pc(wire_pc_MEM_WB),
		.i_mem_data(wire_mem_data_MEM_WB), //dato de la memoria
		.i_alu_result(wire_result_alu_EX_MEM), //resultado de la alu		
		.i_data_inm(wire_inm_ext_MEM_WB),// instruccion lui

		.i_write_register(wire_write_reg_MEM_WB), //registro a escribir		
		.o_mem_to_reg(wire_mem_to_reg_WB),
		.o_mem_data(wire_mem_data_WB),
		.o_alu_result(wire_alu_result_WB),
		.o_inm_ext(wire_inm_ext_WB),
		.o_pc(wire_pc_WB), //deberia entrar en la etapa ID 

		.o_write_register(wire_write_reg_WB_ID),// va tanto a ID como EX
		.o_reg_write(wire_reg_write_WB_EX), //va a EX para unit forward
		.o_halt_detected(o_halt)
		
	);

	WRITE_BACK stage_write_back
	(		
		.i_alu_result(wire_alu_result_WB),
		.i_pc(wire_pc_WB),
		.i_mem_data(wire_mem_data_WB),
		.i_mem_to_reg(wire_mem_to_reg_WB),
		.i_inm_ext(wire_inm_ext_WB),
		.o_data(wire_data_write_WB_ID) //dato a escribir en registro
	);


	branch_forward_unit branch_forward_unit
	(
		.i_ID_rs(wire_rs_ID),
		.i_ID_rt(wire_rt_ID),

		.i_EX_MEM_write_reg(wire_reg_write_MEM_EX),//write 
		.i_EX_MEM_reg_write(wire_write_reg_MEM_WB),//registro a escribir


		.o_forward_A(forw_branch_A),
		.o_forward_B(forw_branch_B)
	);

endmodule 