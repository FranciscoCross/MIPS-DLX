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