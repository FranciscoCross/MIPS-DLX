
/*
El modulo tiene entradas para la senial de reloj (i_clock), senial de reinicio (i_reset), senial de lectura/escritura (i_rw), 
direcciones de registro de lectura A y B (i_addr_ra e i_addr_rb), direccion de registro de escritura (i_addr_rw) y datos 
para escribir en el registro de escritura (i_data_rw) y las dos salidas que corresponden a los datos de lectura A y B 
(o_data_ra y o_data_rb) que pueden ser seleccionados mediante las direcciones de registro de lectura A y B.

La logica de control para escribir o leer de los registros varia según las seniales de entrada. 
Si la senial de reinicio (i_reset) esta activa, se establecen las salidas de datos de lectura A y B en cero.
Si la senial de lectura/escritura (i_rw) esta activa, el dato de entrada i_data_rw se escribe en el registro 
correspondiente a la direccion de registro de escritura (i_addr_rw). 
Si las direcciones de registro de lectura A o B coinciden con la direccion de registro de escritura, 
los datos de salida correspondientes se actualizan con el nuevo valor. 

En caso contrario, las salidas de datos de lectura A y B se actualizan con los datos almacenados en los registros correspondientes 
a sus direcciones de registro.
*/
module bank_register
	#(
		parameter NB_REG = 5,
		parameter NB_DATA = 32,
		parameter N_REGISTER = 32		
	)
	( 
		input wire i_clock,
		input wire i_reset,
		input wire i_rw, 
		input wire [NB_REG-1:0] i_addr_ra,
		input wire [NB_REG-1:0] i_addr_rb,
		input wire [NB_REG-1:0] i_addr_rw,
		input wire [NB_DATA-1:0] i_data_rw,

		output reg [NB_DATA-1:0] o_data_ra,
		output reg [NB_DATA-1:0] o_data_rb		
	
	);
	reg [NB_DATA-1:0] registers[N_REGISTER-1:0];  	

    always @(posedge i_clock)
        begin
	        if (i_reset)
	        		begin	        			
						o_data_ra <= 32'b0;
						o_data_rb <= 32'b0;
	        		end        	
        	else if (i_rw)
        		begin
        			registers[i_addr_rw] <= i_data_rw;

        		  	if (i_addr_ra == i_addr_rw)
        		  		o_data_ra <= i_data_rw;
        		  	else if (i_addr_rb == i_addr_rw)
        		  		o_data_rb <= i_data_rw;
        		  	else
        		  		begin
        		  			
        		  			o_data_ra <= registers[i_addr_ra];
		    				o_data_rb <= registers[i_addr_rb];
        		  		end
        		end
        	else
        		begin    			
        			o_data_ra <= registers[i_addr_ra];
		    		o_data_rb <= registers[i_addr_rb];	
  				end
        end

	    // Inicializacion de registros.
	generate
	    integer i;		
		initial
	    for (i = 0; i < N_REGISTER; i = i + 1)
	        registers[i] = 32'd0; //registers[i] = {NB_DATA{1'b0}};
	endgenerate


endmodule