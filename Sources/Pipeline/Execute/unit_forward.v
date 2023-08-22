/*
Este código Verilog define un módulo llamado "unit_forward" que implementa el circuito de forwarding utilizado en la arquitectura de procesadores. 

Modulo tiene SEIS puertos:

Las entradas "i_ID_EX_rs" e "i_ID_EX_rt" son los registros de origen de las instrucciones que 
	se están decodificando y ejecutando en la etapa de ejecución (EX) del pipeline del procesador.
Las entradas "i_EX_MEM_write_reg" e "i_MEM_WB_write_reg" son los registros de destino de las 
	instrucciones que se están ejecutando en las etapas de memoria (MEM) y writeback (WB) del pipeline.
Las entradas "i_EX_MEM_reg_write" e "i_MEM_WB_reg_write" indican si las instrucciones que se 
	están ejecutando en las etapas de memoria y writeback del pipeline están escribiendo en un registro.
Las salidas "o_forward_A" y "o_forward_B" indican si se debe realizar un forwarding para los 
	registros de origen de las instrucciones que se están decodificando y ejecutando en la etapa EX del pipeline.

Se lógica de control de forwarding, uno para la salida "o_forward_A" y otro para la salida "o_forward_B".

 En ambos casos, se verifica si el registro de origen de la instrucción actual coincide con el registro de 
 destino de la instrucción anterior que se está ejecutando. Si es así, se establece la salida correspondiente en "01" si la 
 instrucción anterior se ejecutó en la etapa EX o "10" si se ejecutó en la etapa WB. Si no hay coincidencia, 
 la salida correspondiente se establece en "00", lo que indica que el valor debe ser tomado del registro.

dato del registro deerecho (sin corto) 		-> 00
dato proviene de la etapa de Execution/Mem 	-> 01
dato proviene de la etapa de Mem/WB 		-> 10
*/

module unit_forward
	#(
		parameter NB_DATA = 32,
		parameter NB_REG  = 5
	)

	(
		input wire [NB_REG-1:0] i_ID_EX_rs,
		input wire [NB_REG-1:0] i_ID_EX_rt,
		
		input wire [NB_REG-1:0] i_EX_MEM_write_reg,
		input wire [NB_REG-1:0] i_MEM_WB_write_reg,

		input wire i_EX_MEM_reg_write,
		input wire i_MEM_WB_reg_write,

		output reg [1:0] o_forward_A, o_forward_B
	);

	always @(*)
		begin
			//####################################################################################################################################
			//#######################################################-FORWARD-A-##################################################################
			//####################################################################################################################################

			//Cuando se quiere escribir un registro despues de la etapa de execution y memoria y ese coincide con el registro de que se decodeo y executa (viene de la etapa MEM)
			if ((i_EX_MEM_reg_write == 1'b1) && (i_ID_EX_rs == i_EX_MEM_write_reg))
				o_forward_A = 2'b01;
			//Cuando se quiere escribir un registro despues de la etapa de memoria y writeback y ese coincide con el registro de que se decodeo y executa (viene de la etapa WB)
			else if ((i_MEM_WB_reg_write == 1'b1) && (i_ID_EX_rs == i_MEM_WB_write_reg))
				o_forward_A = 2'b10; 
			//Si no queda otra es que viene del banco de registro
			else
				o_forward_A = 2'b00; 
			//####################################################################################################################################
			//#######################################################-FORWARD-B-##################################################################
			//####################################################################################################################################
			
			//Cuando se quiere escribir un registro despues de la etapa de execution y memoria y ese coincide con el registro de que se decodeo y executa (viene de la etapa MEM)
			if ((i_EX_MEM_reg_write == 1'b1) && (i_ID_EX_rt == i_EX_MEM_write_reg))
				o_forward_B = 2'b01;
			//Cuando se quiere escribir un registro despues de la etapa de memoria y writeback y ese coincide con el registro de que se decodeo y executa (viene de la etapa WB)
			else if ((i_MEM_WB_reg_write == 1'b1) && (i_ID_EX_rt == i_MEM_WB_write_reg))
				o_forward_B = 2'b10; 
			//Si no queda otra es que viene del banco de registro
			else
				o_forward_B = 2'b00;

		end

	//seteo salidas en cero incialmente
	initial
		begin
			o_forward_A = 2'b00;
			o_forward_B = 2'b00;
		end
endmodule