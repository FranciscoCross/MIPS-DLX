`timescale 1ns / 1ps

module tb_mux;
    localparam NB_DATA = 5;

    //for clock pulse
    reg clk = 0;

    reg SEL;
    reg [NB_DATA - 1 : 0] A;
    reg [NB_DATA - 1 : 0] B;
    wire [NB_DATA - 1 : 0] OUT;

    mux2 #(.N_BITS (NB_DATA)) inst_mux2
    (
        .i_A(A),
        .i_B(B),
        .i_SEL(SEL),
        .o_OUT(OUT)
    );
    
    always #1 clk = ~clk; // # < timeunit > delay
       initial begin
            #0
            clk = 1;
            SEL = 0;
            A = 5;
            B = 2;
            #10
            SEL = 1;
            #10
            SEL = 0;
            #10
            $finish;
        end
endmodule