`timescale 1ns / 1ps

module tb_ext_signo(

    );
    localparam NB_DATA = 16;
    localparam NB_EXTEND = 32;
    
    reg clk = 0;

    reg [NB_DATA - 1 : 0] IN;
    wire [NB_EXTEND - 1 : 0] OUT;

    ext_signo #(.NB_UNEXTEND (NB_DATA), .NB_EXTEND (NB_EXTEND)) inst_ext_signo
    (
        .i_unextended(IN),
        .o_extended(OUT)
    );
    
    always #1 clk = ~clk; // # < timeunit > delay
       initial begin
            #0
            clk = 1;
            IN = 16'h0FFF;
            #10
            IN = 16'hFFFF;
            #10
            IN = 16'h7000;
            #10
            IN = 16'h8000;
            #10
            $finish;
        end
endmodule
