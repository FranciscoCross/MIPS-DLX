`timescale 1ns / 1ps

module tb_debugUnit;
    localparam NB_BITES = 8;
    localparam NB_STATE  = 11;
    localparam NB_DATA  = 32;
    
    reg clock = 0;
    reg reset = 0;
    reg halt = 0;
    wire rx_data;
    reg [7 : 0] program_counter = 8'b11111111;
    reg reg_debug_unit = 0;
    reg bit_sucio = 0;
    reg mem_debug_unit = 0;
    reg [7 : 0] cant_cycles_d = 8'b11111111;
    reg tx_start_d = 0;
    reg data_ready_uart_d = 0;
    reg tx_done_d = 0;	
    reg [NB_BITES-1: 0] data_uart_d = 0;

    //Outputs

    wire [5-1:0] o_addr_reg_debug_unit; //32 reg
    wire [7-1:0] o_addr_mem_debug_unit; //128 elementos en memoria
    wire o_ctrl_addr_debug_mem;
    wire o_ctrl_wr_debug_mem;
    wire o_ctrl_read_debug_reg;
    wire o_tx_data;
    wire o_en_write;
    wire o_en_read;		
    wire o_enable_pipe;
    wire o_enable_mem;
    wire o_debug_unit_reg;		
    wire [NB_DATA-1:0] o_inst_load;
    wire [7-1:0] o_address;
    wire o_ack_debug;
    wire o_end_send_data;
    wire o_data_ready;
    wire o_en_read_cant_instr;
    wire o_receive_full_inst;
    wire o_send_inst_finish;
    wire [NB_STATE-1:0] o_state;
    wire [NB_BITES-1: 0] o_data_receive;
    wire o_tx_start;

    /*Auxiliary UART Unit*/
    reg aux_tx_start;
    reg [7 : 0]aux_tx_data = 0;
    wire [7 : 0]aux_rx_data;
    wire aux_rx_done;
    wire aux_tx_done;
    always #1 clock = ~clock; // # < timeunit > delay
       initial begin
            #0
            reset = 0;
            aux_tx_start = 0;     
            #1
            reset = 1;   
            #1
            reset = 0;
            #2            
            $display("Envio numero de instrucciones");

            aux_tx_data = 8'b00000001;     
            #1000
            aux_tx_start = 1;
            #100
            aux_tx_start = 0;
            
            while (!aux_tx_done) begin
                #5; // Wait 5 time units before checking again
            end
            #2          
            $display("Envio primer byte de instruccion 1");
            aux_tx_data = 8'b00001111;     
            #1000
            aux_tx_start = 1;
            #100
            aux_tx_start = 0;
            
            while (!aux_tx_done) begin
                #5; // Wait 5 time units before checking again
            end
            #2          
            $display("Envio segundno byte de instruccion 1");
            aux_tx_data = 8'b00001111;     
            #1000
            aux_tx_start = 1;
            #100
            aux_tx_start = 0;
            
            while (!aux_tx_done) begin
                #5; // Wait 5 time units before checking again
            end
            #2          
            $display("Envio tercer byte de instruccion 1");
            aux_tx_data = 8'b00001111;     
            #1000
            aux_tx_start = 1;
            #100
            aux_tx_start = 0;
            
            while (!aux_tx_done) begin
                #5; // Wait 5 time units before checking again
            end
            #2          
            $display("Envio cuarto byte de instruccion 1");
            aux_tx_data = 8'b00001111;     
            #1000
            aux_tx_start = 1;
            #100
            aux_tx_start = 0;
            
            while (!aux_tx_done) begin
                #5; // Wait 5 time units before checking again
            end
            #2
            $display("Envio modo de operacion step/continuo");
            //ENVIO EL EL MODO DE OPERACION ENTRE STEP TO STEP (8'b00000100) O CONTINUO(b00010000)
            aux_tx_data = 8'b00010000;     
            #1000
            aux_tx_start = 1;
            #100
            aux_tx_start = 0;
            
            while (!aux_tx_done) begin
                #5; // Wait 5 time units before checking again
            end
             #2
            $display("Envio un halt");
            #10000
            halt = 1;
            #100
            halt = 0;
            //$display("Envio primer byte de instruccion 1");
            #1000000
            $finish;
 
        end
    
    debug_unit #(.BAUD_RATE(115200)) debug_unit
	(
		.i_clock(clock),
		.i_reset(reset),
		.i_halt(halt),	
		.i_rx_data(rx_data),	
		.i_send_program_counter(program_counter), //pc + 1
		.i_cant_cycles(cant_cycles_d),
		.i_reg_debug_unit(reg_debug_unit), //viene del banco de registros
		.i_bit_sucio(bit_sucio),
		.i_mem_debug_unit(mem_debug_unit),
		
        .o_addr_reg_debug_unit(o_addr_reg_debug_unit),// direccion a leer del registro para enviar a pc
        .o_addr_mem_debug_unit(o_addr_mem_debug_unit), //direccion a leer en memoria
		.o_ctrl_addr_debug_mem(o_ctrl_addr_debug_mem),
		.o_ctrl_wr_debug_mem(o_ctrl_wr_debug_mem),
		.o_ctrl_read_debug_reg(o_ctrl_read_debug_reg),
		.o_tx_data(o_tx_data),
		.o_en_write(o_en_write), //habilitamos la escritura en memoria, sabiendo que el dato ya esta completo formando los 32 bits de la instruccion
		.o_en_read(o_en_read),		
		.o_enable_pipe(o_enable_pipe),
		.o_enable_mem(o_enable_mem),
		.o_debug_unit_reg(o_debug_unit_reg),				
		.o_inst_load(o_inst_load), //instruccion a cargar en memoria
		.o_address(o_address), //direccion donde se carga la instruccion
		.o_ack_debug(o_ack_debug), //avisa al test que ya puede enviar el comando
		.o_end_send_data(o_end_send_data), //avisa al test que ya se termino de enviar datos de memoria
        .o_data_ready(o_data_ready),		
		.o_en_read_cant_instr(o_en_read_cant_instr),
		.o_receive_full_inst(o_receive_full_inst),
		.o_send_inst_finish(o_send_inst_finish),
		.o_state(o_state),
		.o_data_receive(o_data_receive),
		.o_tx_start(o_tx_start)	
	);


    uart #(
        .CLK(50E6),
        .BAUD_RATE(115200),
        .NB_DATA(8)
    ) instancia_uart (
        .clock(clock),
        .reset(reset),
        .tx_start(aux_tx_start),
        .parity(1),
        .rx(o_tx_data),
        .tx_data(aux_tx_data),
        .rx_data(aux_rx_data),
        .tx(rx_data),
        .rx_done(aux_rx_done),
        .tx_done(aux_tx_done)
    );
    
endmodule

/*
 //ENVIO EL PRIMER BYTE DE INSTRUCCION-1
            aux_tx_start = 0;
            data_uart_d = 0;
            #2
            aux_tx_start = 1;
            data_uart_d = 8'b00000001;
            #2
            aux_tx_start = 0;
            data_uart_d = 0;
            //ENVIO EL SEGUNDO BYTE DE INSTRUCCION-1
            #2
            aux_tx_start = 1;
            data_uart_d = 8'b00000010;
            #2
            aux_tx_start = 0;
            data_uart_d = 0;
            //ENVIO EL TERCER BYTE DE INSTRUCCION-1
            #2
            aux_tx_start = 1;
            data_uart_d = 8'b00000100;
            #2
            aux_tx_start = 0;
            data_uart_d = 0;
            //ENVIO EL CUARTO BYTE DE INSTRUCCION-1
            #2
            aux_tx_start = 1;
            data_uart_d = 8'b00001000;
            #2
            aux_tx_start = 0;
            data_uart_d = 0;
            #2
            //ENVIO EL PRIMER BYTE DE INSTRUCCION-2
            #2
            aux_tx_start = 1;
            data_uart_d = 8'b00000001;
            #2
            aux_tx_start = 0;
            data_uart_d = 0;
            //ENVIO EL SEGUNDO BYTE DE INSTRUCCION-2
            #2
            aux_tx_start = 1;
            data_uart_d = 8'b00000010;
            #2
            aux_tx_start = 0;
            data_uart_d = 0;
            //ENVIO EL TERCER BYTE DE INSTRUCCION-2
            #2
            aux_tx_start = 1;
            data_uart_d = 8'b00000100;
            #2
            aux_tx_start = 0;
            data_uart_d = 0;
            //ENVIO EL CUARTO BYTE DE INSTRUCCION-2
            #2
            aux_tx_start = 1;
            data_uart_d = 8'b00001000;
            #2
            aux_tx_start = 0;
            data_uart_d = 0;
            //ENVIO EL EL MODO DE OPERACION ENTRE STEP TO STEP (8'b00000100) O CONTINUO(b00010000)
            #2
            aux_tx_start = 1;
            data_uart_d = 8'b00000100;
            #6 //ESPERA 6 CICLOS SI NO SE LLEGA A LEER TODO TRANCA
            aux_tx_start = 0;
            data_uart_d = 0;
*/