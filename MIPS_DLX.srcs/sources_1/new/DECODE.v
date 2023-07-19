`include "parameters.vh"  // Incluir archivo de parámetros

module DECODE
	#(
		parameter NB_DATA       = 32,    // Tamaño del bus de datos
		parameter NB_EX_CTRL    = 7,     // Tamaño del bus de control de la etapa EX
		parameter NB_MEM_CTRL   = 6,     // Tamaño del bus de control de la etapa MEM
		parameter NB_WB_CTRL    = 3,     // Tamaño del bus de control de la etapa WB
		parameter NB_OPCODE     = 6,     // Tamaño del campo de código de operación
		parameter NB_REG        = 5      // Tamaño del bus de registros
	)
	(
		input wire i_clock,     // Señal de reloj
		input wire i_reset,     // Señal de reinicio
		input wire i_enable,     // Señal de enable

		input wire  i_ctrl_read_debug_reg,     		// Señal de control para leer el registro de depuración
		input wire [NB_DATA-1:0] i_instruction,     // Bus de datos que contiene la instrucción
		input wire [NB_DATA-1:0] i_data_rw,     	// Bus de datos para lectura/escritura en memoria
		input wire [NB_REG-1:0] i_write_register,   // Registro de destino para escritura

		input wire i_reg_write,     		// Señal de control para escritura en registros
		input wire [`ADDRWIDTH-1:0] i_pc,   // Contador de programa

		input wire [NB_REG-1:0] i_addr_debug_unit,     	// Dirección para acceder a la unidad de depuración

		input wire [NB_REG-1:0] i_EX_write_register_usage,    // Registro de escritura desde la etapa EX
		input wire [NB_REG-1:0] i_EX_rt,     			// Registro de destino desde la etapa EX
		input wire i_ID_EX_mem_read,     				// Señal de control desde el registro de la etapa ID/EX para lectura de memoria
		input wire i_EX_reg_write,     					// Señal de control desde la etapa EX para escritura en registros
		input wire i_forward_A,     					// Señal de control para adelantar datos A
		input wire i_forward_B,     					// Señal de control para adelantar datos B
		input wire [NB_DATA-1:0] i_data_forward_EX_MEM,	// Datos adelantados desde la etapa EX/MEM

		output wire [NB_REG-1:0]    o_rs,     // Registro fuente A de la instrucción
		output wire [NB_REG-1:0]    o_rt,     // Registro fuente B de la instrucción
		output wire [NB_REG-1:0]    o_rd,     // Registro destino de la instrucción

		output wire [NB_DATA-1:0]   o_data_ra,     	// Datos del registro fuente A
		output wire [NB_DATA-1:0]   o_data_rb,   	// Datos del registro fuente B
		output wire [NB_REG-1:0]    o_shamt,     	// Campo de desplazamiento en la instrucción
		output wire [NB_DATA-1:0]   o_inm_ext,     	// Inmediato extendido
		output wire [NB_OPCODE-1:0] o_function,     // Campo de código de función

		output wire [1:0] o_pc_src,     // Selección de origen de PC

		output wire o_branch_or_jump,   // Señal de control para rama o salto

		output wire [`ADDRWIDTH-1:0] o_addr_register, // Dirección del registro
		output wire [`ADDRWIDTH-1:0] o_addr_branch,   // Dirección de salto para instrucción de rama
		output wire [`ADDRWIDTH-1:0] o_addr_jump,     // Dirección de salto para instrucción de salto

		output wire o_pc_write,     // Señal de control para escritura en el contador de programa
		output wire o_IF_ID_write,     // Señal de control para escritura en el latch IF/ID

		output wire [NB_DATA-1:0] o_data_reg_debug_unit,     // Datos del registro de la unidad de depuración

		output wire [NB_EX_CTRL-1:0] o_EX_control,     // Bus de control para la etapa EX
		output wire [NB_MEM_CTRL-1:0] o_M_control,     // Bus de control para la etapa MEM
		output wire [NB_WB_CTRL-1:0] o_WB_control,     // Bus de control para la etapa WB
		output wire o_halt     // Señal de control para detener la ejecución
	);
	wire wire_halt_detected;     // Señal de detección de parada
	wire is_equal;      // Señal para comparación de igualdad
	wire wire_stall;     // Señal de retardo para comprobar la igualdad de los registros fuente en instrucciones de salto
	wire wire_beq;     // Señal de control para instrucción BEQ (igualdad)
	wire wire_bne;     // Señal de control para instrucción BNE (no igualdad)
	wire wire_jump;     // Señal de control para instrucción de salto

	wire [NB_REG-1:0]       wire_addr_ra;     // Dirección para acceder al registro de depuración
	wire [NB_DATA-1:0]      wire_inm_ext;     // Inmediato extendido
	wire [NB_DATA-1:0]      data_ra_branch;     // Datos del registro fuente A para instrucción de salto
	wire [NB_DATA-1:0]      data_rb_branch;     // Datos del registro fuente B para instrucción de salto
	wire [NB_WB_CTRL-1:0]   wire_WB_control;     // Bus de control para la etapa WB
	wire [NB_EX_CTRL-1:0]   wire_EX_control;     // Bus de control para la etapa EX
	wire [NB_MEM_CTRL-1:0]  wire_M_control;     // Bus de control para la etapa MEM
	wire [NB_DATA-1:0]      reg_data_ra, reg_data_rb;     // Datos del registro fuente A y B
	wire [`ADDRWIDTH-1:0] wire_addr_branch;     // Dirección de salto para instrucción de salto

	// Register for saving the output values
	reg [NB_REG-1:0]  rs_reg;
	reg [NB_REG-1:0]  rt_reg;
	reg [NB_REG-1:0]  rd_reg;
	reg [NB_REG-1:0]    reg_shamt;     	// Campo de desplazamiento en la instrucción
	reg [NB_DATA-1:0]   reg_inm_ext;    	// Inmediato extendido
	reg [NB_OPCODE-1:0] reg_function;     // Campo de código de función
	reg [NB_WB_CTRL-1:0]   reg_WB_control;     // Bus de control para la etapa WB
	reg [NB_EX_CTRL-1:0]   reg_EX_control;     // Bus de control para la etapa EX
	reg [NB_MEM_CTRL-1:0]  reg_M_control;     // Bus de control para la etapa MEM
	reg [`ADDRWIDTH-1:0] reg_addr_branch;   // Dirección de salto para instrucción de rama
	reg [`ADDRWIDTH-1:0] reg_addr_jump;     // Dirección de salto para instrucción de salto
		
	reg [NB_DATA-1:0]   reg_inm_ext;     	// Inmediato extendido
	reg reg_branch_or_jump;   // Señal de control para rama o salto
	reg reg_halt;   // Señal de control para rama o salto

	// Asignaciones de las salidas a las señales internas
	assign o_rs =                   rs_reg;
	assign o_rt =                   rt_reg;
	assign o_rd =                   rd_reg;
	assign o_shamt =                reg_shamt;
	assign o_function =             reg_function;
	assign o_data_reg_debug_unit =  reg_data_ra;
	assign o_data_ra =              reg_data_ra;
	assign o_data_rb =              reg_data_rb;
	assign o_EX_control =           reg_EX_control;
	assign o_M_control =            reg_M_control;
	assign o_WB_control =           reg_WB_control;
	assign o_addr_register  =       reg_data_ra[`ADDRWIDTH-1:0];
	assign o_addr_jump =            reg_addr_jump;
	assign o_addr_branch =          reg_addr_branch;
	assign o_inm_ext =              reg_inm_ext;
	assign o_branch_or_jump =       reg_branch_or_jump;
	assign o_halt =                 reg_halt;


	initial begin
		rs_reg = 0;
		rt_reg = 0;
		rd_reg = 0;
		reg_shamt    = 0;
		reg_function = 0;

		reg_addr_jump = 0;
		reg_addr_branch = 0;

		reg_EX_control = 0;
		reg_M_control =  0;
		reg_WB_control = 0;

		reg_inm_ext = 0;
		reg_branch_or_jump = 0;
		reg_halt = 0;
	end


	always @(posedge i_clock)
	begin
		if(i_reset)
		begin	
			rs_reg <= 0;
			rt_reg <= 0;
			rd_reg <= 0;
			reg_shamt <=    0;
			reg_function <= 0;

			reg_addr_jump <= 0;
			reg_addr_branch <= 0;

			reg_EX_control <= 0;
			reg_M_control <=  0;
			reg_WB_control <= 0;

			reg_inm_ext <= 0;
			reg_branch_or_jump <= 0;
			reg_halt <= 0;
		end
		else
		begin
			rs_reg <= i_instruction[`RS_BIT];
			rt_reg <= i_instruction[`RT_BIT];
			rd_reg <= i_instruction[`RD_BIT];
			reg_shamt <=    i_instruction[`SHAMT_BIT];
			reg_function <= i_instruction[`FUNC_BIT];
			
			reg_addr_jump <=   i_instruction[`ADDRWIDTH-1:0];
			reg_addr_branch <= wire_addr_branch;

			reg_EX_control <=  (wire_stall) ? {NB_EX_CTRL{1'b0}} : wire_EX_control;
			reg_M_control <=   (wire_stall) ? {NB_MEM_CTRL{1'b0}} : wire_M_control;
			reg_WB_control <=  (wire_stall) ? {NB_WB_CTRL{1'b0}} : wire_WB_control;
			
			reg_inm_ext <=  wire_inm_ext;
			reg_branch_or_jump <= ((wire_beq && is_equal) | (wire_bne && !is_equal) | wire_jump);
			reg_halt <= wire_halt_detected;
		end
	end

	// Instancias de los módulos y asignaciones de las señales
	unit_branch unit_branch
	(
		.i_pc(i_pc), 															//Representa la dirección de la próxima instrucción a ejecutar.
		.i_inm_ext(wire_inm_ext[`ADDRWIDTH-1:0]), //Representa la dirección de destino del salto condicional.
		.i_data_ra(data_ra_branch),								//Contiene el valor del registro RA (Registro A).
		.i_data_rb(data_rb_branch), 							//Contiene el valor del registro RB (Registro B).

		.o_is_equal(is_equal),
		.o_branch_address(wire_addr_branch) //Contiene la dirección de destino del salto incondicional.
	);
	
	unit_hazard unit_hazard
	(
		.i_ID_rs(i_instruction[`RS_BIT]),												//RS de instruccion ACTUAL
		.i_ID_rt(i_instruction[`RT_BIT]),												//RT de instruccion ACTUAL
		.i_EX_reg_write(i_reg_write), 												//Si la etapa que sigue (EXECUTION) escribe en un registro
		.i_EX_write_register_usage(i_EX_write_register_usage),	//Registro que escribe la etapa que sigue (EXECUTION) 
		.i_EX_rt(i_EX_rt),																			//RT de la estapa que sigue (EXECUTION) o instruccion PASADA
		.i_ID_EX_mem_read(i_ID_EX_mem_read),										//La instruccion PASADA escribira en MEMORIA
		.i_halt(wire_halt_detected),
		.o_stall(wire_stall),
		.o_pc_write(o_pc_write),																//cuando hay un stall aca deshabilita el PC ya que asi no sigue trajento instrucciones
		.o_IF_ID_write(o_IF_ID_write)
	);

	unit_control unit_control
	(
		.i_enable(i_enable),
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

	bank_register bank_register
	(
		.i_clock(i_clock),
		.i_reset(i_reset),
		.i_rw(i_reg_write),
		.i_addr_ra(wire_addr_ra),
		.i_addr_rb(i_instruction[`RT_BIT]),
		.i_addr_rw(i_write_register),
		.i_data_rw(i_data_rw),
		.o_data_ra(reg_data_ra),
		.o_data_rb(reg_data_rb)
	);

	//Con este mux lo que hacemos es elegir si queremos conectar la debug unit para que podamos leer los registros despues de una ejecucion 
	mux2 #(.NB_DATA(NB_REG)) mux_read_debug
	(
		.i_A(i_instruction[`RS_BIT]),
		.i_B(i_addr_debug_unit),
		.i_SEL(i_ctrl_read_debug_reg),
		.o_OUT(wire_addr_ra)
	);


	mux2#(.NB_DATA(NB_DATA)) mux_reg_A
	(
		.i_A(reg_data_ra),
		.i_B(i_data_forward_EX_MEM),
		.i_SEL(i_forward_A),
		.o_OUT(data_ra_branch)
	);

	mux2#(.NB_DATA(NB_DATA)) mux_reg_B
	(
		.i_A(reg_data_rb),
		.i_B(i_data_forward_EX_MEM),
		.i_SEL(i_forward_B),
		.o_OUT(data_rb_branch)
	);

	ext_signo ext_signo
	(
		.i_unextended(i_instruction[`INM_BIT]),
		.o_extended(wire_inm_ext)
	);

endmodule
