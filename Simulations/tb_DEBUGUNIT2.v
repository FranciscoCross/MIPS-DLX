`timescale 1ns / 1ps
`include "parameters.vh"

module tb_DEBUGUNIT2;
    localparam NB_BITES = 8;
    localparam NB_STATE  = 14;
    localparam NB_DATA  = 32;
    localparam NB_REG  = 5;
    
    reg clock = 0;
    reg reset = 0;
    reg halt = 0;
    reg [`ADDRWIDTH-1:0] program_counter = 3;
    wire[`ADDRWIDTH-1:0] im_addr, im_addr_aux;
    wire [32-1:0] dm_data;
 
    wire [32-1:0] bk_data;
    wire [32-1:0] data_instr;
    //Outputs

    wire [NB_REG-1:0]  br_addr; //32 reg
    wire [7-1:0] dm_addr; //128 elementos en memoria
    wire br_read;
    wire im_write_enable;
    wire o_enable_pipe;
    wire [NB_DATA-1:0] im_data_write;
    wire [NB_STATE-1:0] o_state;

    /*Auxiliary UART Unit*/
    reg aux_tx_start;
    wire du_select_addr;
    reg [7 : 0]  aux_tx_data = 0;
    wire [7 : 0] tx_data_to_send;
    wire [7 : 0] aux_rx_data_pipe, aux_rx_data_pc;
    wire aux_rx_done_pc, aux_rx_done_pipe;
    wire aux_tx_done_pc, aux_tx_done_pipe;



    always #10 clock = ~clock; 
       initial begin
            #0
            reset = 0;
            aux_tx_start = 0;    
            #20
            reset = 1;   
            #20
            reset = 0;
            #20
            $display("Envio comando para escribir programa");
            aux_tx_data = 8'd1;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
//
//#########################################################################
//#########################################################################
//#########################################################################
//#########################################################################
//
            #20
            $display("Envio 1 byte Instruccion 1");
            aux_tx_data = 8'd1;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 2 byte Instruccion 1");
            aux_tx_data = 8'd2;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 3 byte Instruccion 1");
            aux_tx_data = 8'd3;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 4 byte Instruccion 1");
            aux_tx_data = 8'd4;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
//
//#########################################################################
//#########################################################################
//#########################################################################
//#########################################################################
//

            #20
            $display("Envio 1 byte Instruccion 2");
            aux_tx_data = 8'd2;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 2 byte Instruccion 2");
            aux_tx_data = 8'd3;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 3 byte Instruccion 2");
            aux_tx_data = 8'd4;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 4 byte Instruccion 2");
            aux_tx_data = 8'd5;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
//
//#########################################################################
//#########################################################################
//#########################################################################
//#########################################################################
//

            #20
            $display("Envio 1 byte Instruccion 3");
            aux_tx_data = 8'd3;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 2 byte Instruccion 3");
            aux_tx_data = 8'd4;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 3 byte Instruccion 3");
            aux_tx_data = 8'd5;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 4 byte Instruccion 3");
            aux_tx_data = 8'd6;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
//
//#########################################################################
//#########################################################################
//#########################################################################
//#########################################################################
//

            #20
            $display("Envio 1 byte Instruccion 4");
            aux_tx_data = 8'd4;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 2 byte Instruccion 4");
            aux_tx_data = 8'd5;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 3 byte Instruccion 4");
            aux_tx_data = 8'd6;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 4 byte Instruccion 4");
            aux_tx_data = 8'd7;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
//
//#########################################################################
//#########################################################################
//#########################################################################
//#########################################################################
//

            #20
            $display("Envio 1 byte Instruccion 5");
            aux_tx_data = 8'd2;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 2 byte Instruccion 5");
            aux_tx_data = 8'd2;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 3 byte Instruccion 5");
            aux_tx_data = 8'd2;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 4 byte Instruccion 5");
            aux_tx_data = 8'd2;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
//
//#########################################################################
//#########################################################################
//#########################################################################
//#########################################################################
//

            #20
            $display("Envio 1 byte Instruccion 6");
            aux_tx_data = 8'd3;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 2 byte Instruccion 6");
            aux_tx_data = 8'd3;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 3 byte Instruccion 6");
            aux_tx_data = 8'd3;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 4 byte Instruccion 6");
            aux_tx_data = 8'd3;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
//
//#########################################################################
//#########################################################################
//#########################################################################
//#########################################################################
//

            #20
            $display("Envio 1 byte Instruccion 7");
            aux_tx_data = 8'd1;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 2 byte Instruccion 7");
            aux_tx_data = 8'd1;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 3 byte Instruccion 7");
            aux_tx_data = 8'd1;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 4 byte Instruccion 7");
            aux_tx_data = 8'd1;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
//
//#########################################################################
//#########################################################################
//#########################################################################
//#########################################################################
//

            #20
            $display("Envio 1 byte Instruccion 8");
            aux_tx_data = 8'd1;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 2 byte Instruccion 8");
            aux_tx_data = 8'd1;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 3 byte Instruccion 8");
            aux_tx_data = 8'd1;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 4 byte Instruccion 8");
            aux_tx_data = 8'd1;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
//
//#########################################################################
//#########################################################################
//#########################################################################
//#########################################################################
//

            #20
            $display("Envio 1 byte Instruccion 9");
            aux_tx_data = 8'd1;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 2 byte Instruccion 9");
            aux_tx_data = 8'd1;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 3 byte Instruccion 9");
            aux_tx_data = 8'd1;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 4 byte Instruccion 9");
            aux_tx_data = 8'd1;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
