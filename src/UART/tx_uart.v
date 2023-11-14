`timescale 1ns / 1ps

module tx_uart 
#(parameter DBIT = 8,
  parameter NB_STATE = 2,
  parameter SB_TICK = 16  
  ) 
(
    input               i_clock,
    input               i_reset,
    input               i_tx_start,
    input               i_s_tick,             
    input [DBIT-1:0]    i_data,
    output reg          o_tx_done_tick,
    output              o_tx                 
);

localparam [NB_STATE - 1 : 0 ] IDLE  = 2'b00;
localparam [NB_STATE - 1 : 0 ] START = 2'b01;
localparam [NB_STATE - 1 : 0 ] DATA  = 2'b10;
localparam [NB_STATE - 1 : 0 ] STOP  = 2'b11;

reg [1:0] state, next_state;
reg [3:0] tick_counter, next_tick_counter;
reg [2:0] data_counter, next_data_counter;
reg [DBIT-1:0] shiftreg, next_shiftreg;
reg tx_reg, tx_next;


always @(posedge i_clock) begin //le saque el posedge reset
    if(i_reset)begin
        state           <= IDLE;
        tick_counter    <= 0;
        data_counter    <= 0;
        shiftreg        <= 0;
        tx_reg          <= 1'b1;
    end
    else begin
        state           <= next_state;
        tick_counter    <= next_tick_counter;
        data_counter    <= next_data_counter;
        shiftreg        <= next_shiftreg;
        tx_reg          <= tx_next;
    end
end

always @(*) begin
    next_state          = state;
    o_tx_done_tick      = 1'b0;
    next_tick_counter   = tick_counter;
    next_data_counter   = data_counter;
    next_shiftreg       = shiftreg;
    tx_next             = tx_reg;

    case(state)
        IDLE: begin
            tx_next = 1'b1;
            if(i_tx_start) begin
                next_state          = START;
                next_tick_counter   = 0;
                next_shiftreg       = i_data;
            end
        end
        START: begin
            tx_next = 1'b0;
            if(i_s_tick) begin
                if(tick_counter == (SB_TICK - 1)) begin
                    next_state          = DATA;
                    next_tick_counter   = 0;
                    next_data_counter   = 0;
                end
                else begin
                    next_tick_counter = tick_counter + 1;
                end
            end 
        end
        DATA: begin
            tx_next = shiftreg[0];
            if(i_s_tick)begin
                if(tick_counter == (SB_TICK - 1))begin
                    next_tick_counter   = 0;
                    next_shiftreg       = shiftreg >> 1;
                    if(data_counter == (DBIT - 1))
                        next_state = STOP;
                    else begin
                        next_data_counter = data_counter + 1;
                    end    
                end
                else
                    next_tick_counter = tick_counter + 1;
            end
        end
        STOP: begin
            tx_next = 1'b1;
            if(i_s_tick) begin
                if(tick_counter == 4'b1111) begin
                    next_state      = IDLE;
                    o_tx_done_tick  = 1'b1;
                end
                else begin
                    next_tick_counter = tick_counter + 1;
                end
            end
        end
    endcase
end

assign o_tx = tx_reg;

endmodule