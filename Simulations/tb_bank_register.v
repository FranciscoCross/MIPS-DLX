`timescale 1ns / 1ps

module tb_bank_register(

    );

    localparam NB_DATA = 32;
    localparam NB_REG = 5;

    reg clock = 0;
    reg reset = 0;
    reg rw = 0;
    
    reg [NB_REG - 1 : 0] IN_ADDR_RA;
    reg [NB_REG - 1 : 0] IN_ADDR_RB;

    
    reg [NB_REG - 1 : 0] IN_ADDR_RW;
    reg [NB_DATA - 1 : 0] IN_DATA_RW;


    wire [NB_DATA - 1 : 0] OUT_DATA_RA;
    wire [NB_DATA - 1 : 0] OUT_DATA_RB;

    bank_register #(.NB_DATA (NB_DATA)) bank
    (
        .i_clock(clock),
        .i_reset(reset),
        .i_rw(rw), 
        .i_addr_ra(IN_ADDR_RA),
        .i_addr_rb(IN_ADDR_RB),
        .i_addr_rw(IN_ADDR_RW),
        .i_data_rw(IN_DATA_RW),
        .o_data_ra(OUT_DATA_RA),
        .o_data_rb(OUT_DATA_RB)
    );
    
    always #1 clock = ~clock; // # < timeunit > delay
    initial begin
        #0
        clock = 1;
        reset = 1;
        rw = 1;
        IN_ADDR_RA = 5'b10101;
        IN_ADDR_RB = 5'b10111;
        IN_ADDR_RW = 5'b10101;
        IN_DATA_RW = 0;
        #2
        reset = 0;
        #10
        IN_DATA_RW = 15;
        #10
        IN_DATA_RW = 20;
        IN_ADDR_RW = 5'b10111;
        #10
        IN_DATA_RW = 25;
        IN_ADDR_RW = 5'b00011;
        #10
        IN_DATA_RW = 30;
        IN_ADDR_RW = 5'b00111;
        #10
        rw = 0;
        IN_DATA_RW = 35;
        IN_ADDR_RW = 5'b10111;
        #10
        rw = 1;
        IN_DATA_RW = 88;
        IN_ADDR_RW = 5'b10111;
        #10
        $finish;
    end
endmodule
