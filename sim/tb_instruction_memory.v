`timescale 1ns / 1ps

module tb_instru_mem();

    parameter MEMORY_WIDTH = 8;
    parameter MEMORY_DEPTH = 64;
    parameter NB_ADDR = 32;
    parameter NB_INSTRUCTION = 32;
    
    reg [NB_ADDR-1:0]         read_addr;
    reg                       clock;
    reg                       read_enable;
    reg                       i_write_enable;
    reg [MEMORY_WIDTH-1:0]    i_write_data;
    wire [NB_INSTRUCTION-1:0] o_data;
    
    initial begin
    
        clock          = 1'b0;
        read_enable    = 1'b0;
        i_write_enable = 1'b0;
        i_write_data   = {MEMORY_WIDTH{1'b0}}; // DEBUG UNIT
        read_addr      = 6'd0;
        
        // Se leen datos de la memoria
        #40
        read_addr = 6'd0;
        read_enable = 1'b1;
        #40
        read_addr = 6'd4;
        #40
        read_addr = 6'd8;
        #40
        read_addr = 6'd12;
        
        #20
        read_enable = 1'b0;
        
        #200
        
        $finish;
    
    end
    
    always #10 clock = ~clock;
    
    instru_mem instru_mem(.i_clock(clock),
                                          .i_read_enable(read_enable),
                                          .i_write_enable(i_write_enable),
                                          .i_write_data(i_write_data),
                                          .i_read_addr(read_addr),
                                          .o_read_data(o_data)
                                          );

endmodule
