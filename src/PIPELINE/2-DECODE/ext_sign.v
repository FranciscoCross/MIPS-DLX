`timescale 1ns / 1ps

module ext_sign#(
        parameter NB_IN = 16,
        parameter NB_OUT = 32
    )
    (
        input [NB_IN-1:0]  i_data,
        output reg [NB_OUT-1:0] o_data
    );

    always@(*) begin
        o_data[NB_IN-1:0]       = i_data[NB_IN-1:0];
        o_data[NB_OUT-1:NB_IN]  = {NB_IN{i_data[NB_IN-1]}}; // se extiende el signo de i_data[15]
    end    
endmodule
