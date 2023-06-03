`timescale 1ns / 1ps

`define N_TICKS 16

module baudrategen 
    #(
        parameter CLK = 50e6, 
        parameter BAUD_RATE = 9600
    )(
        input wire clock,
        input wire reset,
        output wire tick
    );

    localparam integer N_BCLK_DIV = (CLK / (BAUD_RATE*`N_TICKS));
    localparam N_BITS = $clog2 (N_BCLK_DIV);

    reg [N_BITS - 1 : 0] count;

    always @(posedge clock)
    begin
        if(reset) count <= 0;
        else if(count == N_BCLK_DIV) count <= 0;
        else count = count + 1;
    end

    assign tick = (count == N_BCLK_DIV) ? 1'b1 : 1'b0;

endmodule
