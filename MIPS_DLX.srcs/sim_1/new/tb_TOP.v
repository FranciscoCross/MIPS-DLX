`timescale 1ns / 1ps

module tb_TOP(

    );

    localparam CLK  = 50E6;
    localparam BAUD_RATE  = 115200;
    localparam NB_DATA  = 32;
    localparam NB_BYTES = 8;
    localparam NB_BITS = 8;
    localparam NB_STATE = 12;

    wire wire_rx, wire_tx, wire_rx_done, aux_tx_done, wire_locked;
    wire [NB_STATE-1:0] wire_state;
    wire [NB_BITS -1 : 0] wire_rx_data;

    reg clock = 0;
    reg reset = 0;

    reg reset_wz = 0;
    reg aux_tx_start = 0;
    reg [NB_BITS-1 : 0] aux_tx_data = 0;
    
    TOP #(	
		.CLOCK(CLK),
		.BAUD_RATE(BAUD_RATE),		
		.NB_DATA(NB_BYTES)	
    ) instancia_TOP	(
		.i_clock(clock),
		.i_reset(reset),
		.i_rx(wire_tx),

		.o_tx(wire_rx),
    .o_state(wire_state)
	);

  UART2 uart2_PC
      (
      .i_clock(clock_w),
      .i_reset(reset),
      .i_rx(wire_rx),
      .i_tx(aux_tx_data), 
      .i_tx_start(aux_tx_start),
      .o_rx(wire_rx_data),
      .o_rx_done_tick(wire_rx_done),
      .o_tx(wire_tx),
      .o_tx_done_tick(aux_tx_done)
      );
    
   	clock_wz clock_wz_pc
  	(  
		.clk_out1(clock_w),
	  	.reset(reset_wz), 
	  	.clk_in1(clock)
	 );

  // Clock generation    
  always #10 clock = ~clock; // # < timeunit > delay

       initial begin
            #20
            reset_wz = 0;
            #20
            reset_wz = 1;
            #20
            reset_wz = 0;
            #1000
            reset = 0;
            #20
            reset = 1;
            #20
            reset = 0;
            
            
            
            $display("Envio numero de instrucciones");
            aux_tx_data = 8'b00001011;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done) begin
                  #1; // Wait 5 time units before checking again
            end
            #50  




            $display("Envio primer byte de instruccion 1"); //32'b00111100000000010000000000001010; 3C01000A // lui R1, 10
            aux_tx_data = 8'b00001010;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio segundo byte de instruccion 1"); //32'b00111100000000010000000000001010; 3C01000A // lui R1, 10
            aux_tx_data = 8'b00000000;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio tercer byte de instruccion 1"); //32'b00111100000000010000000000001010; 3C01000A // lui R1, 10
            aux_tx_data = 8'b00000001;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio cuarto byte de instruccion 1"); //32'b00111100000000010000000000001010; 3C01000A // lui R1, 10
            aux_tx_data = 8'b00111100;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #50
            

            $display("Envio primer byte de instruccion 2"); //32'b00111100 00000010 00000000 00010100; //3C020014 //lui R2, 20
            aux_tx_data = 8'b00010100;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio segundo byte de instruccion 2"); //32'b00111100 00000010 00000000 00010100; //lui R2, 20
            aux_tx_data = 8'b00000000;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio tercer byte de instruccion 2"); //32'b00111100 00000010 00000000 00010100; //lui R2, 20
            aux_tx_data = 8'b00000010;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio cuarto byte de instruccion 2"); //32'b00111100 00000010 00000000 00010100; //lui R2, 20
            aux_tx_data = 8'b00111100;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #50            
            


            $display("Envio primer byte de instruccion 3");  //32'b00111100 00000011 00000000 00011110; //lui R3, 30
            aux_tx_data = 8'b00011110;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio segundo byte de instruccion 3");  //32'b00111100 00000011 00000000 00011110; //lui R3, 30
            aux_tx_data = 8'b00000000;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio tercer byte de instruccion 3");  //32'b00111100 00000011 00000000 00011110; //lui R3, 30
            aux_tx_data = 8'b00000011;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio cuarto byte de instruccion 3");  //32'b00111100 00000011 00000000 00011110; //lui R3, 30
            aux_tx_data = 8'b00111100;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #50 
            
            


            $display("Envio primer byte de instruccion 4");   //32'b00000000 00100010 00100000 00100001; //addu R4, R1, R2 
            aux_tx_data = 8'b00100001;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio segundo byte de instruccion 4");  //32'b00000000 00100010 00100000 00100001; //addu R4, R1, R2 
            aux_tx_data = 8'b00100000;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio tercer byte de instruccion 4");   //32'b00000000 00100010 00100000 00100001; //addu R4, R1, R2 
            aux_tx_data = 8'b00100010;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio cuarto byte de instruccion 4");   //32'b00000000 00100010 00100000 00100001; //addu R4, R1, R2 
            aux_tx_data = 8'b00000000;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #50              
            
            


            $display("Envio primer byte de instruccion 5");   //32'b00010000 01100100 00000000 00000111; //beq R3, R4, 3
            aux_tx_data = 8'b00000111;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio segundo byte de instruccion 5");  //32'b00010000 01100100 00000000 00000111; //beq R3, R4, 3 
            aux_tx_data = 8'b00000000;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio tercer byte de instruccion 5");   //32'b00010000 01100100 00000000 00000111; //beq R3, R4, 3
            aux_tx_data = 8'b01100100;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20

            $display("Envio cuarto byte de instruccion 5");   //32'b00010000 01100100 00000000 00000111; //beq R3, R4, 3
            aux_tx_data = 8'b00010000;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #50             
            
            


            $display("Envio primer byte de instruccion 6");   //32'b00100000 00000011 00000000 00001010; //addi R3, 10
            aux_tx_data = 8'b00001010;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio segundo byte de instruccion 6");  //32'b00100000 00000011 00000000 00001010; //addi R3, 10
            aux_tx_data = 8'b00000000;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio tercer byte de instruccion 6");   //32'b00100000 00000011 00000000 00001010; //addi R3, 10
            aux_tx_data = 8'b00000011;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio cuarto byte de instruccion 6");   //32'b00100000 00000011 00000000 00001010; //addi R3, 10
            aux_tx_data = 8'b00100000;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #50          
            
            


            $display("Envio primer byte de instruccion 7");   //32'b00001000 00000000 00000000 00001000; //j 1
            aux_tx_data = 8'b00001000;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio segundo byte de instruccion 7");  //32'b00001000 00000000 00000000 00001000; //j 1
            aux_tx_data = 8'b00000000;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio tercer byte de instruccion 7");   //32'b00001000 00000000 00000000 00001000; //j 1
            aux_tx_data = 8'b00000000;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio cuarto byte de instruccion 7");   //32'b00001000 00000000 00000000 00001000; //j 1
            aux_tx_data = 8'b00001000;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #50 
            
            


            $display("Envio primer byte de instruccion 8");   //32'b00100000 00000011 00000000 00001010; //addi R3, 10
            aux_tx_data = 8'b00001010;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio segundo byte de instruccion 8");  //32'b00100000 00000011 00000000 00001010; //addi R3, 10
            aux_tx_data = 8'b00000000;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio tercer byte de instruccion 8");   //32'b00100000 00000011 00000000 00001010; //addi R3, 10
            aux_tx_data = 8'b00000011;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio cuarto byte de instruccion 8");   //32'b00100000 00000011 00000000 00001010; //addi R3, 10
            aux_tx_data = 8'b00100000;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #50                          
            
            


            $display("Envio primer byte de instruccion 9");  //32'b10001100 00000101 00000000 00000000; //lw R5, 0(0)
            aux_tx_data = 8'b00000000;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio segundo byte de instruccion 9");  //32'b10001100 00000101 00000000 00000000; //lw R5, 0(0)
            aux_tx_data = 8'b00000000;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio tercer byte de instruccion 9");   //32'b10001100 00000101 00000000 00000000; //lw R5, 0(0)
            aux_tx_data = 8'b00000101;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio cuarto byte de instruccion 9");   //32'b10001100 00000101 00000000 00000000; //lw R5, 0(0)
            aux_tx_data = 8'b10001100;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #50
            
            


            $display("Envio primer byte de instruccion 10");  //32'b10101100 00000100 00000000 00000001; //sw R4, 1(0)
            aux_tx_data = 8'b00000001;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio segundo byte de instruccion 10");  //32'b10101100 00000100 00000000 00000001; //sw R4, 1(0)
            aux_tx_data = 8'b00000000;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio tercer byte de instruccion 10");   //32'b10101100 00000100 00000000 00000001; //sw R4, 1(0)
            aux_tx_data = 8'b00000100;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio cuarto byte de instruccion 10");   //32'b10101100 00000100 00000000 00000001; //sw R4, 1(0)
            aux_tx_data = 8'b10101100;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #50                    
            
            


            $display("Envio primer byte de instruccion 11"); //32'b11111100 00000000 00000000 00000000;  // HALT
            aux_tx_data = 8'b00000000;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20

            $display("Envio segundo byte de instruccion 11");  //32'b11111100 00000000 00000000 00000000;  // HALT
            aux_tx_data = 8'b00000000;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio tercer byte de instruccion 11");   //32'b11111100 00000000 00000000 00000000;  // HALT
            aux_tx_data = 8'b00000000;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20 

            $display("Envio cuarto byte de instruccion 11");  //32'b11111100 00000000 00000000 00000000;  // HALT
            aux_tx_data = 8'b11111100;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #100            

            $display("Envio ModeOperate");  //32'b11111100 00000000 00000000 00000000;  // HALT
            aux_tx_data = 8'b00010000;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #10000               

            $finish;
 
        end
endmodule
