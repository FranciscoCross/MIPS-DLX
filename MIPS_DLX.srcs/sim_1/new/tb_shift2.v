`timescale 1ns / 1ps

module tb_shift2(

    );

    localparam NB_DATA = 32;
    
    reg clk = 0;

    reg [NB_DATA - 1 : 0] IN;
    wire [NB_DATA - 1 : 0] OUT;

    shift2 #(.NB_DATA (NB_DATA)) inst_shift2
    (
        .i_data(IN),
        .o_data(OUT)
    );
    
    always #1 clk = ~clk; // # < timeunit > delay
    initial begin
        #0
        clk = 1;
        IN = 32'h00000FFF;
        #10
        IN = 32'hFFFFFFFF;
        #10
        IN = 32'h00007000;
        #10
        IN = 32'hFFFF8000;
        #10
        $finish;
    end
endmodule
