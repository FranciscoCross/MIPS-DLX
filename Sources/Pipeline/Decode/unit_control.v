`include "parameters.vh"
`timescale 1ns / 1ps
/* MIPS Control Unit 
*
*  Recibe las instrucciones tipo R, I, J y configura el hardware para la ejecucion de las mismas.

La señal o_EX_control consta de 7 bits, 
	Los bits o_EX_control [6:5], se utilizan para seleccionar la fuente de los valores de A y B. 
	Los bits o_EX_control [4:3] indica el tipo de instrucción: I, R, J. 
	Los bits o_EX_control [2:0], especifican el tipo de operación para la unidad ALU.
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
		input wire 						i_enable,	
		input wire [NB_OPCODE-1:0] 		i_op_code,
		input wire [NB_FUNCTION-1:0] 	i_function,

		//Registros que van hacia los LATCH
		output reg [NB_EX_CTRL-1:0] 	o_EX_control,
		output reg [NB_MEM_CTRL-1:0] 	o_M_control, 
		output reg [NB_WB_CTRL-1:0] 	o_WB_control,

		output reg [1:0] 				o_pc_src,
		
		output reg 						o_beq,
		output reg 						o_bne,
		output reg 						o_jump,
		output reg						o_halt_detected
		
	);


	always@(*)
		begin
			if (i_enable)
				begin
					case (i_op_code)
						`HALT_OPCODE://6'b111111   //Halt
							begin
								o_beq  <= 1'b0;
								o_bne  <= 1'b0;
								o_jump <= 1'b0;	
								o_halt_detected <= 1'b1;
								o_pc_src      <= 2'b00;
								o_M_control   <= 6'b000000;
								o_WB_control  <= 3'b000;
								o_EX_control  <= 7'b0000000;
							end
						/* Aca seteamos los valores de los registros para cada tipo de instruccion
						*
						*/
						`R_TYPE_OPCODE://6'b000000  
							begin
								case (i_function)
									`SLL_FUNCTION,`SRL_FUNCTION,`SRA_FUNCTION:    //6'b000000, 6'b000010, 6'b000011		
										begin
											o_beq  <= 1'b0;
											o_bne  <= 1'b0;
											o_jump <= 1'b0;	
											o_halt_detected <= 1'b0;
											o_pc_src <= 2'b00;					
											o_EX_control <= 7'b1101000;
											o_M_control  <= 6'b000000;
											o_WB_control <= 3'b101;					
										end
									`SLLV_FUNCTION,`SRLV_FUNCTION,`SRAV_FUNCTION: //6'b000100, 6'b000110, 6'b000111							
										begin
											o_beq  <= 1'b0;
											o_bne  <= 1'b0;
											o_jump <= 1'b0;
											o_halt_detected <= 1'b0;
											o_pc_src <= 2'b00;
											o_EX_control <= 7'b0101000;		
											o_M_control  <= 6'b000000;
											o_WB_control <= 3'b101;					
										end
									`JR_FUNCTION: //Jump Register //6'b001000
										begin
											o_beq  <= 1'b0;
											o_bne  <= 1'b0;
											o_jump <= 1'b0;
											o_halt_detected <= 1'b0;
											o_pc_src <= 2'b00;
											o_pc_src     	<= 2'b00; 	//00 -> i_addr_register, 01 -> i_addr_branch, 10 -> i_addr_jump						
											o_EX_control 	<= 7'bx;		//Es un salto por ende no afecta a EX						
											o_WB_control 	<= 3'bxxx;	//Mismo que arriba, no afecta a WB
											o_jump       	<= 1'b1;		//SE INDICA QUE SE HACE UN JUMP
										end
									`JALR_FUNCTION: // Jump and Link register
										begin
											o_beq  <= 1'b0;
											o_bne  <= 1'b0;
											o_jump <= 1'b0;
											o_halt_detected <= 1'b0;
											o_pc_src     	<= 2'b00;			// 00 -> i_addr_register
											o_EX_control 	<= 7'bxx10xxx; 	// 00 -> tipo I, 01 -> tipo R, 10 ->jumps and link 							
											o_WB_control 	<= 3'b110;		//  reg_write[2] mem_to_reg[1:0] -> selecciona entre (i_mem_data(00)), (i_alu_result(01)), ({{25'b0}, i_pc}(10)), (i_inm_ext(11))
											o_jump       	<= 1'b1;		
										end
									`ADDU_FUNCTION, `SUBU_FUNCTION, `AND_FUNCTION, `OR_FUNCTION, `NOR_FUNCTION, `SLT_FUNCTION:
										begin
											o_beq  <= 1'b0;
											o_bne  <= 1'b0;
											o_jump <= 1'b0;
											o_halt_detected <= 1'b0;
											o_pc_src 		<= 2'b00;
											o_EX_control 	<= 7'b0101000;
											o_M_control  	<= 6'b000000;
											o_WB_control 	<= 3'b101;
										end
									default:
										begin
											o_beq  <= o_beq;
											o_bne  <= o_bne;
											o_jump <= o_jump;	
											o_halt_detected	<= o_halt_detected;	 					
											o_pc_src 		<= o_pc_src;
											o_EX_control 	<= o_EX_control;
											o_M_control  	<= o_M_control;
											o_WB_control 	<= o_WB_control;									

										end																
								endcase					
							end
						/* TYPE I*/
						/* Load */ 				
						`LW_OPCODE:
							begin
								o_beq  <= 1'b0;
								o_bne  <= 1'b0;
								o_jump <= 1'b0;	
								o_halt_detected <= 1'b0;
								o_pc_src     <= 2'b00;
								o_M_control  <= 6'b101001;
								o_WB_control <= 3'b100;
								o_EX_control <= 7'b0000001;
							end					
						`LWU_OPCODE:
							begin	
								o_beq  <= 1'b0;
								o_bne  <= 1'b0;
								o_jump <= 1'b0;	
								o_halt_detected <= 1'b0;					
								o_pc_src     <= 2'b00;
								o_M_control  <= 6'b101000;
								o_WB_control <= 3'b100;
								o_EX_control <= 7'b0000001;						
							end
						`LH_OPCODE:
							begin		
								o_beq  <= 1'b0;
								o_bne  <= 1'b0;
								o_jump <= 1'b0;	
								o_halt_detected <= 1'b0;				
								o_pc_src     <= 2'b00;
								o_M_control  <= 6'b100101;
								o_WB_control <= 3'b100;
								o_EX_control <= 7'b0000001;
							end
						`LHU_OPCODE:
							begin
								o_beq  <= 1'b0;
								o_bne  <= 1'b0;
								o_jump <= 1'b0;		
								o_halt_detected <= 1'b0;					
								o_pc_src     <= 2'b00;
								o_M_control  <= 6'b100100;
								o_WB_control <= 3'b100;
								o_EX_control <= 7'b0000001;						
							end
						`LB_OPCODE:
							begin
								o_beq  <= 1'b0;
								o_bne  <= 1'b0;
								o_jump <= 1'b0;	
								o_halt_detected <= 1'b0;						
								o_pc_src     <= 2'b00;
								o_M_control  <= 6'b100011;
								o_WB_control <= 3'b100;
								o_EX_control <= 7'b0000001;						
							end	
						`LBU_OPCODE:
							begin	
								o_beq  <= 1'b0;
								o_bne  <= 1'b0;
								o_jump <= 1'b0;	
								o_halt_detected <= 1'b0;					
								o_pc_src     <= 2'b00;
								o_M_control  <= 6'b100010;
								o_WB_control <= 3'b100;
								o_EX_control <= 7'b0000001;						
							end				
						/* CARGA */					 				
						`SW_OPCODE:
							begin
								o_beq  <= 1'b0;
								o_bne  <= 1'b0;
								o_jump <= 1'b0;	
								o_halt_detected <= 1'b0;
								o_pc_src     <= 2'b00;
								o_M_control  <= 6'b011001;
								o_WB_control <= 3'bxxx;
								o_EX_control <= 7'b00xx001;
													
							end
						`SH_OPCODE:
							begin
								o_beq  <= 1'b0;
								o_bne  <= 1'b0;
								o_jump <= 1'b0;	
								o_halt_detected <= 1'b0;
								o_pc_src     <= 2'b00;
								o_M_control  <= 6'b010101;
								o_WB_control <= 3'bxxx;
								o_EX_control <= 7'b00xx001;					
							end
						`SB_OPCODE:
							begin
								o_beq  <= 1'b0;
								o_bne  <= 1'b0;
								o_jump <= 1'b0;	
								o_halt_detected <= 1'b0;
								o_pc_src     <= 2'b00;
								o_M_control  <= 6'b010011;
								o_WB_control <= 3'bxxx;
								o_EX_control <= 7'b00xx001;					
							end										
						`ADDI_OPCODE:
							begin
								o_beq  <= 1'b0;
								o_bne  <= 1'b0;
								o_jump <= 1'b0;		
								o_halt_detected <= 1'b0;					
								o_pc_src     <= 2'b00;
								o_M_control  <= 6'b000000;
								o_WB_control <= 3'b101;
								o_EX_control <= 7'b0000001;						
							end	
						`ANDI_OPCODE:
							begin
								o_beq  <= 1'b0;
								o_bne  <= 1'b0;
								o_jump <= 1'b0;		
								o_halt_detected <= 1'b0;						
								o_pc_src     <= 2'b00;
								o_M_control  <= 6'b000000;
								o_WB_control <= 3'b101;
								o_EX_control <= 7'b0000010;
							end					
						`ORI_OPCODE:
							begin	
								o_beq  <= 1'b0;
								o_bne  <= 1'b0;
								o_jump <= 1'b0;		
								o_halt_detected <= 1'b0;					
								o_pc_src     <= 2'b00;
								o_M_control  <= 6'b000000;
								o_WB_control <= 3'b101;
								o_EX_control <= 7'b0000011;						
							end	
						`XORI_OPCODE:
							begin
								o_beq  <= 1'b0;
								o_bne  <= 1'b0;
								o_jump <= 1'b0;		
								o_halt_detected <= 1'b0;
								o_pc_src     <= 2'b00;
								o_M_control  <= 6'b000000;
								o_WB_control <= 3'b101;
								o_EX_control <= 7'b0000100;						
							end					
						`LUI_OPCODE:
							begin
								o_beq  <= 1'b0;
								o_bne  <= 1'b0;
								o_jump <= 1'b0;		
								o_halt_detected <= 1'b0;
								o_pc_src     <= 2'b00;
								o_M_control  <= 6'b000000;
								o_WB_control <= 3'b111;
								o_EX_control <= 7'b0000101;						
							end
						`SLTI_OPCODE: 
							begin
								o_beq  <= 1'b0;
								o_bne  <= 1'b0;
								o_jump <= 1'b0;		
								o_halt_detected <= 1'b0;
								o_pc_src     <= 2'b00;
								o_M_control  <= 6'b000000;
								o_WB_control <= 3'b101;
								o_EX_control <= 7'b0000110;						
							end						
						`BEQ_OPCODE:
							begin
								o_beq  <= 1'b1;
								o_bne  <= 1'b0;
								o_jump <= 1'b0;		
								o_halt_detected <= 1'b0;
								o_pc_src     <= 2'b01;
								o_M_control  <= 6'b000000;
								o_WB_control <= 3'bxxx;
								o_EX_control <= 7'bxxxxxxx;
							end				
						`BNE_OPCODE:
							begin
								o_beq  <= 1'b0;
								o_bne  <= 1'b1;
								o_jump <= 1'b0;		
								o_halt_detected <= 1'b0;
								o_pc_src     <= 2'b01;
								o_M_control  <= 6'b000000;
								o_WB_control <= 3'bxxx;
								o_EX_control <= 7'bxxxxxxx;																				
							end
						`J_OPCODE:
							begin
								o_beq  <= 1'b0;
								o_bne  <= 1'b0;
								o_jump <= 1'b1;		
								o_halt_detected <= 1'b0;
								o_pc_src     <= 2'b10;
								o_M_control  <= 6'b000000;
								o_WB_control <= 3'bxxx;
								o_EX_control <= 7'bxxxxxxx;						
								o_jump       <= 1'b1;						
							end
						`JAL_OPCODE:
							begin
								o_beq  <= 1'b0;
								o_bne  <= 1'b0;
								o_jump <= 1'b1;		
								o_halt_detected <= 1'b0;
								o_pc_src     <= 2'b10;
								o_M_control  <= 6'b000000;
								o_WB_control <= 3'b110;
								o_EX_control <= 7'bxx10xxx;
								o_jump       <= 1'b1;											
							end	
						`NOP_OPCODE:
							begin
								o_beq  <= 1'b0;
								o_bne  <= 1'b0;
								o_jump <= 1'b0;		
								o_halt_detected <= 1'b0;
								o_pc_src     <= 2'b00;
								o_M_control  <= 6'b000000;
								o_WB_control <= 3'bxxx;
								o_EX_control <= 7'bxxxxxxx;								
							end
						default: 
							begin
								o_beq  <= o_beq;
								o_bne  <= o_bne;
								o_jump <= o_jump;
								o_halt_detected <= o_halt_detected;
								o_pc_src     <= o_pc_src;
								o_M_control  <= o_M_control;
								o_WB_control <= o_WB_control;
								o_EX_control <= o_EX_control;												
							end
					endcase
				end
			else
				begin
					o_beq 				<=	o_beq;
					o_bne 				<= 	o_bne;
					o_jump 				<= 	o_jump;
					o_halt_detected 	<= 	o_halt_detected;
					o_pc_src 			<= 	o_pc_src;
					o_EX_control 		<= 	o_EX_control; 
					o_M_control 		<= 	o_M_control;   
					o_WB_control 		<= 	o_WB_control; 
					
				end
		end
	
endmodule

