`define WR_REG 	i_EX_write_register != 5'b0
`define OP1   	i_EX_write_register == i_ID_rs
`define OP2   	i_EX_write_register == i_ID_rt

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
		input wire [NB_REG-1:0] i_EX_write_register,
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
		begin // LOAD R|I|B + HALT
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