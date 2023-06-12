/*
Este código define un módulo Verilog llamado "unit_hazard" que se utiliza para los riegos en el mips y actuar para evitarlos. 
Se definen TRES macros WR_REG, OP1, y OP2. 
	WR_REG 	evalúa si el registro que se va a escribir en la etapa EX no es un registro cero. 
	OP1 	evalúa si el registro fuente rs de la instrucción ID coincide con el registro que se va a escribir en la etapa EX. 
	OP2 	evalúa si el registro fuente rt de la instrucción ID coincide con el registro que se va a escribir en la etapa EX.

La lógica esencialmente implementa un "stall" para las instrucciones que intentan leer un registro que aún NO ha sido escrito, para evitar que se produzcan
datos erróneos en la ejecución de la instrucción. Si la señal i_ID_EX_mem_read es 1 y el registro i_EX_rt no es cero y coincide con i_ID_rs o i_ID_rt, o si 
la señal i_halt es 1, se establece una serie de señales de control que impiden la carga de la siguiente instrucción y detienen la escritura de la dirección 
siguiente del contador de programa.

Por otro lado, si se intenta escribir en un registro que se está leyendo en la etapa anterior, también se establecen estas señales de control para evitar 
la escritura y permitir que se complete la lectura antes de continuar con la siguiente instrucción. Si no se cumplen ninguna de estas condiciones, las 
señales de control se establecen para permitir el flujo normal de instrucciones y datos a través del procesador.
En resumen, el módulo se utiliza para detectar y evitar peligros en un procesador al detener la carga de la siguiente instrucción o
la escritura en el registro hasta que se completen ciertas operaciones previas.
*/


`define WR_REG 	i_EX_write_register_usage != 5'b0
`define OP1   	i_EX_write_register_usage == i_ID_rs
`define OP2   	i_EX_write_register_usage == i_ID_rt

module unit_hazard
	#(
		parameter NB_OPCODE = 6,
		parameter NB_REG = 5
	)
	(
		input wire i_ID_EX_mem_read,
		//input wire [NB_OPCODE-1:0] op_code_i,
		input wire i_EX_reg_write,
		//input wire beq_i, bne_i,
		input wire [NB_REG-1:0] i_ID_rs,
		input wire [NB_REG-1:0] i_ID_rt,
		input wire [NB_REG-1:0] i_EX_write_register_usage,
		input wire [NB_REG-1:0] i_EX_rt,

		input wire i_halt,
		output reg o_stall,
		output wire o_pc_write, //detiene cargar la sig direccion
		output wire o_IF_ID_write //detiene cargar la instruccion en el registro IF_ID
	

	);

	reg reg_pc_write, reg_IF_ID_write;
	initial
		begin
			reg_pc_write    = 1'b1;
			reg_IF_ID_write = 1'b1; 
			o_stall = 1'b0; 
		end

	always @(*)
		begin 
			if (((i_ID_EX_mem_read == 1'b1) && ((i_EX_rt != 5'b0) && ((i_EX_rt == i_ID_rs) || (i_EX_rt == i_ID_rt)))) || i_halt)                
				begin						
					reg_pc_write = 1'b0;
					reg_IF_ID_write = 1'b0;
					o_stall = 1'b1;
				end
			else if (i_EX_reg_write == 1'b1 && ((`WR_REG) && ((`OP1) || (`OP2))))
				begin					
					reg_pc_write = 1'b0;
					reg_IF_ID_write = 1'b0;
					o_stall = 1'b1;
				end			
			else
				begin
					reg_pc_write = 1'b1;
					reg_IF_ID_write = 1'b1;
					o_stall = 1'b0; 
				end
		end

	assign o_pc_write = reg_pc_write;
	assign o_IF_ID_write = reg_IF_ID_write;
	
endmodule