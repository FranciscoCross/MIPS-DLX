`include "parameters.vh"
/*
El modulo cuenta con los siguientes puertos

i_pc: Representa la dirección de la próxima instrucción a ejecutar.
i_inm_ext: Representa la dirección de destino del salto condicional.
i_data_ra: Contiene el valor del registro RA (Registro A).
i_data_rb: Contiene el valor del registro RB (Registro B).

o_is_equal: Bit que indica si los valores de los registros RA y RB son iguales (1'b1) o si no (1'b0).
o_branch_address: Contiene la dirección de destino del salto incondicional.
*/

module unit_branch
	#(
		parameter NB_DATA = 32		
	)
	(
		input wire [`ADDRWIDTH-1:0] 	i_pc,
		input wire [`ADDRWIDTH-1:0] 	i_inm_ext,
		input wire [NB_DATA-1:0] 		i_data_ra,
		input wire [NB_DATA-1:0] 		i_data_rb,
		output wire 					o_is_equal,
		output wire [`ADDRWIDTH-1:0] 	o_branch_address   
	);

	//Salto incondicional para instrucciones tipo I.
	//Se comparan los valores de rs y rt. Despues se utilizan en INSTRUCTION DECODE para BEQ, BNEQ, JUMP
	assign o_is_equal = (i_data_ra == i_data_rb) ? 1'b1 : 1'b0;
	assign o_branch_address = i_pc + i_inm_ext;	

endmodule