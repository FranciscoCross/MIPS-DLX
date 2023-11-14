`timescale 1ns / 1ps

module tb_mux4();

    parameter   NB = 32;
    parameter   NB_SELECT = 2;
    
    reg  [NB_SELECT-1:0]     select;
    reg  [NB-1:0]            a;
    reg  [NB-1:0]            b;
    reg  [NB-1:0]            c;
    reg  [NB-1:0]            d;
    
    wire [NB-1:0]            data;
    
    initial begin
    
        a = 32'd1;
        b = 32'd80;
        c = 32'd250;
        d = 32'd999;
        select = 2'd0;
        
        #100
        select = 2'd1;
        
        #100
        select = 2'd2;
        
        #100
        select = 2'd3;
        
        #200
        
        $finish;
    
    end
    
    mux4 mux4(.i_SEL(select),
              .i_A(a),
              .i_B(b),
              .i_C(c),
              .i_D(d),
              .o_data(data)
              );

endmodule
