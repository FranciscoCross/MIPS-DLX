module branch_forward_unit
	#(
		parameter NB_DATA = 32,
		parameter NB_REG  = 5
	)

	(
		input wire [NB_REG-1:0] i_ID_rs,
		input wire [NB_REG-1:0] i_ID_rt,
		
		input wire [NB_REG-1:0] i_EX_MEM_write_reg,
		input wire i_EX_MEM_reg_write,	

		output reg o_forward_A, o_forward_B
	);

	initial 
		begin
			o_forward_A = 0;
			o_forward_B = 0;
		end

	always @(*)
		begin
            //viene de la etapa MEM
			if ((i_EX_MEM_reg_write == 1'b1) && (i_ID_rs == i_EX_MEM_write_reg))
				o_forward_A = 1'b1;		
			//Si no, viene del banco de registro
            else
				o_forward_A = 1'b0;

			//####################################################################################################################################

            //viene de la etapa MEM
			if ((i_EX_MEM_reg_write == 1'b1) && (i_ID_rt == i_EX_MEM_write_reg))
				o_forward_B = 1'b1;			
			//Si no, viene del banco de registro
            else
				o_forward_B = 1'b0; 
		end

endmodule