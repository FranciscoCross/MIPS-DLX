`timescale 10ns / 1ps //10ns es el semi ciclo, un ciclo entero tiene 20ns osea 50MHz
module baudrategen
    #(
        parameter N_BITS = 8,
        parameter N_COUNT = 163 //Se espera que cada 163 ciclos de clock generar una señal tick para muestrear
    )                           //El valor 163 es para un baudrate de 19200 bauds y un clock de 50MHz (50*10^6 / 19200*16)
    (
        input wire clock,
        input wire reset,
        output wire tick
    );

    reg [N_BITS-1:0] count;
    wire reset_counter = (count == N_COUNT-1) ? 1'b1 : 1'b0;

    always @(posedge clock)
    begin
        if(reset) count <= 0;
        else if (reset_counter) count <= 0;
        else count = count + 1;        
    end

    assign tick = reset_counter;
endmodule