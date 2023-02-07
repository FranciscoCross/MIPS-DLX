`define WR_REG EX_write_register_i != 5'b0
`define OP1   EX_write_register_i == ID_rs_i
`define OP2   EX_write_register_i == ID_rt_i



/* Modulo de deteccion de riesgos. 
El modulo se utiliza para detener el flujo de datos en el procesador en caso de un conflicto de recursos.
El modulo se define con dos parametros: 
	NB_OPCODE = numero de opcodes
	NB_REG = registros en el procesador

Toma como entrada varios valores relacionados con la fase ID y la fase EX, incluyendo 
	ID_EX_mem_read_i, 
	EX_reg_write_i, 
	ID_rs_i, ID_rt_i, 
	EX_write_register_i, y EX_rt_i.

La senial de detencion, halt_i, que detiene el procesador independientemente de cualquier conflicto de recursos.
La senial stall_o se utiliza para detener el flujo de datos en el procesador si se detecta un conflicto de recursos. 
Las seniales 
	pc_write_o y IF_ID_write_o 
se utilizan para detener la escritura en los registros PC y IF_ID respectivamente.
El bloque always @(*) contiene la logica que determina si se debe detener el procesador o no. Si se detecta un conflicto de recursos, se detiene el procesador activando 
las seniales stall_o, pc_write_o y IF_ID_write_o. 
De lo contrario, el procesador seguira funcionando normalmente.
 */



module hazard_detect
	#(
		parameter NB_OPCODE = 6,
		parameter NB_REG = 5
	)
	(
		input wire ID_EX_mem_read_i,
		input wire EX_reg_write_i,
		input wire [NB_REG-1:0] ID_rs_i,
		input wire [NB_REG-1:0] ID_rt_i,
		input wire [NB_REG-1:0] EX_write_register_i,
		input wire [NB_REG-1:0] EX_rt_i,

		input wire halt_i,
		output reg stall_o,
		output wire pc_write_o, 
		output wire IF_ID_write_o 
	

	);

	reg reg_pc_write;
	reg reg_IF_ID_write;
	
	//seteo lo registros en 1 y el stall en cero
	initial
		begin
			reg_pc_write    = 1'b1;
			reg_IF_ID_write = 1'b1; 
			stall_o = 1'b0; 
		end

	always @(*)
		begin 
			if (((ID_EX_mem_read_i == 1'b1) && ((EX_rt_i != 5'b0) && ((EX_rt_i == ID_rs_i) || (EX_rt_i == ID_rt_i)))) || halt_i)                
				begin						
					reg_pc_write = 1'b0;
					reg_IF_ID_write = 1'b0;
					stall_o = 1'b1;
				end
			
			else if (EX_reg_write_i == 1'b1 && ((`WR_REG) && ((`OP1) || (`OP2))))
				begin					
					reg_pc_write = 1'b0;
					reg_IF_ID_write = 1'b0;
					stall_o = 1'b1;
				end			
			else
				begin
					reg_pc_write = 1'b1;
					reg_IF_ID_write = 1'b1;
					stall_o = 1'b0; 
				end
		end

	assign pc_write_o = reg_pc_write;
	assign IF_ID_write_o = reg_IF_ID_write;
	
endmodule