`timescale 1ns / 1ps

module extend#(
        parameter NB_IN = 5,
        parameter NB_OUT = 32
    )
    (
        input [NB_IN-1:0]       i_data,
        output reg [NB_OUT-1:0] o_data
    );

    always@(*) begin
        o_data = {27'b0, i_data};
    end    
endmodule