module EXECUTE
	#(
		parameter NB_DATA       = 32,
		parameter NB_REG        = 5,
		parameter NB_FUNCTION   = 6,
		parameter NB_ALU_OP     = 3, 
		parameter NB_EX_CTRL    = 7,
		parameter NB_OP_ALU     = 4
	)
	(
		input wire [NB_FUNCTION-1:0] i_function,		
		input wire [NB_DATA-1:0]    i_data_ra,
		input wire [NB_DATA-1:0]    i_data_rb,
		input wire [NB_DATA-1:0]    i_data_inm,

		input wire [NB_REG-1:0]	    i_shamt,
		input wire [NB_REG-1:0]	    i_rs, 
        input wire [NB_REG-1:0]     i_rt,
        input wire [NB_REG-1:0]     i_rd,

		input wire [NB_EX_CTRL-1:0] i_EX_control,

		input wire [NB_REG-1:0]     i_EX_MEM_write_reg, // addres de reg a escribir
		input wire [NB_REG-1:0]     i_MEM_WB_write_reg,

		input wire i_EX_MEM_reg_write, //escritura en reg ?
		input wire i_MEM_WB_reg_write,

		input wire [NB_DATA-1:0]   i_EX_MEM_result_alu,
		input wire [NB_DATA-1:0]   i_MEM_WB_data,
		
		output wire [NB_DATA-1:0]  o_data_write_mem,
		output wire [NB_REG-1:0]   o_write_register,
		output wire [NB_DATA-1:0]  o_result_alu
	);
	
	wire [NB_DATA-1:0]  wire_input_alu_A;  //entradas a la alu
    wire [NB_DATA-1:0]  wire_input_alu_B;
	wire [NB_DATA-1:0]  out_mux_forwardA;
    wire [NB_DATA-1:0]  out_mux_forwardB;

	wire [1:0]  src_forwardA;
	wire [1:0]  src_forwardB;

	assign o_data_write_mem = out_mux_forwardB;

	wire [3:0] cod_op_alu;

    /*
    El alu control me ayuda a generar un ALU OPCODE (4bits)
    en funcion de codigo de FUNCION(6bits) y  condigo de ALU OPCODE (3 bits) 
    */ 
	
    alu_control alu_control
	(
		.i_function(i_function),
		.i_alu_op(i_EX_control[2:0]), //ALU OPERATION
		.o_alu_op(cod_op_alu) //basicamente me da un bit mas de alu opcode
	);	

    /*
    Alu en la que se manda el valor A y el valor B 
    en que se aplica una operacion en funcion del OPCODE generado por el alu control 
    */ 
	ALU#(.N_BITS(NB_DATA),
	     .N_BITS_OP(NB_OP_ALU)
	) alu (
		.i_A(wire_input_alu_A),
		.i_B(wire_input_alu_B),
		.i_OP(cod_op_alu),
		.o_RES(o_result_alu)		
	);
    /*
    Unidad de cortocircuito que se encarga de elegir la fuente de fordward en 
    funcion del uso de los valores en las diferentes etapas 
    */
	unit_forward unit_forward
	(
		.i_ID_EX_rs(i_rs),
		.i_ID_EX_rt(i_rt),

		.i_EX_MEM_write_reg(i_EX_MEM_write_reg),
		.i_MEM_WB_write_reg(i_MEM_WB_write_reg),
		.i_EX_MEM_reg_write(i_EX_MEM_reg_write),
		.i_MEM_WB_reg_write(i_MEM_WB_reg_write),

		.o_forward_A(src_forwardA),
		.o_forward_B(src_forwardB) 
	);
	/* 
    MUX es manejado por la unidad de forward
    */
	mux3 #(.NB_DATA(NB_DATA))mux_forwardA
	(
		.i_A(i_data_ra), //00
		.i_B(i_EX_MEM_result_alu), //01
		.i_C(i_MEM_WB_data), //10
		.i_SEL(src_forwardA),
		.o_OUT(out_mux_forwardA)
	);
    /* 
    MUX es manejado por la unidad de forward
    */
	mux3 #(.NB_DATA(NB_DATA))mux_forwardB
	(
		.i_A(i_data_rb),            //dato que viene derecho
		.i_B(i_EX_MEM_result_alu),  //dato que se adelanta porque todavia no termino la instruccion por eso el forward
		.i_C(i_MEM_WB_data),        //dato que se adelanta porque todavia no termino la instruccion por eso el forward
		.i_SEL(src_forwardB),       //selector de Unit forward que sabe que elegir
		.o_OUT(out_mux_forwardB)
	);

    /*
    CON LOS DOS MUX DE ABAJO ELIJO DE DONDE SALE LOS VALORE S DE A Y B
    TENIENDO EN CUENTA LA OPCION DE FORWARD o dato inmediato o si es una instruccion con shamt
    esto se decide en la UNIDAD DE CONTROL si cabe alguna duda de las posiciones es mejor repasar 
    dichos valores para tener en cuenta 
    */
	mux2 #(.NB_DATA(NB_DATA)) mux_alu_src_A	
	(
		.i_A(out_mux_forwardA), //0
		.i_B({{27'b0},i_shamt}), // sel = 1
		.i_SEL(i_EX_control[6]),
		.o_OUT(wire_input_alu_A)
	);

	mux2#(.NB_DATA(NB_DATA)) mux_alu_src_B	
	(
		.i_A(i_data_inm),
		.i_B(out_mux_forwardB), // sel = 1
		.i_SEL(i_EX_control[5]),
		.o_OUT(wire_input_alu_B)
	);

	/* 
    Aca decidimos cuan es el registro destino donde ira a parar el resultado
    */
	mux3#(.NB_DATA(NB_REG)) mux_reg_dest
	(
		.i_A(i_rt), // tipo I 00
		.i_B(i_rd), // tipo R 01
		.i_C(5'd31), // jumps and link 10		
		.i_SEL(i_EX_control[4:3]),
		.o_OUT(o_write_register)
	);

endmodule