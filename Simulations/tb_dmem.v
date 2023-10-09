`timescale 1ns / 1ps

module tb_dmem;
    localparam N_BITS = 32;
    localparam MEM_SIZE = 128;
    
    reg[N_BITS - 1 : 0] I_ADDR;
    reg[N_BITS - 1 : 0] I_DATA;
    
    reg EN_MEM;
    reg EN_W;
    reg EN_R;
    
    wire[N_BITS - 1 : 0] O_DATA;

    //for clock pulse
    reg clk = 0;
 
    dmem instancia_dmem(
        .i_clock(clk),
        .i_mem_enable(EN_MEM),
        .i_write(EN_W),
        .i_read(EN_R),
        .i_addr(I_ADDR),
        .i_data(I_DATA),
        .o_data(O_DATA)
    );
    
    always #1 clk = ~clk; // # < timeunit > delay
       initial begin
            #0
            EN_MEM = 1;
            EN_W = 1;
            EN_R = 0;
            I_ADDR= 6'b0;
            I_DATA= 32'b1010;
            
            #10
            EN_W = 0;
            EN_R = 1;
            I_ADDR= 6'b0;
            #10
            $finish;
 
        end
endmodule
