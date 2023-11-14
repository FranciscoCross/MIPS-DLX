`timescale 1ns / 1ps

module tb_ext_sign();

    parameter NB_IN = 16;
    parameter NB_OUT = 32;
    
    reg [NB_IN-1:0] i_data;
   
    wire [NB_OUT-1:0] o_data;
    
    initial begin
    
        i_data = 16'd7;
        
        #40
        i_data = 16'd57;
        
        #40
        i_data = 16'd273;
        
        #40
        i_data = 16'hff01;
        
        #200
        
        $finish;
    
    end
    
    ext_sign ext_sign(.i_data(i_data),
                            .o_data(o_data)
                            );

endmodule