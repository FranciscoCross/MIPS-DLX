`timescale 1ns / 1ps

module rx
    #(
        parameter N_BITS = 8,     //cantidad de bits de dato
        parameter N_TICK = 8 // # ticks para stop bits 
    )(
        input wire clock,
        input wire reset,
        input wire tick,
        input wire parity,

        //Receiver interface
        input wire rx,
        output wire RxDone, //Receiver done
        output wire [N_BITS - 1:0] dout
    );

    //State declaration
    //According to Lattice semmiconductors state diagram (This implementation is a simplifed version)
    //UART Reference Design 1011 June 2011
    localparam [2 : 0] START     = 3'b000;
    localparam [2 : 0] SHIFT     = 3'b001;
    localparam [2 : 0] PARITY    = 3'b010;
    localparam [2 : 0] STOP_1B   = 3'b011;
   
    //Masks
    localparam START_BIT  = 0;
    localparam STOP_BIT   = 1;

    //State machine
    reg [2 : 0] state;

    reg done, paridad, parity_rx;

    //Register
    reg [N_BITS - 1 : 0] rsr; //Receiver Shift Register
    reg [N_BITS - 1 : 0] rbr; //Receiver Buffer Register

    //Local
    reg [4 : 0] tick_counter;
    reg [3 : 0] bit_counter;
    reg [2 : 0] start_tick_counter;

    //Next states
    reg next_done, next_paridad, next_parity_rx;
    reg [N_BITS - 1 : 0] next_rsr; 
    reg [N_BITS - 1 : 0] next_rbr; 
    reg [2 : 0] next_state;
    reg [2 : 0] next_start_tick_counter;
    reg [3 : 0] next_bit_counter;
    reg [4 : 0] next_tick_counter;

    //Reset values
    reg reset_done, reset_paridad, reset_parity_rx;
    reg [N_BITS - 1 : 0] reset_rsr; 
    reg [N_BITS - 1 : 0] reset_rbr; 
    reg [2 : 0] reset_state;
    reg [2 : 0] reset_start_tick_counter;
    reg [3 : 0] reset_bit_counter;
    reg [4 : 0] reset_tick_counter;

    //Initial value initialization
    initial begin 
        next_state              = START;
        next_done               = 0;    
        next_paridad            = 0;  
        next_parity_rx          = 0;  
        next_rsr                = 0; 
        next_rbr                = 0; 
        next_bit_counter        =-1;
        next_tick_counter       = 0;
        next_start_tick_counter = 0;

        //Reset values
        reset_state              = START;
        reset_done               = 0;    
        reset_paridad            = 0;  
        reset_parity_rx          = 0;  
        reset_rsr                = 0; 
        reset_rbr                = 0; 
        reset_bit_counter        =-1;
        reset_tick_counter       = 0;
        reset_start_tick_counter = 0;
    end

    always @(posedge clock) //Memory
    begin
        if(reset) 
        begin
            state <= reset_state;
            done <= reset_done;    
            paridad <= reset_paridad;  
            parity_rx<= reset_parity_rx;  
            rsr <= reset_rsr; 
            rbr <= reset_rbr; 
            bit_counter  <= reset_bit_counter;
            tick_counter <= reset_tick_counter;     
            start_tick_counter <= reset_start_tick_counter;
        end
        else //Update every variable state
        begin
            state <= next_state;
            done <= next_done;    
            paridad <= next_paridad;  
            parity_rx<= next_parity_rx;  
            rsr <= next_rsr; 
            rbr <= next_rbr; 
            bit_counter  <= next_bit_counter;
            tick_counter <= next_tick_counter;     
            start_tick_counter <= next_start_tick_counter;
        end
    end

    always @(posedge tick) //Next state logic
    begin
        next_tick_counter = tick_counter + 1;
        case(state)
            START:
            begin
                next_tick_counter = 0;
                if(start_tick_counter == N_TICK -1) //We need at least 8 ticks to check START 
                begin
                    next_done = 0;
                    next_state = SHIFT; 
                    next_bit_counter = 0;
                    next_rbr = 0; 
                    //next_tick_counter = ((N_TICK / 2)-1);
                    next_start_tick_counter = 0;
                end
                else 
                begin
                    if(rx == START_BIT) 
                        next_start_tick_counter = start_tick_counter + 1;
                    else
                    next_start_tick_counter = 0;        
                    next_state = START; 
                    next_bit_counter = -1;
                end
            end
            SHIFT:
            begin
                if (tick_counter == (N_TICK - 1) & (bit_counter < N_BITS )) begin
                    next_rbr = {rx, rbr[N_BITS - 1:1]}; // put the bit in the buffer register
                end
                if (tick_counter == (N_TICK*2) - 1) begin
                    next_tick_counter = 0;
                    next_bit_counter = bit_counter + 1;

                    if (bit_counter == N_BITS) begin
                        next_paridad = (^next_rbr);
                        next_bit_counter = -1;
                        if (parity) 
                            next_state = PARITY;
                        else
                            next_state = STOP_1B;
                    end else begin
                        next_state = SHIFT; // stay in the SHIFT state
                    end
                end
            end
            PARITY:
            begin
                if(tick_counter == (N_TICK - 1))
                begin
                    next_parity_rx = rx;
                end
                if(tick_counter == (N_TICK*2 - 1))
                begin
                    next_tick_counter = 0;
                    if(parity_rx == paridad) begin
                        next_state = STOP_1B;
                    end else begin
                        next_done = 1;
                        next_state = START; 
                        next_tick_counter = 0;
                        next_bit_counter = -1;
                    end
                end
            end
            STOP_1B:
            begin
                if(tick_counter == (N_TICK*2 - 1))
                begin
                    next_done = 1;
                    next_state = START;
                    next_tick_counter = 0;
                    next_bit_counter = -1;
                end                
            end
            default: //Fault recovery
            begin
                next_done = 1;
                next_state = START; 
                next_tick_counter = 0;
                next_bit_counter = -1;
            end
        endcase
    end

    assign dout = rbr;
    assign RxDone = done;
endmodule