//
//#########################################################################
//#########################################################################
//#########################################################################
//#########################################################################
//

            #20
            $display("Envio 1 byte Instruccion 10");
            aux_tx_data = 8'd1;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 2 byte Instruccion 10");
            aux_tx_data = 8'd1;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 3 byte Instruccion 10");
            aux_tx_data = 8'd1;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 4 byte Instruccion 10");
            aux_tx_data = 8'd1;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end


            #20
            $display("Envio 1 byte Instruccion 11");
            aux_tx_data = 8'd1;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 2 byte Instruccion 11");
            aux_tx_data = 8'd1;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 3 byte Instruccion 11");
            aux_tx_data = 8'd1;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 4 byte Instruccion 11");
            aux_tx_data = 8'd1;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
//
//#########################################################################
//#########################################################################
//#########################################################################
//#########################################################################
//

            #20
            $display("Envio 1 byte Instruccion 12");
            aux_tx_data = 8'd1;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 2 byte Instruccion 12");
            aux_tx_data = 8'd1;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 3 byte Instruccion 12");
            aux_tx_data = 8'd1;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #20
            $display("Envio 4 byte Instruccion 12");
            aux_tx_data = 8'd1;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end


//
//#########################################################################
//#########################################################################
//#########################################################################
//#########################################################################
//   8'd6       
            #100
            $display("Envio comando STEP-BY-STEP ");
            aux_tx_data = 8'd3;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
            #1000
            halt = 0;
            #1000
            // $display("Envio comando SEND_PC ");
            // aux_tx_data = 8'd6;     
            // #20
            // aux_tx_start = 1;
            // #20
            // aux_tx_start = 0;
            
            // while (!aux_tx_done_pc) begin
            //      #1; // Wait 1 time units before checking again
            // end
            #100000
            $display("Envio comando STEP ");
            aux_tx_data = 8'd7;     
            #20
            aux_tx_start = 1;
            #20
            aux_tx_start = 0;
            
            while (!aux_tx_done_pc) begin
                 #1; // Wait 1 time units before checking again
            end
               while (o_state != 256) begin
               #1; // Wait 1 time units before checking again
               end
               while (o_state != 16) begin
               #1; // Wait 1 time units before checking again
               end
          $finish;
 
        end
	
    debug_unit2 debug_unit2
    (
        .i_clock(clock),
        .i_reset(reset),
        .i_halt(halt),          
        .i_rx_done(aux_rx_done_pipe),      
        .i_tx_done(aux_tx_done_pipe),      
        .i_rx_data(aux_rx_data_pipe),     
        .i_pc_value(program_counter),     
        .i_dm_data(dm_data),      
        .i_br_data(bk_data),      
        .o_im_write_enable(im_write_enable), 
        .o_im_data_write(im_data_write),
        .o_im_addr(im_addr),      
        .o_tx_data(tx_data_to_send),      
        .o_tx_start(tx_start_debug_unit),     
        .o_br_addr(br_addr),      
        .o_br_read(br_read),  
        .o_dm_addr(dm_addr),      
        .o_dm_enable(dm_enable), 
        .o_dm_read_enable(dm_read_enable), 
        .o_state(o_state),
        .o_enable_pipe(o_enable_pipe),
        .o_debug_unit_load(du_select_addr)
    );

    UART2 uart_pipeline
    (
        .i_clock(clock),
        .i_reset(reset),
        .i_rx(aux_tx_rx),                   //wire para rx bit a bit
        .i_tx_data(tx_data_to_send),        //data to transfer
        .i_tx_start(tx_start_debug_unit),   //start transfer
        .o_rx_data(aux_rx_data_pipe),       //data complete recive
        .o_rx_done_tick(aux_rx_done_pipe),  //rx done
        .o_tx(aux_rx_tx),                   //wire para tx bit a bit
        .o_tx_done_tick(aux_tx_done_pipe)   //tx done
    );

    UART2 uart_pc
    (
        .i_clock(clock),
        .i_reset(reset),
        .i_rx(aux_rx_tx),                   //wire para rx bit a bit
        .i_tx_data(aux_tx_data),            //data to transfer
        .i_tx_start(aux_tx_start),          //start transfer
        .o_rx_data(aux_rx_data_pc),         //data complete recive
        .o_rx_done_tick(aux_rx_done_pc),    //rx done
        .o_tx(aux_tx_rx),                   //wire para tx bit a bit
        .o_tx_done_tick(aux_tx_done_pc)     //tx done
    );

    bank_register bank_register
    ( 
        .i_clock(clock),
        .i_reset(reset),
        .i_rw(br_read), 
        .i_addr_ra(br_addr[4:0]),
        .o_data_ra(bk_data)		
    );

    dmem memory_data
    (
        .i_clock(clock),
        .i_mem_enable(dm_enable),
        .i_addr(dm_addr),		
        .i_read(dm_read_enable),
        .o_data(dm_data)
    );

    imem instancia_imem(
        .i_clock(clock),
        .i_enable(i_enable),
        .i_reset(i_reset),
        .i_en_write(im_write_enable),
        .i_en_read(i_Mem_REn),
        .i_addr(im_addr_aux),
        .i_data(im_data_write),
        .o_data(data_instr)
    );

    mux2#(.NB_DATA(`ADDRWIDTH)) mux_address_mem
    (
        .i_A({`ADDRWIDTH{1'b0}}), //0
        .i_B(im_addr),    //1
        .i_SEL(du_select_addr), //wire_debug_unit_reg despues poner este output en debug unit, por el momento siempre elije a address de debug unit
        .o_OUT(im_addr_aux)
    );
endmodule

