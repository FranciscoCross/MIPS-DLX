

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