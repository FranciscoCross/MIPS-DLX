`timescale 1ns / 1ps

//Defines para saber que se elige leer un byte, media palabra o una palabra
`define BYTE  3'b001
`define HALF_WORD 3'b010
`define WORD 3'b100

//Define para establecer la cantidad de bites que se eligen (ancho)
`define N_BYTE 7:0
`define N_HALF 15:0

//BITS que determinan si se quiere leer o escribir y se usan en el case para elegir que hacer
`define MEM_READ 5
`define MEM_WRITE 4
//Para determinar el ancho de el selector que se quiere usar en este caso 3 bits
`define SIZE 3:1
//Si lo que se lee es con signo o no el bit 0 determina eso
`define SIGNED 0

`define N_ELEMENTS 128
`define ADDRWIDTH $clog2(`N_ELEMENTS)

module mem_controller
	#(
		parameter NB_DATA     = 32,
		parameter NB_MEM_CTRL = 6	    
	)
	(
		input wire [NB_DATA-1:0] i_data_write,		
		input wire [NB_DATA-1:0] i_data_read,
   		input wire [NB_MEM_CTRL-1:0] i_MEM_control,

   		output wire [NB_DATA-1:0] o_data_write,
   		output wire [NB_DATA-1:0] o_data_read
	
	);

	reg [NB_DATA-1:0] reg_data_write;
	reg [NB_DATA-1:0] reg_data_read;	

	always @(*) //Lectura
		begin	
			if (i_MEM_control[`MEM_READ])
	            begin 	
	                if (i_MEM_control[`SIGNED]) 
	                	begin 
			            	case (i_MEM_control[`SIZE])			            		
				                	`BYTE:      		
				                		begin
				                			reg_data_read = {{24'b0}, i_data_read[`N_BYTE]};   			
				                		end	                		                
				                            
				                	`HALF_WORD:
				                		begin				                			                			
				                			reg_data_read = {16'b0, i_data_read[`N_HALF]};  
				                    	end
				                    	
				                	`WORD:
				                	    begin
									 		reg_data_read = i_data_read;                   	
				                		end

				                    default:
				                    	reg_data_read = 32'b0;        
	                			endcase
	                	end
	              	else
	              		begin
	              			case (i_MEM_control[`SIZE])	              				
				                	`BYTE:	                		
				                		begin
				                			reg_data_read = {{24{i_data_read[7]}}, i_data_read[`N_BYTE]}; 			                			           			
				                		end	                		                
				                            
				                	`HALF_WORD:
				                		begin	                			
				                			reg_data_read = {{16{i_data_read[15]}}, i_data_read[`N_HALF]};   
				                    	end
				                    	
				                	`WORD:
                                        begin
				                		    reg_data_read = i_data_read;                 	
				                		end

				                    default:
				                    	reg_data_read = 32'b0;        
	                    	
	                		endcase
	              		end
	            end	
	        else
				reg_data_read = 32'b0;	  
		end

/*************************************************************************/
	always @(*) //Escritura
		begin
			if (i_MEM_control[`MEM_WRITE])
	            begin    
	            	case (i_MEM_control[`SIZE])
	                	`BYTE:
	                		reg_data_write = i_data_write[`N_BYTE];                
	                            
	                	`HALF_WORD:               
	                    	reg_data_write = i_data_write[`N_HALF];	                    

	                	`WORD:                    
	                    	reg_data_write = i_data_write;         
	                    default:
	                    	reg_data_write = 32'b0;
	                endcase
	            end
	        else
	            reg_data_write = 32'b0;
		end

/*************************************************************************/
	assign o_data_write = reg_data_write;
	assign o_data_read  = reg_data_read;
/*************************************************************************/

endmodule