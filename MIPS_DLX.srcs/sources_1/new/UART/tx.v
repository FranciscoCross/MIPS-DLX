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
        output wire TxDone, //Transmitter done
        output wire tx //Transmitter serial output
    );

    //State declaration
    //According to Lattice semmiconductors state diagram (This implementation is a simplifed version)
    //UART Reference Design 1011 June 2011
    localparam [2 : 0] START     = 3'b000;
    localparam [2 : 0] SHIFT     = 3'b001;
    localparam [2 : 0] PARITY    = 3'b010;
    localparam [2 : 0] STOP_1B   = 3'b011;
    
    //Transmition params
    localparam START_b = 1'b0;
    localparam STOP_b  = 1'b1;


    reg tx_reg, tx_ready, paridad, transmitir, done;
    //Memory
    reg [2 : 0] state;

    //Register
    reg [N_BITS - 1 : 0] tsr; //Transmit Shift Register
    reg [N_BITS - 1 : 0] thr; //Transmit Holding Register
    //Local
    reg [4 : 0] tick_counter;
    reg [3 : 0] bit_counter;


    //Next values
    reg next_done, next_tx, next_tx_ready, next_paridad, next_transmitir;
    reg [2 : 0] next_state;
    reg [4 : 0] next_tick_counter;
    reg [3 : 0] next_bit_counter;
    reg [N_BITS - 1 : 0] next_tsr;
    reg [N_BITS - 1 : 0] next_thr;

    //Reset values
    reg reset_done, reset_tx, reset_tx_ready, reset_paridad, reset_transmitir;
    reg [2 : 0] reset_state;
    reg [4 : 0] reset_tick_counter;
    reg [2 : 0] reset_bit_counter;
    reg [N_BITS - 1 : 0] reset_tsr;
    reg [N_BITS - 1 : 0] reset_thr;

    //Initial value initialization
    initial begin 
        next_state = START;
        next_tx = STOP_b;
        next_done = 0;
        next_tsr = 0;
        next_thr = 0;
        next_tick_counter = 0;
        next_bit_counter = 0;
        next_tx_ready = 1;
        next_paridad = 0;
        next_transmitir = 0;

        //Reset values
        reset_state = START;
        reset_done = 0;
        reset_tsr = 0;
        reset_thr = 0;
        reset_tick_counter = 0;
        reset_bit_counter = 0;
        reset_tx_ready = 1;
        reset_tx = STOP_b;
        reset_paridad = 0;
        reset_transmitir = 0;
    end

    always @(posedge clock) //Memory
    begin
        if(reset) 
        begin
            state <= reset_state;
            tx_reg <= reset_tx;
            tick_counter <= reset_tick_counter;
            bit_counter <= reset_bit_counter;
            thr <= reset_thr;
            tsr <= reset_tsr;
            tx_ready <= reset_tx_ready;
            done <= reset_done;
            paridad <= reset_paridad;
            transmitir <= reset_transmitir;
        end
        else //Update every variable state
        begin
            state <= next_state;
            tx_reg <= next_tx;
            tick_counter <= next_tick_counter;
            bit_counter <= next_bit_counter;
            thr <= next_thr;
            tsr <= next_tsr;
            tx_ready <= next_tx_ready;
            done <= next_done;
            paridad <= next_paridad;
            transmitir <= next_transmitir;
        end
    end


    always @(posedge tick) //Next state logic
    begin
        next_tick_counter = tick_counter + 1;

        if(tx_start & tx_ready)
        begin
            next_transmitir = 1;
        end

        case(state)
            START:
            begin
                if(!transmitir) //Si no hay TX start sigo en START
                begin //aca no trasmitp
                    next_tx = STOP_b;
                    next_state = START;
                    next_tick_counter = 0;
                end else begin //Comienza la transmision
                    next_thr = din;
                    next_tsr = din;
                    next_done = 0;
                    next_tx = START_b; 
                    next_tx_ready = 0;
                    if(tick_counter == ((N_TICK / 2)-1))
                    begin
                        next_state = SHIFT; 
                        next_tick_counter = 0;
                        next_transmitir = 0;
                    end
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
                        next_paridad = (^thr);
                    end
                    next_tick_counter = 0;
                end
            end
            PARITY: //Bit 8
            begin
                next_tx = paridad;
                if(tick_counter == (N_TICK - 1))
                begin
                    next_state = STOP_1B;
                    next_tick_counter = 0;
                    next_bit_counter = -1;
                end
            end
            STOP_1B:
            begin
                next_tx = STOP_b;
                if(tick_counter == (N_TICK - 1))
                begin
                    next_done = 1;
                    next_tx_ready = 1;
                    next_thr = 0;
                    next_tsr = 0;
                    next_state = START;
                    next_tick_counter = 0;
                    next_bit_counter = 0;
                end                
            end
            default: //Fault recovery
            begin
                next_done = 1;
                next_tx_ready = 1;
                next_thr = 0;
                next_tsr = 0;
                next_state = START; 
                next_tick_counter = 0;
                next_bit_counter = 0;
            end
        endcase
    end

    assign tx = tx_reg;
    assign TxDone = done;
endmodule