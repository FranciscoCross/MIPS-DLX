`include "parameters.vh"

module alu_control
	#(
		parameter NB_FUNCTION = 6, //6 bist para elegir la funcion de la ALU
		parameter NB_ALU_OP   = 3, //3 bits para la OPERACION a hacer
		parameter NB_OP_ALU   = 4  //4 bits Operacion/funcion final que se manda a la ALU

	)
	(
		input wire [NB_FUNCTION-1:0] i_function,
		input wire [NB_ALU_OP-1:0]   i_alu_op,
		output wire [NB_OP_ALU-1:0]  o_alu_op
	);

	reg [NB_OP_ALU-1:0] reg_alu_op;
	assign o_alu_op = reg_alu_op;

	always @(*)
		begin
			case (i_alu_op)
				`R_ALUCODE://R-type
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
