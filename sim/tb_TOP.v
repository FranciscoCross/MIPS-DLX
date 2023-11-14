`timescale 1ns / 1ps

module tb_TOP;

  // Parameters
  localparam  BYTE = 8;
  localparam  DWORD = 32;
  localparam  ADDR = 5;
  localparam  NB_MEM_DEPTH = 8;
  localparam  RB_ADDR = 5;
  localparam  NB_STATE = 10;
  localparam  NB_DATA = 8;
  localparam  NB_OP = 6;


  // Ports
  reg             i_clock       = 0;
  reg             i_reset       = 0;
  reg             i_clock_reset = 0;
  reg             i_uart_debug_unit_rx  = 0;
  reg [BYTE-1:0]  command       = 8'd0;
  reg             send          = 1'b0;

  wire uart_debug_unit_tx;
  wire uart_debug_unit_rx;
  wire clk_wzrd;  // Borrar

  wire o_halt;
  wire [NB_STATE-1:0] o_state;
  
  // UART externa
  reg i_rx;
  wire [BYTE-1:0] o_rx;
  wire o_rx_done_tick;
  wire o_tx_done_tick;
  
  integer i;
  integer inst_counter = 0;
  reg [NB_DATA-1:0] memory [255:0]; 

  TOP TOP (.i_clock (i_clock),
            .i_reset (i_reset),
            .i_clock_reset (i_clock_reset),
            .i_uart_debug_unit_rx (uart_debug_unit_rx),
            .o_uart_debug_unit_tx (uart_debug_unit_tx),
            .o_halt (o_halt),
            .o_state (o_state),
            .o_clk(clk_wzrd)
        );

  UART #(.NB_DATA(NB_DATA),
         .NB_OP(NB_OP))
  UART(.i_clock(clk_wzrd), // Cambiar
           .i_reset(i_reset),
           .i_rx(uart_debug_unit_tx),
           .i_tx(command),
           .i_tx_start(send),
           .o_rx(o_rx),
           .o_rx_done_tick(o_rx_done_tick),
           .o_tx(uart_debug_unit_rx),
           .o_tx_done_tick(o_tx_done_tick));       

  initial begin
    i_clock       = 1'b0;
    i_reset       = 1'b1;
    i_clock_reset = 1'b1;
    command       = 8'd0;
    send          = 1'b0;

    #100
    i_clock_reset = 1'b0;

    #600
    i_reset = 1'b0;

    $monitor("[$monitor] time=%0t o_state=%b ", $time, o_state);
    $monitor("[$monitor] time=%0t o_rx   =%h ", $time, o_rx);
    $monitor("[$monitor] time=%0t o_rx_done_tick   =%h ", $time, o_rx_done_tick);

    // write instruction memory
    #400
    $display("Write IM.");
    command = 8'd1; // WRITE_IM
    send    = 1'b1;

    #20
    send    = 1'b0;

    $readmemb("/instructions.mem", memory, 0, 255);
    // Se envia instruccion por instruccion, byte por byte
    for (i=0; i<40; i=i+1) begin
        #550000
        $display("instructions : ",inst_counter);
        inst_counter = inst_counter+1;
    	$display("valor: ", memory[i]);
		#20
		command	= memory[i];
		send	= 1'b1;

		#20
		send	= 1'b0;
    end

//     // Ejecucion continua
//     #550000
//     // $display("Sate after write INSTRUCTION MEMORY, state = %b", o_state);
//     $display("Ejecucón continua");
//     command = 2;
//     send = 1'b1;

//     #20
//     send = 1'b0;

// //    read bank register
//     #3000000
//     $display("Display read BANK REGISTER. time=%0t", $time);
//     command = 8'd4;
//     send    = 1'b1;

//     #20
//     send    = 1'b0;
    
//     // read data memory
//     #70000000
//     #20
//     $display("Display read DATA MEMORY.  time=%0t", $time);
//     command = 8'd5;
//     send    = 1'b1;

//     #20
//     send = 1'b0;

//     // read PC
//     #70000000
//     #20
//     $display("Display read PC.  time=%0t", $time);
//     command = 8'd6;
//     send    = 1'b1;

//     #20
//     send = 1'b0;
        // Ejecucion STEP BY STEP
    #550000
    $display("Ejecución step by step. time = %0t", $time);
    command = 3;
    send = 1'b1;

    #20
    send = 1'b0;

    #550000
    $display("Send step 1. time = %0t", $time);
    command = 7;
    send = 1'b1;
    #20
    send = 1'b0;
    #550000
    #2200000 // lectura de PC
    #80000000 // lectura de BR 
    #60000000 // lectura de MEM
    
    $display("Send step 2. time = %0t", $time);
    command = 7;
    send = 1'b1;
    #20
    send = 1'b0;
    #550000
    #2200000 // lectura de PC
    #80000000 // lectura de BR 
    #60000000 // lectura de MEM

    $display("Send step 3. time = %0t", $time);
    command = 7;
    send = 1'b1;
    #20
    send = 1'b0;
    #550000
    #2200000 // lectura de PC
    #80000000 // lectura de BR 
    #60000000 // lectura de MEM
    
    $display("Send step 4. time = %0t", $time);
    command = 7;
    send = 1'b1;
    #20
    send = 1'b0;
    #550000
    #2200000 // lectura de PC
    #80000000 // lectura de BR 
    #60000000 // lectura de MEM
    
    $display("Send step 5. time = %0t", $time);
    command = 7;
    send = 1'b1;
    #20
    send = 1'b0;
    #550000
    #2200000 // lectura de PC
    #80000000 // lectura de BR 
    #60000000 // lectura de MEM

    $display("Continuar con ejecucion. time = %0t", $time);
    command = 8;
    send = 1'b1;

    #20
    send = 1'b0;

    #2200000

    $finish;
  end

  always
    #5  i_clock = ! i_clock ;

endmodule
