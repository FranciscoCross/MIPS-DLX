`timescale 1ns / 1ps

`define N_TICKS 16

module baudrate_gen 
    #(parameter CLK      = 50E6,
      parameter BAUDRATE = 19200
    )
    (input      i_clock,
     input      i_reset,
     output     o_bank_register_clock);

localparam integer N_CONT = CLK/(BAUDRATE*`N_TICKS);
localparam integer N_BITS = $clog2(N_CONT);

reg [N_BITS - 1:0] counter;

always @(posedge i_clock) begin
    if(i_reset)begin
        counter <= {N_BITS{1'b0}};
    end
    else begin
        if(counter < N_CONT)
            counter <= counter + 1;
        else
            counter <= {N_BITS{1'b0}};
    end    
end

assign o_bank_register_clock = (counter==N_CONT)? 1'b1 : 1'b0;
    
endmodule

// 19200 baudrate
// 16 ticks
// clock -> 50 MHz
// s_tick cada 19200*16 = 307200 ticks por segundo