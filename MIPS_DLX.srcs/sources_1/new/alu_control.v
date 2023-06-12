`include "parameters.vh"


/*
Modulo alu_control que tiene TRES puertos:
Pequeña unidad de control que sirve para generar las señales de control de la ALU

i_function: entrada que especifica la funcion deseada para la ALU.
i_alu_op: 	entrada que especifica la operacion a realizar por la ALU.
o_alu_op: 	salida que especifica la operacion FINAL que se enviará a la ALU.

El modulo tiene tres parámetros NB_FUNCTION, NB_ALU_OP y NB_OP_ALU, estos especifican el tamanio de las entradas y salidas.

El codigo utiliza cases para determinar la operacion final que se enviará a la ALU. 
La entrada i_alu_op se utiliza como el selector principal, y luego, en funcion de su valor, 
se elige una operacion específica de la ALU a partir de la entrada i_function. 
El resultado final se almacena en un registro reg_alu_op, que se asigna a la salida o_alu_op.
*/


module alu_control
	#(
		parameter NB_FUNCTION = 6, //6 bist para elegir la funcion de la ALU
		parameter NB_ALU_OP   = 3, //3 bits para la OPERACION a hacer
		parameter NB_OP_ALU   = 4  //4 bits Operacion/funcion final que se manda a la ALU

	)
	(
		input wire [NB_FUNCTION-1:0] i_function, // func
		input wire [NB_ALU_OP-1:0]   i_alu_op,   // ALUop
		output wire [NB_OP_ALU-1:0]  o_alu_op    // Operacion de la ALU
	);

	reg [NB_OP_ALU-1:0] reg_alu_op;
	
	initial begin
	   reg_alu_op = 0;
	end
	
	assign o_alu_op = reg_alu_op;
	/*
	R-Type:
	|	OPCODE	|	RS	|	RT	|	RD	| SHMAT	| FUNCT |
	I-Type:
	|	OPCODE	|	RS	|	RT	|	OFFSET  |
	*/
	always @(*)
		begin
			case (i_alu_op)
				`R_ALUCODE:	//Instrucciones de tipo R
					begin
						case (i_function)
							`SLL_FUNCTION    : reg_alu_op    = `SLL; 
							`SRL_FUNCTION    : reg_alu_op    = `SRL; 
							`SRA_FUNCTION    : reg_alu_op    = `SRA; 
							`SRLV_FUNCTION   : reg_alu_op    = `SRL;
							`SRAV_FUNCTION   : reg_alu_op    = `SRA; 
							`ADDU_FUNCTION   : reg_alu_op    = `ADD;
							`SLLV_FUNCTION   : reg_alu_op    = `SLL;
							`SUBU_FUNCTION   : reg_alu_op    = `SUB;
							`AND_FUNCTION    : reg_alu_op    = `AND;
							`OR_FUNCTION     : reg_alu_op    = `OR;
							`XOR_FUNCTION    : reg_alu_op    = `XOR;
							`NOR_FUNCTION    : reg_alu_op    = `NOR;
							`SLT_FUNCTION    : reg_alu_op    = `SLT;
							default          : reg_alu_op    = 4'b0000;
						endcase
					end
				/*Instrucciones inmediatas Tipo-I que requieren de la ALU*/
				`L_S_ADDI_ALUCODE : reg_alu_op = `ADD;
				`ANDI_ALUCODE     : reg_alu_op = `AND;
				`ORI_ALUCODE      : reg_alu_op = `OR;
				`XORI_ALUCODE     : reg_alu_op = `XOR;
				`SLTI_ALUCODE     :	reg_alu_op = `SLT;
				`LUI_ALUCODE      : reg_alu_op = `LUI;
				default :  reg_alu_op = 4'b0000;
			endcase
				
		end

endmodule
