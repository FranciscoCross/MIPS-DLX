`timescale 1ns / 1ps

module tb_adder();

    parameter N_BITS = 32;
    
    reg [N_BITS-1:0] b;
    reg pc_enable;
    reg clock;
    reg pc_reset;
    
    wire [N_BITS-1:0] result;
    wire [N_BITS-1:0] o_pc;
    
    
    initial begin
    
        clock = 1'b0;
        pc_reset = 1'b1;
        pc_enable = 1'b0;
        b = 32'b0;
        
        #40
        pc_reset = 1'b0;
        pc_enable = 1'b1;
        b = 32'd1;
        
        #200
        
        $finish;
    
    end
    
    always #10 clock = ~clock;
    
    program_counter program_counter(.i_clock(clock),
                                    .i_reset(pc_reset),
                                    .i_enable(pc_enable),
                                    .i_mux_pc(result),
                                    .o_pc(o_pc)
                                    );
    
    adder adder(.i_A(o_pc),
                .i_B(b),
                .o_result(result)
                );

endmodule
