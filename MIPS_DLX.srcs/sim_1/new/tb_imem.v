`timescale 1ns / 1ps

module tb_imem;
    localparam N_BITS = 32;
    localparam MEM_SIZE = 128;
    
    reg[N_BITS - 1 : 0] ADDR_I;
    reg[N_BITS - 1 : 0] DATA_I;
    
    reg EN_W;
    reg EN_R;
    
   wire[N_BITS - 1 : 0] DATA_O;

    //for clock pulse
    reg clk;
    
    imem #(
        .MEM_SIZEB(MEM_SIZE),
        .NB_DATA(N_BITS)
    )
    instancia_imem(
        .i_clk(clk),
        .i_en_write(EN_W),
        .i_en_read(EN_R),
        .i_addr(ADDR_I),
        .i_data(DATA_I),
        .o_data(DATA_O)
    );
    always #1 clk = ~clk; // # < timeunit > delay
       initial begin
           // $dumpfile("tb_imem.vcd");
            //Specify variables to be dumped, w/o any argument it dumps all variables 
          //  $dumpvars;
           

            #0
            EN_W = 1;
            EN_R = 0;
            ADDR_I= 32'b0;
            DATA_I= 32'b1010;
            
            #10
            EN_W = 0;
            EN_R = 1;
            ADDR_I= 6'b0;
            #10
            $finish;
 
        end
endmodule
