`timescale 1ns / 1ps

module tb_TOP_para_debug2;

  // Parameters
  localparam  BYTE    = 8;
  localparam  DWORD   = 32;
  localparam  ADDR    = 5;
  localparam  RB_ADDR = 5;
  localparam  NB_DATA = 8;
  localparam  NB_OP   = 6;
  localparam  NB_ST   = 10;
  localparam N_BITS   = 8;
  
  reg [DWORD-1:0] memory [255:0]; 

  // Ports
  reg               i_clock       = 1'b0;
  reg               i_reset_wz    = 1'b1;
  reg               i_reset       = 1'b1;
  reg               i_rx_done     = 1'b0;
  reg               i_tx_done     = 1'b0;
  reg [BYTE-1:0]    i_rx_data     = 8'b0;

  wire              o_halt;
  wire [NB_ST-1:0]  o_state;
  wire [BYTE-1:0]   o_tx_data;
  wire              o_tx_start;
  wire              o_locked;
  
  integer i;
  integer s;
  integer inst_counter;

    TOP_para_debug TOP_para_debug
	(
		.i_clock(i_clock),
		.i_reset(i_reset),
		.i_reset_wz(i_reset_wz),
		.i_rx_data(i_rx_data),
		.i_rx_done_tick(i_rx_done),
		.i_tx_done_tick(i_tx_done),

		.o_halt(o_halt),
		.o_locked(o_locked),
		.o_tx_start(o_tx_start),
		.o_tx_data(o_tx_data),
		.o_state(o_state)
	);
    //-------------------------------------------------------------------------------------------
    // Comandos de la debug unit
	// External commands
    localparam [N_BITS-1:0] CMD_WRITE_IM       = 8'd1; // Escribir programa
    localparam [N_BITS-1:0] CMD_START          = 8'd2; // Ejecucion continua
    localparam [N_BITS-1:0] CMD_STEP_BY_STEP   = 8'd3; // Step-by-step
    localparam [N_BITS-1:0] CMD_SEND_BR        = 8'd4; // Leer bank register
    localparam [N_BITS-1:0] CMD_SEND_MEM       = 8'd5; // Leer data memory
    localparam [N_BITS-1:0] CMD_SEND_PC        = 8'd6; // Leer PC
    localparam [N_BITS-1:0] CMD_STEP           = 8'd7; // Send step
    localparam [N_BITS-1:0] CMD_CONTINUE       = 8'd8; // Continue execution >>
    //-------------------------------------------------------------------------------------------
    // Definición de funciones
    
    // Simular recepcion por TX 
    task simular_tx();
        begin
            //#468747 //Simulando envio de un byte (8bits + 1 de bajada) -> (50e6 hz / 19200 bauds * 20) * 9 bits
            #100
            i_tx_done	= 1'b1;
            #20
            i_tx_done	= 1'b0;
        end
    endtask
    
    task simular_read_pc();
        begin
            simular_tx();
        end
    endtask
    
    task simular_read_br();
        begin
            for (i=0; i<32; i=i+1) begin
                simular_tx();
                simular_tx();
                simular_tx();
                simular_tx();
            end
        end
    endtask
    
    task simular_read_dmem();
        begin
            for (i=0; i<128; i=i+1) begin
                simular_tx();
                simular_tx();
                simular_tx();
                simular_tx();
            end
        end
    endtask
    
    task enviar_comando(input [N_BITS-1:0] comando);
        begin
            i_rx_data = comando;
            #20;
            i_rx_done = 1'b1;
            #20;
            i_rx_done = 1'b0;
        end
    endtask
    
    task ejecutar_step();
        begin
            enviar_comando(CMD_STEP);
            simular_read_pc();
            simular_read_br();
            simular_read_dmem();
        end
    endtask
    
    task enviar_instruccion(input [DWORD-1:0] instruccion);
        begin
        i_rx_data	    = instruccion[7:0]; //Primer byte LSB
        #20
        i_rx_done       = 1'b1;
        #20
        i_rx_done       = 1'b0;
        #20
        i_rx_data	    = instruccion[15:8]; //Segundo byte
        #20
        i_rx_done       = 1'b1;
        #20
        i_rx_done       = 1'b0;   
        #20
        i_rx_data	    = instruccion[23:16]; //Tercer byte
        #20
        i_rx_done       = 1'b1;
        #20
        i_rx_done       = 1'b0;
        #20
        i_rx_data	    = instruccion[31:24]; //Cuarto byte MSB
        #20
        i_rx_done       = 1'b1;
        #20
        i_rx_done       = 1'b0;
        end
    endtask 
    
    
  initial begin
    inst_counter    = 0;
    i_clock         = 1'b0;
    i_reset         = 1'b1;
    i_reset_wz      = 1'b1;
    i_rx_data       = 8'd0;
    i_rx_done       = 1'b0;
    
    //Sample program for synthesis
    
    memory[0]  = 32'b00111100000000010000000000001010; // lui R1, 10
    memory[1]  = 32'b00111100000000100000000000010100; //lui R2, 20 
    memory[2]  = 32'b00111100000000110000000000011110; //lui R3, 30
    memory[3]  = 32'b00000000001000100010000000100001; //addu R4, R1, R2
    memory[4]  = 32'b00010000011001000000000000000111; //beq R3, R4, 3
    memory[5]  = 32'b00100000000000110000000000001010; //addi R3, 10
    memory[6]  = 32'b00001000000000000000000000001000; //j 1
    memory[7]  = 32'b00100000000000110000000000001010; //addi R3, 10
    memory[8]  = 32'b10001100000001010000000000000000; //lw R5, 0(0)
    memory[9]  = 32'b10101100000001000000000000000001; //sw R4, 1(0)
    memory[10] = 32'b11111100000000000000000000000000; //halt
    
    for (i=11; i<256; i=i+1) begin
    	memory[i] = 0;
    end
    
    #100 
    i_reset_wz   = 1'b0;
    #1000 //Hasta que arranque el clock wizard
    //------------------------------------------
    i_reset         = 1'b0;
    //------------------------------------------
    enviar_comando(CMD_WRITE_IM);
    
    //Escribir memoria
    for (i=0; i<11; i=i+1) begin
        enviar_instruccion(memory[i]);
    end
    
    enviar_comando(CMD_STEP_BY_STEP);
    
    //Ejecutar!
    ejecutar_step();
    ejecutar_step();
    ejecutar_step();
    ejecutar_step();
    ejecutar_step();
    ejecutar_step();
    ejecutar_step();
    ejecutar_step();
    ejecutar_step();
    ejecutar_step();
    ejecutar_step();
    ejecutar_step();
    ejecutar_step();
    ejecutar_step();
    ejecutar_step();
    //-----------------
    ejecutar_step();
    ejecutar_step();
    ejecutar_step();
    ejecutar_step();
    ejecutar_step();

    $finish;
  end

  always
    #10  i_clock = ! i_clock ;

endmodule
