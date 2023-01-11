`timescale 1ns / 1ps

module tb_mux3;
    localparam NB_DATA = 5;
    localparam NB_SEL = 2;

    //for clock pulse
    reg clk = 0;

    reg [NB_DATA - 1 : 0] SEL;
    reg [NB_DATA - 1 : 0] A;
    reg [NB_DATA - 1 : 0] B;
    reg [NB_DATA - 1 : 0] C;
    wire [NB_DATA - 1 : 0] OUT;

    mux3 #(.N_BITS (NB_DATA)) inst_mux3
    (
        .i_A(A),
        .i_B(B),
        .i_C(C),
        .i_SEL(SEL),
        .o_OUT(OUT)
    );
    
    always #1 clk = ~clk; // # < timeunit > delay
       initial begin
            #0
            clk = 1;
            SEL = 2'b0;
            A = 5'ha;
            B = 5'hb;
            C = 5'hc;
            #10
            SEL = 2'b1;
            #10
            SEL = 2'b10;
            #10
            SEL = 0;
            #10
            $finish;
        end
endmodule