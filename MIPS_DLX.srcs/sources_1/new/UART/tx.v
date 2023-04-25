`timescale 1ns / 1ps

module tx
    #(
        parameter N_BITS = 8,     //cantidad de bits de dato
        parameter N_TICK = 16     // # ticks para stop bits 
    )(
        input wire clock,
        input wire reset,
        input wire tick,
        input wire parity,
        input wire tx_start,

        input wire [N_BITS - 1 : 0] din, //Data input

        //Receiver interface
        output reg TxDone, //Transmitter done
        output wire tx //Transmitter serial output
    );

    //State declaration
    //According to Lattice semmiconductors state diagram (This implementation is a simplifed version)
    //UART Reference Design 1011 June 2011
    localparam [2 : 0] START     = 3'b000;
    localparam [2 : 0] SHIFT     = 3'b001;
    localparam [2 : 0] PARITY    = 3'b010;
    localparam [2 : 0] STOP_1B   = 3'b011;
    //Not implemented:
    //localparam [2 : 0] STOP_2B   = 3'b100;
    //localparam [2 : 0] STOP_1_5B = 3'b101;
    
    //Transmition params
    localparam START_b = 1'b0;
    localparam STOP_b  = 1'b1;

    //Masks

    //Memory
    reg [2 : 0] state;
    reg [2 : 0] next_state;
    reg tx_reg;
    reg next_tx;
    reg paridad;
    reg done;

    //Register
    reg [N_BITS - 1 : 0] tsr; //Transmit Shift Register
    reg [N_BITS - 1 : 0] thr; //Transmit Holding Register
    reg [N_BITS - 1 : 0] next_tsr;
    reg [N_BITS - 1 : 0] next_thr;

    //Local
    reg [4 : 0] tick_counter;
    reg [2 : 0] bit_counter;

    reg [4 : 0] next_tick_counter;
    reg [2 : 0] next_bit_counter;



    always @(posedge clock) //Memory
    begin
        if(reset) 
        begin
            state <= START;
            tx_reg <= STOP_b; 
            thr <= 0;
            tsr <= 0;            
            tick_counter <= 0;
            bit_counter <= 0;
            
            next_thr <= 0;
            next_tsr <= 0;
            next_tx <= STOP_b; 
            next_state <= START;
            next_tick_counter <= 0;
            next_bit_counter <= 0;
            
            TxDone <= 1;
        end
        else //Update every variable state
        begin
            state <= next_state;
            tx_reg <= next_tx;
            tick_counter <= next_tick_counter;
            bit_counter <= next_bit_counter;
            thr <= next_thr;
            tsr <= next_tsr;
        end

    end

    always @(posedge tick) //Next state logic
    begin
        next_tick_counter = tick_counter + 1;

        case(state)
            START:
            begin
                if(tx_start == 0)
                begin
                    next_thr = din;
                    next_tsr = din;
                    next_tx = STOP_b;
                    next_state = START; 
                end
                else
                begin
                    TxDone = 0;
                    next_tx = START_b; 
                    next_state = SHIFT; 
                    next_tick_counter = 0;
                end
            end
            SHIFT:
            begin
                next_tx = tsr[0];
                if(tick_counter == (N_TICK - 1))
                begin
                    next_tsr = tsr >> 1;
                    next_bit_counter = bit_counter + 1;
                    if((bit_counter == (N_BITS -1)))
                    begin
                        if(parity) next_state = PARITY;
                        else next_state = STOP_1B;

                        paridad = (^thr);
                        next_bit_counter = 0;
                    end
                    next_tick_counter = 0;
                end
            end
            PARITY:
            begin
                next_tx = paridad;
                if(tick_counter == (N_TICK - 1))
                begin
                    next_state = STOP_1B;
                    next_tick_counter = 0;
                end
            end
            STOP_1B:
            begin
                next_tx = STOP_b;
                if(tick_counter == (N_TICK - 1))
                begin
                    TxDone = 1;

                    next_thr = 0;
                    next_tsr = 0;
                    next_state = START;
                    next_tick_counter = 0;
                end                
            end
            default: //Fault recovery
            begin
                TxDone = 1;
                next_thr = 0;
                next_tsr = 0;
                next_state = START; 
                next_tick_counter = 0;
            end
        endcase
    end

    assign tx = tx_reg;
endmodule
