`timescale 1ns / 1ps

module tb_TOP(

    );

    localparam CLK  = 50E6;
    localparam BAUD_RATE  = 115200;
    localparam NB_DATA  = 32;
    localparam NB_BYTES = 8;
    localparam NB_BITS = 8;
    localparam NB_STATE  = 11;

    wire wire_rx, wire_tx, wire_rx_done, wire_tx_done, wire_locked, wire_ack, wire_end_send_data;
    wire [NB_BITS -1 : 0] wire_rx_data;

    reg reg_clock = 0;
    reg reg_reset = 0;

    reg reg_reset_wz = 0;
    reg reg_tx_start = 0;
    reg [NB_BITS-1 : 0]reg_tx_data = 0;
    
    TOP #(	
		.CLOCK(CLK),
		.BAUD_RATE(BAUD_RATE),		
		.NB_DATA(NB_BYTES)	
    ) instancia_TOP	(
		.i_clock(reg_clock),
		.i_reset(reg_reset),
		.i_reset_wz(reg_reset_wz),
		.i_rx_data(wire_tx),

		.o_tx_data(wire_rx),
		.o_locked(wire_locked),	
		.o_ack_debug(wire_ack),
		.o_end_send_data(wire_end_send_data)
	);

    uart #(
        .CLK(CLK),
        .BAUD_RATE(BAUD_RATE),
        .NB_DATA(NB_BYTES)
    ) instancia_uart (
        .clock(reg_clock),
        .reset(reg_reset),
        .tx_start(reg_tx_start),
        .parity(1),
        .rx(wire_rx),
        .tx_data(reg_tx_data),
        .rx_data(wire_rx_data),
        .tx(wire_tx),
        .rx_done(wire_rx_done),
        .tx_done(wire_tx_done)
    );

        always #1 reg_clock = ~reg_clock; // # < timeunit > delay
       initial begin
            reg_reset_wz = 0;
            reg_reset = 0;
            #10
            reg_reset_wz = 1;
            reg_reset = 1;
            #10
            reg_reset_wz = 0;
            reg_reset = 0;
            
            wait(wire_locked == 1'b1); 

            $display("Envio numero de instrucciones");

            reg_tx_data = 8'b00000001;     
            reg_tx_start = 1;
            #10
            reg_tx_start = 0;
            
            while (!wire_tx_done) begin
                #5; // Wait 5 time units before checking again
            end

            $display("Recibio numero de instrucciones");
            /*
            #2          
            $display("Envio primer byte de instruccion 1");
            reg_tx_data = 8'b00100000;     
            #1000
            reg_tx_start = 1;
            #100
            reg_tx_start = 0;
            
            while (!wire_tx_done) begin
                #5; // Wait 5 time units before checking again
            end
            #2          
            $display("Envio segundno byte de instruccion 1");
            reg_tx_data = 8'b00001111;     
            #1000
            reg_tx_start = 1;
            #100
            reg_tx_start = 0;
            
            while (!wire_tx_done) begin
                #5; // Wait 5 time units before checking again
            end
            #2          
            $display("Envio tercer byte de instruccion 1");
            reg_tx_data = 8'b00001111;     
            #1000
            reg_tx_start = 1;
            #100
            reg_tx_start = 0;
            
            while (!wire_tx_done) begin
                #5; // Wait 5 time units before checking again
            end
            #2          
            $display("Envio cuarto byte de instruccion 1");
            reg_tx_data = 8'b00001111;     
            #1000
            reg_tx_start = 1;
            #100
            reg_tx_start = 0;
            */
            #10000
            $finish;
 
        end
endmodule
