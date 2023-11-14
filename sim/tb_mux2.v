`timescale 1ns / 1ps

module tb_mux2();

    parameter   NB = 32;
    
    reg           select;
    reg  [NB-1:0] a;
    reg  [NB-1:0] b;
    
    wire [NB-1:0] data;
    
    initial begin
    
        a = 32'd1;
        b = 32'd80;
        select = 1'b0;
        
        #100
        select = 1'b1;
        
        #100
        select = 1'b0;
        
        #100
        select = 1'b1;
        
        #200
        
        $finish;
    
    end
    
    mux2 mux2(.i_SEL(select),
              .i_A(a),
              .i_B(b),
              .o_data(data)
              );

endmodule
