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

    reg clock = 0;
    reg reset = 0;

    reg reset_wz = 0;
    reg tx_start = 0;
    reg [NB_BITS-1 : 0] tx_data = 0;
    
    TOP #(	
		.CLOCK(CLK),
		.BAUD_RATE(BAUD_RATE),		
		.NB_DATA(NB_BYTES)	
    ) instancia_TOP	(
		.i_clock(clock),
		.i_reset(reset),
		.i_reset_wz(reset_wz),
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
    ) uart_PC (
        .clock(clock_w),
        .reset(reset),
        .tx_start(tx_start),
        .parity(1),
        .rx(wire_rx),
        .tx_data(tx_data),
        .rx_data(wire_rx_data),
        .tx(wire_tx),
        .rx_done(wire_rx_done),
        .tx_done(wire_tx_done)
    );
    
   	clock_wz clock_wz_pc
  	(  
		.clk_out1(clock_w),
	  	.reset(reset), 
	  	.locked(),
	  	.clk_in1(clock)
	 );

  // Clock generation    
    always @* 
    begin
        forever 
            begin
              forever #10 clock = ~clock; //clock a 50MHz -> 20ns de periodo
            end
    end

       initial begin
            reset_wz = 0;
            reset = 0;
            #10
            reset_wz = 1;
            reset = 1;
            #10
            reset_wz = 0;
            reset = 0;
            $display("Envio numero de instrucciones");
            
            #100
            tx_data = 8'b00001011;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;

            #200000
            $display("Envio primer byte de instruccion lui R1, 10 "); //32'b00111100000000010000000000001010; 3C01000A // lui R1, 10
            #20
            tx_data = 8'b00001010;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio segundo byte de instruccion lui R1, 10"); //32'b00111100 00000001 00000000 00001010;  // lui R1, 10
            #20
            tx_data = 8'b00000000;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio tercer byte de instruccion lui R1, 10"); //32'b00111100 00000001 00000000 00001010;  // lui R1, 10
            #20
            tx_data = 8'b00000001;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio cuarto byte de instruccion lui R1, 10"); //32'b00111100 00000001 00000000 00001010;  // lui R1, 10
            #20
            tx_data = 8'b00111100;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            
            
            $display("Envio primer byte de instruccion lui R2, 20"); //32'b00111100 00000010 00000000 00010100; //lui R2, 20
            #20
            tx_data = 8'b00010100;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio segundo byte de instruccion lui R2, 20"); //32'b00111100 00000010 00000000 00010100; //lui R2, 20
            #20
            tx_data = 8'b00000000;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio tercer byte de instruccion lui R2, 20"); //32'b00111100 00000010 00000000 00010100; //lui R2, 20
            #20
            tx_data = 8'b00000010;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio cuarto byte de instruccion lui R2, 20"); //32'b00111100 00000010 00000000 00010100; //lui R2, 20
            #20
            tx_data = 8'b00111100;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            
            
            
            $display("Envio primer byte de instruccion lui R3, 30"); //32'b00111100 00000011 00000000 00011110; //lui R3, 30
            #20
            tx_data = 8'b00011110;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio segundo byte de instruccion lui R3, 30");  //32'b00111100 00000011 00000000 00011110; //lui R3, 30
            #20
            tx_data = 8'b00000000;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio tercer byte de instruccion lui R3, 30");  //32'b00111100 00000011 00000000 00011110; //lui R3, 30
            #20
            tx_data = 8'b00000011;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio cuarto byte de instruccion lui R3, 30");  //32'b00111100 00000011 00000000 00011110; //lui R3, 30
            #20
            tx_data = 8'b00111100;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            
            
            $display("Envio primer byte de instruccion addu R4, R1, R2 "); //32'b00000000 00100010 00100000 00100001; //addu R4, R1, R2 
            #20
            tx_data = 8'b00100001;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio segundo byte de instruccion addu R4, R1, R2 "); //32'b00000000 00100010 00100000 00100001; //addu R4, R1, R2 
            #20
            tx_data = 8'b00100000;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio tercer byte de instruccion addu R4, R1, R2 "); //32'b00000000 00100010 00100000 00100001; //addu R4, R1, R2 
            #20
            tx_data = 8'b00100010;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio cuarto byte de instruccion addu R4, R1, R2 "); //32'b00000000 00100010 00100000 00100001; //addu R4, R1, R2 
            #20
            tx_data = 8'b00000000;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            
            
            $display("Envio primer byte de instruccion beq R3, R4, 3"); //32'b00010000 01100100 00000000 00000111; //beq R3, R4, 3
            #20
            tx_data = 8'b00000111;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio segundo byte de instruccion beq R3, R4, 3"); //32'b00010000 01100100 00000000 00000111; //beq R3, R4, 3
            #20
            tx_data = 8'b00000000;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio tercer byte de instruccion beq R3, R4, 3"); //32'b00010000 01100100 00000000 00000111; //beq R3, R4, 3
            #20
            tx_data = 8'b01100100;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio cuarto byte de instruccion beq R3, R4, 3"); //32'b00010000 01100100 00000000 00000111; //beq R3, R4, 3
            #20
            tx_data = 8'b00010000;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            
            
            
            $display("Envio primer byte de instruccion addi R3, 10"); //32'b00100000 00000011 00000000 00001010; //addi R3, 10
            #20
            tx_data = 8'b00001010;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio segundo byte de instruccion addi R3, 10"); //32'b00100000 00000011 00000000 00001010; //addi R3, 10
            #20
            tx_data = 8'b00000000;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio tercer byte de instruccion addi R3, 10"); //32'b00100000 00000011 00000000 00001010; //addi R3, 10
            #20
            tx_data = 8'b00000011;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio cuarto byte de instruccion addi R3, 10"); //32'b00100000 00000011 00000000 00001010; //addi R3, 10
            #20
            tx_data = 8'b00100000;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            
            
            
            $display("Envio primer byte de instruccion j 1"); //32'b00001000 00000000 00000000 00001000; //j 1
            #20
            tx_data = 8'b00001000;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio segundo byte de instruccion j 1"); //32'b00001000 00000000 00000000 00001000; //j 1
            #20
            tx_data = 8'b00000000;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio tercer byte de instruccion j 1"); //32'b00001000 00000000 00000000 00001000; //j 1
            #20
            tx_data = 8'b00000000;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio cuarto byte de instruccion j 1"); //32'b00001000 00000000 00000000 00001000; //j 1
            #20
            tx_data = 8'b00001000;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            
            
            
            $display("Envio primer byte de instruccion addi R3, 10"); //32'b00100000 00000011 00000000 00001010; //addi R3, 10
            #20
            tx_data = 8'b00001010;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio segundo byte de instruccion addi R3, 10"); //32'b00100000 00000011 00000000 00001010; //addi R3, 10
            #20
            tx_data = 8'b00000000;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio tercer byte de instruccion addi R3, 10"); //32'b00100000 00000011 00000000 00001010; //addi R3, 10
            #20
            tx_data = 8'b00000011;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio cuarto byte de instruccion addi R3, 10"); //32'b00100000 00000011 00000000 00001010; //addi R3, 10
            #20
            tx_data = 8'b00100000;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            
            
            
            $display("Envio primer byte de instruccion lw R5, 0(0)"); //32'b10001100 00000101 00000000 00000000; //lw R5, 0(0)
            #20
            tx_data = 8'b00000000;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio segundo byte de instruccion lw R5, 0(0)"); //32'b10001100 00000101 00000000 00000000; //lw R5, 0(0)
            #20
            tx_data = 8'b00000000;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio tercer byte de instruccion lw R5, 0(0)"); //32'b10001100 00000101 00000000 00000000; //lw R5, 0(0)
            #20
            tx_data = 8'b00000101;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio cuarto byte de instruccion lw R5, 0(0)");//32'b10001100 00000101 00000000 00000000; //lw R5, 0(0)
            #20
            tx_data = 8'b10001100;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            
            
            
            
            $display("Envio primer byte de instruccion sw R4, 1(0)"); //32'b10101100 00000100 00000000 00000001; //sw R4, 1(0)
            #20
            tx_data = 8'b00000001;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio segundo byte de instruccion sw R4, 1(0)"); //32'b10101100 00000100 00000000 00000001; //sw R4, 1(0)
            #20
            tx_data = 8'b00000000;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio tercer byte de instruccion sw R4, 1(0)"); //32'b10101100 00000100 00000000 00000001; //sw R4, 1(0)
            #20
            tx_data = 8'b00000100;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio cuarto byte de instruccion sw R4, 1(0)"); //32'b10101100 00000100 00000000 00000001; //sw R4, 1(0)
            #20
            tx_data = 8'b10101100;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            
            
            
            $display("Envio primer byte de instruccion HALT"); //32'b11111100 00000000 00000000 00000000;  // HALT
            #20
            tx_data = 8'b00000000;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio segundo byte de instruccion HALT"); //32'b11111100 00000000 00000000 00000000;  // HALT
            #20
            tx_data = 8'b00000000;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio tercer byte de instruccion HALT"); //32'b11111100 00000000 00000000 00000000;  // HALT
            #20
            tx_data = 8'b00000000;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            $display("Envio cuarto byte de instruccion HALT"); //32'b11111100 00000000 00000000 00000000;  // HALT
            #20
            tx_data = 8'b11111100;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000
            
            $display("Envio ModeOperate"); //32'b11111100 00000000 00000000 00000000;  // HALT
            #20
            tx_data = 8'b00010000;     
            #2
            tx_start = 1;
            #6000
            tx_start = 0;
            #200000

            $finish;
 
        end
endmodule
