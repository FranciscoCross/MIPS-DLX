module uart_top
    # ( 
    parameter N_BITS = 8, // # cantidad de bits por dato 
    parameter SB_TICK = 16, // # ticks para stop bits 
    parameter N_COUNT = 163
    )
    ( 
    input wire clk,
    input wire reset, 
    input wire tx_start,
    input wire [N_BITS - 1:0] ParamEnviar,
    output wire [N_BITS - 1:0] RESULTADO,
    output wire datoListorti 
    );


    //wires
    wire tick;
    wire tx1;
    wire tx2;
    wire rx_done1;
    wire rx_done2;
    wire tx_start_res;
    wire [N_BITS - 1:0] ParamRec;
    wire [N_BITS - 1:0] A;
    wire [N_BITS - 1:0] B;
    wire [N_BITS - 1:0] OP;
    wire [N_BITS - 1:0] RES;
    wire [N_BITS - 1:0] resuRec;
    

    baudrategen #(
    .N_BITS(N_BITS),
    .N_COUNT(N_COUNT)
    )
    u_baudrategen(
        .clock(clk),
        .reset(reset),
        .tick(tick)
    );

    uart_tx #(
    .N_BITS(N_BITS),
    .SB_TICK(SB_TICK)
    )
    u_uart_tx1(
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .s_tick(tick),
        .din(ParamEnviar),
        .tx_done_tick(),
        .tx(tx1)
    );

    uart_rx #(
        .N_BITS(N_BITS),
        .SB_TICK(SB_TICK)
    )
    u_uart_rx2(
        .clk(clk),
        .reset(reset),
        .rx(tx1),
        .s_tick(tick),
        .rx_done_tick(rx_done2),
        .dout(ParamRec)
    );

    uart_interface #(
    .N_BITS(N_BITS)
    )
    u_uart_interface(
        .clk(clk),
        .reset(reset),
        .i_dato_Recv(ParamRec),
        .i_dato_Recv_valid(rx_done2),
        .o_tx_start(tx_start_res),
        .o_A(A),
        .o_B(B),
        .o_OP(OP)
    );

    ALU #(
    .N_BITS(N_BITS),
    .N_LEDS(N_BITS)
    )
    u_ALU(
        .o_res(RES),
        .i_A(A),
        .i_B(B),
        .i_Op(OP)
    );


    uart_tx #(
    .N_BITS(N_BITS),
    .SB_TICK(SB_TICK)
    )
    u_uart_tx2(
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start_res),
        .s_tick(tick),
        .din(RES),
        .tx_done_tick(),
        .tx(tx2)
    );


    uart_rx #(
    .N_BITS(N_BITS),
    .SB_TICK(SB_TICK)
    )
    u_uart_rx1(
        .clk(clk),
        .reset(reset),
        .rx(tx2),
        .s_tick(tick),
        .rx_done_tick(datoListorti),
        .dout(RESULTADO)
    );


endmodule
