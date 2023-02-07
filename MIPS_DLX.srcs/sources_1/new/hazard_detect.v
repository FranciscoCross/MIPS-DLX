`define WR_REG i_EX_write_register != 5'b0
`define OP1   i_EX_write_register == i_ID_rs
`define OP2   i_EX_write_register == i_ID_rt



/* Modulo de deteccion de riesgos. 
El modulo se utiliza para detener el flujo de datos en el procesador en caso de un conflicto de recursos.
El modulo se define con dos parametros: 
	NB_OPCODE = numero de opcodes
	NB_REG = registros en el procesador

Toma como entrada varios valores relacionados con la fase ID y la fase EX, incluyendo 
	i_ID_EX_mem_read, 
	i_EX_reg_write, 
	i_ID_rs, i_ID_rt, 
	i_EX_write_register, y i_EX_rt.

La senial de detencion, i_halt, que detiene el procesador independientemente de cualquier conflicto de recursos.
La senial o_stall se utiliza para detener el flujo de datos en el procesador si se detecta un conflicto de recursos. 
Las seniales 
	o_pc_write y o_IF_ID_write 
se utilizan para detener la escritura en los registros PC y IF_ID respectivamente.
El bloque always @(*) contiene la logica que determina si se debe detener el procesador o no. Si se detecta un conflicto de recursos, se detiene el procesador activando 
las seniales o_stall, o_pc_write y o_IF_ID_write. 
De lo contrario, el procesador seguira funcionando normalmente.
 */



module hazard_detect
	#(
		parameter NB_OPCODE = 6,
		parameter NB_REG = 5
	)
	(
		input wire i_ID_EX_mem_read,
		input wire i_EX_reg_write,
		input wire [NB_REG-1:0] i_ID_rs,
		input wire [NB_REG-1:0] i_ID_rt,
		input wire [NB_REG-1:0] i_EX_write_register,
		input wire [NB_REG-1:0] i_EX_rt,
		input wire i_halt,

		output reg o_stall,
		output wire o_pc_write, 
		output wire o_IF_ID_write 
	

	);

	reg reg_pc_write;
	reg reg_IF_ID_write;
	
	//seteo lo registros en 1 y el stall en cero
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