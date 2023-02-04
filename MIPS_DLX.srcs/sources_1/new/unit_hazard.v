`define WR_REG EX_write_register_i != 5'b0
`define OP1   EX_write_register_i == ID_rs_i
`define OP2   EX_write_register_i == ID_rt_i
//`define RB    (op_code_i == 6'b0 || beq_i || bne_i)

module hazard_detection
	#(
		parameter NB_OPCODE = 6,
		parameter NB_REG = 5
	)
	(
		input wire ID_EX_mem_read_i,
		//input wire [NB_OPCODE-1:0] op_code_i,
		input wire EX_reg_write_i,
		//input wire beq_i, bne_i,
		input wire [NB_REG-1:0] ID_rs_i,
		input wire [NB_REG-1:0] ID_rt_i,
		input wire [NB_REG-1:0] EX_write_register_i,
		input wire [NB_REG-1:0] EX_rt_i,

		input wire halt_i,
		output reg stall_o,
		output wire pc_write_o, //detiene cargar la sig direccion
		output wire IF_ID_write_o //detiene cargar la instruccion en el registro IF_ID
	

	);

	reg reg_pc_write, reg_IF_ID_write;
	initial
		begin
			reg_pc_write    = 1'b1;
			reg_IF_ID_write = 1'b1; 
			stall_o = 1'b0; 
		end

	always @(*)
		begin // LOAD R|I|B + HALT
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