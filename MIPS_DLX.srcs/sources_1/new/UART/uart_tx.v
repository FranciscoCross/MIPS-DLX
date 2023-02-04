module uart_tx
    #(
        parameter N_BITS = 8,     //cantidad de bits de dato
        parameter SB_TICK = 16 // # ticks para stop bits 
    )
    (
    input wire clk,
    input wire reset,
    input wire tx_start,
    input wire s_tick,
    input wire [N_BITS - 1 : 0] din,
    output reg tx_done_tick,
    output wire tx 
    );

    //Declaracion de los estados
    localparam [2 : 0] idle    = 3'b000;
    localparam [2 : 0] start   = 3'b001;
    localparam [2 : 0] data    = 3'b010;
    localparam [2 : 0] parity  = 3'b011;
    localparam [2 : 0] stop    = 3'b100;

    //Declaracion de las seniales
    reg [2 : 0] state_reg;
    reg [2 : 0] state_next; 
    reg [3 : 0] s_reg;
    reg [3 : 0] s_next; 
    reg [2 : 0] n_reg; 
    reg [2 : 0] n_next; 
    reg [N_BITS - 1 : 0] b_reg; 
    reg [N_BITS - 1 : 0] b_next;
    reg tx_reg;
    reg tx_next;
    reg paridad;

    //maquina de estados para los estados y datos
    always @(posedge clk)begin
        if (reset)
            begin
                state_reg <= idle;
                s_reg <= 0;
                n_reg <= 0;
                b_reg <= 0;
                tx_reg <= 1'b1;
            end        
        else
            begin
                state_reg <= state_next;
                s_reg <= s_next;
                n_reg <= n_next;
                b_reg <= b_next;
                tx_reg <= tx_next;
            end
    end

    //Maquina de estados para proximo estado
    always @(*) begin
        state_next = state_reg;
        tx_done_tick = 1'b0;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;
        tx_next = tx_reg;

        case (state_reg)
            idle:
                begin
                    tx_next = 1'b1;
                    if (tx_start) 
                        begin
                            state_next = start;
                            s_next = 0;
                            b_next = din;
                        end    
                end 

            start:
                begin
                    tx_next = 1'b0;
                    if (s_tick) 
                        begin
                            if (s_reg == (SB_TICK - 1)) 
                                begin 
                                state_next = data; 
                                s_next = 0; 
                                n_next = 0; 
                                end 
                            else 
                                s_next = s_reg + 1;     
                        end
                end

            data:
                begin
                    tx_next = b_reg[0];
                    if (s_tick)
                        begin
                            if (s_reg == (SB_TICK - 1))
                                begin
                                    s_next = 0;
                                    b_next = b_reg >> 1;
                                    if (n_reg == (N_BITS - 1)) 
                                        begin
                                        paridad = (^din);
                                        state_next = parity;
                                        n_next = 0;
                                        end
                                    else
                                        n_next = n_reg + 1;
                                end
                            else   
                                s_next = s_reg + 1;
                        end
                end
            parity:
                begin
                    tx_next = paridad;
                    if (s_tick)
                        begin
                            if (s_reg == (SB_TICK - 1))
                                begin
                                    //tx_next =  (^b_reg);
                                    state_next = stop; 
                                    s_next = 0;  
                                end
                            else
                                s_next = s_reg + 1;
                                
                        end
                end

            stop:
                begin
                    tx_next = 1'b1;
                    if (s_tick)
                        begin
                            if (s_reg == (SB_TICK - 1))
                                begin
                                    state_next = idle;
                                    tx_done_tick = 1'b1;
                                end
                            else
                                s_next = s_reg + 1;
                        end
                end
            //default: 
            //agregar
        endcase
    end
    assign tx = tx_reg; 

    endmodule 
