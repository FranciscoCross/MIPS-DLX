`define N_ELEMENTS 128
`define ADDRWIDTH $clog2(`N_ELEMENTS)

module ctrl_bit_sucio
	(
		input wire i_clock,
		input wire i_reset, 
		input wire [`ADDRWIDTH-1:0] i_addr,
		input wire i_mem_write,

		output wire o_bit_sucio
	);
	reg [`N_ELEMENTS-1:0] bit_sucio_reg; // 1 elemento y 128 ancho 
    initial begin
        bit_sucio_reg = 0;
    end
    
	assign o_bit_sucio = bit_sucio_reg[i_addr];

	always @(negedge i_clock)
		begin
		    if (i_reset)
		    	begin
		    		bit_sucio_reg    <= 0; //Inicializa todo en 0. O sea en  "Clean"
		    		bit_sucio_reg[0] <= 1'b1; //Dirty
		    		bit_sucio_reg[1] <= 1'b1; //Dirty
		    		bit_sucio_reg[2] <= 1'b1; //Dirty
		    		bit_sucio_reg[3] <= 1'b1; //Dirty
		    		bit_sucio_reg[4] <= 1'b1; //Dirty
		    		bit_sucio_reg[5] <= 1'b1; //Dirty
		    	end
		    else
			    begin
			        if (i_mem_write) 
			            bit_sucio_reg[i_addr] <= 1'b1; // Cuando escribo lo pongo en Dirty
			       
			        else 
			            bit_sucio_reg <= bit_sucio_reg;	        
			    end
	  	end
endmodule