`include "parameters.vh"
/*
La señal o_EX_control consta de 7 bits, 
	Los bits o_EX_control [6:5], se utilizan para seleccionar la fuente de los valores de A y B. 
	Los bits o_EX_control [5:4] indica el tipo de instrucción: I, R, J. 
	Los bits o_EX_control [3:0], especifican el tipo de operación para la unidad ALU.
La señal o_M_control consta de 6 bits. 
	El bit o_M_control [5] indica que se desea leer de la memoria, 
	El bit o_M_control [4] indica que se desea escribir en la memoria. 
	Los bits o_M_control [3:1] indican el ancho de la variable a leer o escribir, 
	El bit o_M_control [0], indica si la variable es signada o no.
La señal o_WB_control consta de 3 bits. 
	El bit o_WB_control [2] indica que se desea escribir en un registro. 
	Los bits o_WB_control [1:0] especifican la fuente de datos: memoria a datos, resultado de la ALU, contador de programa o valor inmediato.
La señal o_pc_src indica la fuente de la dirección del salto: 
	registro, branch o jump. Las demás salidas del módulo se utilizan según su nombre descriptivo.
La señal o_beq indica que se genera un salto condicional de tipo EQUAL:
La señal o_bne indica que se genera un salto condicional de tipo NO EQUAL:
La señal o_jump que se genera un salto incondicional:
La señal o_halt_detected indica que se nesecita un halt por ende pone un 1 en esta salida:

Dichas salidas se ven afectadas en función de la i_funtion y i_op_code que entran a los cases.
*/
module unit_control
	#(
		parameter NB_OPCODE   = 6,
		parameter NB_FUNCTION = 6,
		parameter NB_EX_CTRL  = 7,
		parameter NB_MEM_CTRL = 6,
		parameter NB_WB_CTRL  = 3
	)
	(		
		input wire [NB_OPCODE-1:0] 		i_op_code,
		input wire [NB_FUNCTION-1:0] 	i_function,

		output wire [NB_EX_CTRL-1:0] 	o_EX_control,
		output wire [NB_MEM_CTRL-1:0] 	o_M_control, 
		output wire [NB_WB_CTRL-1:0] 	o_WB_control,

		output wire [1:0] 				o_pc_src,
		
		output wire 					o_beq,
		output wire 					o_bne,
		output wire 					o_jump,
		output reg 						o_halt_detected
		
	);

	reg [NB_EX_CTRL-1:0] reg_EX_control;
	reg [NB_MEM_CTRL-1:0] reg_M_control;
	reg [NB_WB_CTRL-1:0] reg_WB_control;
	reg [1:0] reg_pc_src;

	reg reg_beq, reg_bne, reg_jump;
	
	assign o_pc_src = reg_pc_src;
	assign o_EX_control = reg_EX_control; // 7'b = (2'b src_alu(alu 1 | alu 2) | 2'b reg_dest | 3'b alu_op )
	assign o_M_control = reg_M_control;   // 6'b = (mem_read | mem_write | 3'b size_transfer(w | h | b) | signed)
	assign o_WB_control = reg_WB_control; // 3'b = (1'b reg_write | 2'b mem_to_reg)

	assign o_beq   = reg_beq;
	assign o_bne   = reg_bne;
	assign o_jump = reg_jump;

	initial
		begin
			reg_beq  = 1'b0;
			reg_bne  = 1'b0;
			reg_jump = 1'b0;
			reg_pc_src = 2'b00;
		end

	always@(*)
		begin
			reg_beq  = 1'b0;
			reg_bne  = 1'b0;
			reg_jump = 1'b0;			
			o_halt_detected = 1'b0;	
			reg_pc_src = 2'b00;

			case (i_op_code)
				`HALT_OPCODE:
					begin
						o_halt_detected = 1'b1;
						reg_pc_src      = 2'b00;
						reg_M_control   = 6'b000000;
						reg_WB_control  = 3'b000;
						reg_EX_control  = 7'b0000000;
					end
				`R_TYPE_OPCODE:
					begin
						reg_pc_src = 2'b00;
						reg_M_control  = 6'b000000;
						reg_WB_control = 3'b101;
						

						case (i_function)
							`SLL_FUNCTION,`SRL_FUNCTION,`SRA_FUNCTION:								
								reg_EX_control = 7'b1101000;					
								
							`SLLV_FUNCTION,`SRLV_FUNCTION,`SRAV_FUNCTION:								
								reg_EX_control = 7'b0101000;							
							`JR_FUNCTION:
								begin
									reg_pc_src     = 2'b00;								
									reg_EX_control = 7'bx;		//7'bxx01xxx;						
									reg_WB_control = 3'bxxx;
									reg_jump       = 1'b1;
								end
							`JALR_FUNCTION:
								begin
									reg_pc_src     = 2'b00;
									reg_EX_control = 7'bxx01xxx;								
									reg_WB_control = 3'b110;
									reg_jump       = 1'b1;		
								end
							default:
								begin								
									reg_EX_control = 7'b0101000;									

								end																
						endcase					
					end
				/* TYPE I*/
				/* Load */ 				
				`LW_OPCODE:
					begin
						reg_pc_src     = 2'b00;
						reg_M_control  = 6'b101001;
						reg_WB_control = 3'b100;
						reg_EX_control = 7'b0000001;
					end					
				`LWU_OPCODE:
					begin						
						reg_pc_src     = 2'b00;
						reg_M_control  = 6'b101000;
						reg_WB_control = 3'b100;
						reg_EX_control = 7'b0000001;						
					end
				`LH_OPCODE:
					begin						
						reg_pc_src     = 2'b00;
						reg_M_control  = 6'b100101;
						reg_WB_control = 3'b100;
						reg_EX_control = 7'b0000001;
					end
				`LHU_OPCODE:
					begin						
						reg_pc_src     = 2'b00;
						reg_M_control  = 6'b100100;
						reg_WB_control = 3'b100;
						reg_EX_control = 7'b0000001;						
					end
				`LB_OPCODE:
					begin						
						reg_pc_src     = 2'b00;
						reg_M_control  = 6'b100011;
						reg_WB_control = 3'b100;
						reg_EX_control = 7'b0000001;						
					end
					
				`LBU_OPCODE:
					begin						
						reg_pc_src     = 2'b00;
						reg_M_control  = 6'b100010;
						reg_WB_control = 3'b100;
						reg_EX_control = 7'b0000001;						
					end				
				/* CARGA */					 				
				`SW_OPCODE:
					begin
						reg_pc_src     = 2'b00;
						reg_M_control  = 6'b011001;
						reg_WB_control = 3'bxxx;
						reg_EX_control = 7'b00xx
						;						
					end
				`SH_OPCODE:
					begin
						reg_pc_src     = 2'b00;
						reg_M_control  = 6'b010101;
						reg_WB_control = 3'bxxx;
						reg_EX_control = 7'b00xx001;					
					end
				`SB_OPCODE:
					begin
						reg_pc_src     = 2'b00;
						reg_M_control  = 6'b010011;
						reg_WB_control = 3'bxxx;
						reg_EX_control = 7'b00xx001;					
					end				
				
				`ADDI_OPCODE:
					begin						
						reg_pc_src     = 2'b00;
						reg_M_control  = 6'b000000;
						reg_WB_control = 3'b101;
						reg_EX_control = 7'b0000001;						
					end	
				`ANDI_OPCODE:
					begin						
						reg_pc_src     = 2'b00;
						reg_M_control  = 6'b000000;
						reg_WB_control = 3'b101;
						reg_EX_control = 7'b0000010;
					end					
				`ORI_OPCODE:
					begin						
						reg_pc_src     = 2'b00;
						reg_M_control  = 6'b000000;
						reg_WB_control = 3'b101;
						reg_EX_control = 7'b0000011;						
					end	
				`XORI_OPCODE:
					begin
						reg_pc_src     = 2'b00;
						reg_M_control  = 6'b000000;
						reg_WB_control = 3'b101;
						reg_EX_control = 7'b0000100;						
					end					
				`LUI_OPCODE:
					begin
						reg_pc_src     = 2'b00;
						reg_M_control  = 6'b000000;
						reg_WB_control = 3'b101;
						reg_EX_control = 7'b0000101;						
					end
				`SLTI_OPCODE: 
					begin
						reg_pc_src     = 2'b00;
						reg_M_control  = 6'b000000;
						reg_WB_control = 3'b101;
						reg_EX_control = 7'b0000110;						
					end
				
				`BEQ_OPCODE:
					begin
						reg_pc_src     = 2'b01;
						reg_M_control  = 6'b000000;
						reg_WB_control = 3'bxxx;
						reg_EX_control = 7'bxxxxxxx;
						reg_beq        = 1'b1;
					end				
				`BNE_OPCODE:
					begin
						reg_pc_src     = 2'b01;
						reg_M_control  = 6'b000000;
						reg_WB_control = 3'bxxx;
						reg_EX_control = 7'bxxxxxxx;						
						reg_bne        = 1'b1;
												
					end
				`J_OPCODE:
					begin
						reg_pc_src     = 2'b10;
						reg_M_control  = 6'b000000;
						reg_WB_control = 3'bxxx;
						reg_EX_control = 7'bxxxxxxx;						
						reg_jump       = 1'b1;						
					end
				`JAL_OPCODE:
					begin
						reg_pc_src     = 2'b10;
						reg_M_control  = 6'b000000;
						reg_WB_control = 3'b110;
						reg_EX_control = 7'bxx10xxx;
						reg_jump       = 1'b1;											
					end	
				`NOP_OPCODE:
					begin
						//reg_pc_src     = 2'b00;
						reg_M_control  = 6'b000000;
						reg_WB_control = 3'bxxx;
						reg_EX_control = 7'bxxxxxxx;								
					end
				default: 
					begin
						reg_pc_src     = 2'b00;
						reg_M_control  = 6'b000000;
						reg_WB_control = 3'b000;
						reg_EX_control = 7'b0000000;												
					end
			endcase
		end
	
endmodule

