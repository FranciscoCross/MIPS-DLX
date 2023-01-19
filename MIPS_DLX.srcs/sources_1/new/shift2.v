`timescale 1ns / 1ps

module shift2#(
        parameter NB_DATA = 32
    )(
    input [NB_DATA -1 : 0] i_data,
    output [NB_DATA -1 : 0] o_data
    );
    
    assign o_data = i_data << 2;
endmodule
