/*
El propósito del módulo es calcular la dirección de salto para una instrucción de salto condicional en un procesador.

La entrada "i_data_to_shift" es un bus de datos de ancho NB_JUMP que contiene la dirección de salto relativa 
en forma de complemento a 2. La entrada "i_pc_4" es un bus de 4 bits que contiene el valor del contador de programa (PC) incrementado en 4.
El módulo tiene "shift_left_2", que se utiliza para desplazar a la izquierda el valor de entrada "i_data_to_shift" por 2 bits y colocarlo 
en el bus "wire_data_to_shift". 
La salida "o_jump_address" es un bus de datos de ancho NB_DATA que se forma concatenando el valor de entrada "i_pc_4" y el valor del bus "wire_data_to_shift".
Por lo tanto, la salida representa la dirección de salto absoluta para la instrucción de salto condicional.
*/



module unit_jump
	#(
		parameter NB_DATA = 32,
		parameter NB_JUMP = 26
	)
	(
		input wire [NB_JUMP-1:0] i_data_to_shift,
		input wire [3:0] i_pc_4,

		output wire [NB_DATA-1:0] o_jump_address
	);
	
	wire [NB_JUMP+1:0] wire_data_to_shift;

	shift_left_2 shift_left_2
	(
		.i_data_to_shift(i_data_to_shift),
		.o_data_to_shift(wire_data_to_shift)
	);

	assign o_jump_address = {i_pc_4, wire_data_to_shift};

endmodule