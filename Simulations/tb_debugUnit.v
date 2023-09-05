`timescale 1ns / 1ps
`include "parameters.vh"

module tb_debugUnit;
    localparam NB_BITES = 8;
    localparam NB_STATE  = 15;
    localparam NB_DATA  = 32;
    localparam NB_REG  = 5;
    
    reg clock = 0;
    reg reset = 0;
    reg halt = 0;
    wire rx_data;
    reg [`ADDRWIDTH-1:0] program_counter = 3;
    wire[`ADDRWIDTH-1:0] wire_address_debug;
    reg reg_debug_unit = 0;
    reg bit_sucio = 1;
    wire [32-1:0] mem_debug_unit;
    reg [`ADDRWIDTH-1:0] cant_cycles_d = 4;
    reg tx_start_d = 0;
    reg data_ready_uart_d = 0;
    reg tx_done_d = 0;	
    reg [NB_BITES-1: 0] data_uart_d = 0;

 
    wire [32-1:0] register;
    wire [32-1:0] wire_instr;
    //Outputs

    wire [NB_REG-1:0]  o_addr_reg_debug_unit; //32 reg
    wire [7-1:0] o_addr_mem_debug_unit; //128 elementos en memoria
    wire o_ctrl_addr_debug_mem;
    wire o_ctrl_wr_debug_mem;
    wire o_ctrl_read_debug_reg;
    wire o_tx_data;
    wire o_en_write;
    wire o_en_read;		
    wire o_enable_pipe;
    wire o_enable_mem;
    wire wire_debug_unit_reg;		
    wire [NB_DATA-1:0] o_inst_load;
    wire [7-1:0] o_address_du;
    wire o_ack_debug;
    wire o_end_send_data;
//
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



    always #10 clock = ~clock; // # < timeunit > delay
       initial begin
            #0
            reset = 0;
            aux_tx_start = 0;    
            #20
            reset = 1;   
            #20
            reset = 0;
            #20
            $display("Envio numero de instrucciones");
            aux_tx_data = 8'b00000010;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done) begin
                 #1; // Wait 5 time units before checking again
            end
            #20       
            $display("Envio primer byte de instruccion 1");
            aux_tx_data = 8'b00000010;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20     
            $display("Envio segundo byte de instruccion 1");
            aux_tx_data = 8'b00000011;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20     
            $display("Envio tercer byte de instruccion 1");
            aux_tx_data = 8'b00000100;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20     
            $display("Envio cuarto byte de instruccion 1");
            aux_tx_data = 8'b00000101;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20

            $display("Envio primer byte de instruccion 2");
            aux_tx_data = 8'b00000110;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20      
            $display("Envio segundo byte de instruccion 2");
            aux_tx_data = 8'b00000111;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20      
            $display("Envio tercer byte de instruccion 2");
            aux_tx_data = 8'b00001000;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20     
            $display("Envio cuarto byte de instruccion 2");
            aux_tx_data = 8'b00001001;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20            
            
            $display("Envio modeOperate");
            aux_tx_data = 8'b00010000;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done) begin
                #1; // Wait 5 time units before checking again
            end
            #20
            $display("Envio un halt");
            #20
            halt = 1;
            #20
            halt = 0;
            #1000
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
		.i_reg_debug_unit(register), //viene del banco de registros
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
		.o_debug_unit_reg(wire_debug_unit_reg),				
		.o_inst_load(o_inst_load), //instruccion a cargar en memoria
		.o_address(o_address_du), //direccion donde se carga la instruccionz
		.o_state(o_state)
	);

	UART2 uart_pc
        (
        .i_clock(clock),
        .i_reset(reset),
        .i_rx(o_tx_data), //wire para rx bit a bit
        .i_tx(aux_tx_data), //data to transfer
        .i_tx_start(aux_tx_start), //start transfer
        .o_rx(aux_rx_data), //data complete recive
        .o_rx_done_tick(aux_rx_done), //rx done
        .o_tx(rx_data), //wire para tx bit a bit
        .o_tx_done_tick(aux_tx_done) //tx done
        );
    
bank_register bank_register

	( 
		.i_clock(clock),
		.i_reset(reset),
		.i_rw(o_ctrl_read_debug_reg), 
		.i_addr_ra(o_addr_reg_debug_unit[4:0]),
		.o_data_ra(register)		
	);

dmem memory_data
(
    .i_clk(clock),
    .i_mem_enable(1'b1),
    .i_addr(o_addr_mem_debug_unit),		
    .i_read(1'b1),
    .o_data(mem_debug_unit)
);

    imem instancia_imem(
        .i_clk(clock),
        .i_enable(i_enable),
        .i_reset(i_reset),
        .i_en_write(o_en_write),
        .i_en_read(i_Mem_REn),
        .i_addr(wire_address_debug),
        .i_data(o_inst_load),
        .o_data(wire_instr)
    );
     mux2#(.NB_DATA(`ADDRWIDTH)) mux_address_mem
	(
		.i_A({`ADDRWIDTH{1'b0}}), //0
		.i_B(o_address_du),    //1
		.i_SEL(wire_debug_unit_reg),
		.o_OUT(wire_address_debug)
	);
endmodule

