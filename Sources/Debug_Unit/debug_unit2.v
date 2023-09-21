`timescale 1ns / 1ps
`include "parameters.vh"

module debug_unit2#(
    parameter NB_STATE    = 10,
    parameter N_BITS      = 8,
    parameter NB_SIZE     = 16, // 2B x 8 b, el tamaño de los datos a recibir en bits
    parameter N_SIZE      = 2,  // 2B de frame para obtener el total de los datos (size)
    parameter NB_DATA     = 32,
    parameter NB_DATA_RB  = 5,
    parameter NB_BYTE_CTR = 2,
    parameter NB_DATA_DM  = 5, 
    parameter IM_DEPTH    = 256,
    parameter NB_PC_CTR   = 2
)    
(
    input                   i_clock,
    input                   i_reset,
    input                   i_halt,          // proveniente del DATAPATH
    input                   i_rx_done,      // meaning: RX tiene un byte listo para ser leido - UART
    input                   i_tx_done,      // meaning: TX ya envio el byte - UART
    input  [N_BITS-1:0]    	i_rx_data,      // from RX - UART
	
    input  [`ADDRWIDTH-1:0] i_pc_value,     // *  data read from PC 
    input  [NB_DATA-1:0]   	i_dm_data,      // *  data read from DATA MEMORY
    input  [NB_DATA-1:0]    i_br_data,      // *  data read from BANK REGISTER
    
	output                  o_im_write_enable, //*
	output [NB_DATA-1:0]    o_im_data_write,// * data to write in INSTRUCTION MEMORY
    output [N_BITS-1:0]    	o_im_addr,      // * address to write INSTRUCTION MEMORY
    output [N_BITS-1:0]    	o_tx_data,      // to TX - UART
    output                  o_tx_start,     // to TX - UART
	output [NB_DATA_RB-1:0] o_br_addr,      // * address to read BANK REGISTER
    output                  o_br_read, // * 
    output [`ADDRWIDTH-1:0] o_dm_addr,      // * address to read DATA MEMORY
    output                  o_dm_enable, // *
    output                  o_dm_read_enable, // *
    output [NB_STATE-1:0]   o_state,
    output                  o_enable_pipe,
    output                  o_debug_unit_load 
);

// States
localparam [NB_STATE-1:0] IDLE         = 10'b0000000001;    //1
localparam [NB_STATE-1:0] WRITE_IM     = 10'b0000000010;    //2    
localparam [NB_STATE-1:0] READY        = 10'b0000000100;    //4
localparam [NB_STATE-1:0] START        = 10'b0000001000;    //8
localparam [NB_STATE-1:0] STEP_BY_STEP = 10'b0000010000;    //16
localparam [NB_STATE-1:0] READ_BR      = 10'b0000100000;    //32
localparam [NB_STATE-1:0] SEND_BR      = 10'b0001000000;    //64
localparam [NB_STATE-1:0] READ_MEM     = 10'b0010000000;    //128
localparam [NB_STATE-1:0] SEND_MEM     = 10'b0100000000;    //256
localparam [NB_STATE-1:0] SEND_PC      = 10'b1000000000;    //512

// External commands
localparam [N_BITS-1:0] CMD_WRITE_IM       = 8'd1; // Escribir programa
localparam [N_BITS-1:0] CMD_START          = 8'd2; // Ejecucion continua
localparam [N_BITS-1:0] CMD_STEP_BY_STEP   = 8'd3; // Step-by-step
localparam [N_BITS-1:0] CMD_SEND_BR        = 8'd4; // Leer bank register
localparam [N_BITS-1:0] CMD_SEND_MEM       = 8'd5; // Leer data memory
localparam [N_BITS-1:0] CMD_SEND_PC        = 8'd6; // Leer PC
localparam [N_BITS-1:0] CMD_STEP           = 8'd7; // Send step
localparam [N_BITS-1:0] CMD_CONTINUE       = 8'd8; // Continue execution >>


// FSM logic
reg [NB_STATE-1:0]      state,              next_state,     prev_state,   next_prev_state;
reg debug_unit_load , next_debug_unit_load;
// INSTRUCTION MEMORY
reg [`ADDRWIDTH-1:0]    im_count,           next_im_count;          // Address a escribir
reg                     im_write_enable,    next_im_write_enable;   // Flag que habilita la escritura del IM
// DATA MEMORY
reg [`ADDRWIDTH-1:0]   count_dm_tx_done,   count_dm_tx_done_next;  // Address
reg [NB_BYTE_CTR-1:0]   count_dm_byte,      next_count_dm_byte;
reg                     dm_read_enable,     next_dm_read_enable;
reg                     dm_enable,          next_dm_enable;
// BANK REGISTER
reg [NB_DATA_RB-1:0]    count_br_tx_done,   next_count_br_tx_done; 
reg [NB_BYTE_CTR-1:0]   count_br_byte,      next_count_br_byte;     // cuenta hasta 4 bytes
reg                     br_read,     next_br_read;
// PC
reg [NB_PC_CTR-1:0]     count_pc,           next_count_pc;
// TX
reg [N_BITS-1:0]       send_data,          next_send_data;         // DM & BR -> TX
reg                     tx_start,           tx_start_next;
// PIPELINE REGISTERS
reg                    enable_pipe,     next_enable_pipe;
reg [NB_PC_CTR-1:0]     count_byte,           next_count_byte;
reg [N_BITS-1:0]        instru0,instru1,instru2,instru3;
reg [N_BITS-1:0]        next_instru0, next_instru1, next_instru2, next_instru3;
// Memory
always @(negedge i_clock) begin
    if(i_reset) begin
        state                   <= IDLE;
        prev_state              <= IDLE;

        // INSTRUCTION MEMORY 
        im_write_enable         <= 1'b0;
        im_count                <= 8'hff;

        // DATA MEMORY
        count_dm_tx_done        <= 5'b0;
        count_dm_byte           <= 2'b0;
        dm_enable               <= 1'b0;
        dm_read_enable          <= 1'b0;

        // REGISTERS BANK
        count_br_tx_done        <= 5'b0;
        count_br_byte           <= 2'b0;
        br_read          <= 1'b0;

        // PC
        count_pc                <= 2'b0;
        count_byte              <= 2'b0;
        
        // TX
        send_data               <= 8'b0;
        tx_start                <= 1'b0;

        enable_pipe         <= 1'b0;

        instru0             <= 8'b0;
        instru1             <= 8'b0;
        instru2             <= 8'b0;
        instru3             <= 8'b0;
        debug_unit_load     <= 1'b0;
	end
    else begin
        debug_unit_load         <= next_debug_unit_load;
        state                   <= next_state;
        prev_state              <= next_prev_state;
        // INSTRUCTION MEMORY
        im_write_enable         <= next_im_write_enable;
        im_count                <= next_im_count;
        // DATA MEMORY
        dm_enable               <= next_dm_enable;
        dm_read_enable          <= next_dm_read_enable;
        count_dm_byte           <= next_count_dm_byte;
        count_dm_tx_done        <= count_dm_tx_done_next;
        // REGISTERS BANK
        br_read                 <= next_br_read;
        count_br_byte           <= next_count_br_byte;
        count_br_tx_done        <= next_count_br_tx_done;
        tx_start                <= tx_start_next;
        // PC
        count_pc                <= next_count_pc;
        count_byte              <= next_count_byte;
        // TX
        send_data               <= next_send_data;
        enable_pipe             <= next_enable_pipe;

        instru0                 <= next_instru0;
        instru1                 <= next_instru1;
        instru2                 <= next_instru2;
        instru3                 <= next_instru3;

    end
end

// Next sate logic
always @(*) begin
    next_state              = state;
    next_dm_enable          = dm_enable;
    next_dm_read_enable     = dm_read_enable;
    next_count_dm_byte      = count_dm_byte;
    count_dm_tx_done_next   = count_dm_tx_done;
    next_count_br_byte      = count_br_byte;
    next_count_br_tx_done   = count_br_tx_done;
    next_count_pc           = count_pc;
    next_count_byte         = count_byte;
    next_im_write_enable    = im_write_enable;
    next_im_count           = im_count;
    next_br_read            = br_read;
    next_send_data          = send_data;
    next_enable_pipe        = enable_pipe;
    tx_start_next           = tx_start;
    next_prev_state         = prev_state;
    next_instru0            = instru0;
    next_instru1            = instru1;
    next_instru2            = instru2;
    next_instru3            = instru3;
    next_debug_unit_load    = debug_unit_load;

    case(state)
        IDLE: begin
            next_im_write_enable    = 1'b0;
            next_br_read            = 1'b0;
            next_dm_enable          = 1'b0;
            next_dm_read_enable     = 1'b0;
            next_enable_pipe        = 1'b0;
            next_send_data          = 8'b0;
			//CASE COMANDOS DE LA PC A DEBUG UNIT
            if(i_rx_done) begin
                case (i_rx_data)
                    CMD_WRITE_IM:  begin
                        next_state = WRITE_IM;
                        next_prev_state = IDLE;
                    end
                    CMD_SEND_BR:begin
                        next_br_read = 1'b1; // Read enable = register bank con lectura para debug unit
                        next_state = READ_BR;
                        next_prev_state = IDLE;
                    end
                    CMD_SEND_PC:begin
                        next_state = SEND_PC;
                        next_prev_state = IDLE;
                    end
                    CMD_SEND_MEM:begin
                        next_dm_read_enable     = 1'b1;
                        next_dm_enable          = 1'b1;

                        next_state = READ_MEM;
                        next_prev_state = IDLE;
                    end
                endcase
            end
        end
        READY: begin
            if(i_rx_done)begin
                case(i_rx_data)
                    CMD_STEP_BY_STEP:   next_state = STEP_BY_STEP;
                    CMD_START:          next_state = START;
                endcase
            end
        end
        START: begin
            next_dm_enable      = 1'b1;
            next_enable_pipe    = 1'b1;

            if(i_halt)begin
                next_state = IDLE;
            end
        end
        STEP_BY_STEP: begin
            count_dm_tx_done_next = 0;
            next_count_br_tx_done = 0;
            if(i_rx_done)begin
                next_enable_pipe = 1'b1;
                case (i_rx_data)
                    CMD_STEP: begin
                        next_state          = SEND_PC;
                        next_prev_state     = STEP_BY_STEP;
                        next_dm_enable      = 1'b1;
                        
                    end
                    CMD_CONTINUE: begin
                        next_state      = START;
                        next_prev_state = IDLE;
                    end    
                endcase
            end

            if(i_halt)begin
                next_state = IDLE;
                next_prev_state = IDLE;
            end
        end
        WRITE_IM: begin //Verificado
            if(im_count == 7'd11)begin
                next_state              = READY;
                next_im_write_enable    = 1'b0;
                next_debug_unit_load    = 1'b0;
                next_im_count           = 8'hff;
            end
            else begin
                case(count_byte)
                    2'd0:   next_instru0 = i_rx_data;
                    2'd1:   next_instru1 = i_rx_data;
                    2'd2:   next_instru2 = i_rx_data;
                    2'd3:   next_instru3 = i_rx_data;
                endcase
                if(i_rx_done)begin
                    if(count_byte == 2'd3)begin
                        next_im_write_enable    = 1'b1;
                        next_debug_unit_load    = 1'b1;
                        next_im_count           = im_count + 1;
                        next_count_byte         = 2'b0;
                    end
                    else begin
                        next_count_byte = count_byte + 1;
                        next_state = WRITE_IM;
                    end
                end
                else begin
                    next_im_write_enable    = 1'b0;
                    next_debug_unit_load    = 1'b0;     
                end
            end
        end
        SEND_PC: begin //Verificado
            tx_start_next       = 1'b1;
            next_dm_enable      = 1'b0;
            next_enable_pipe    = 1'b0;
            next_send_data = i_pc_value;
            if(i_tx_done)begin
                tx_start_next = 1'b0;
                    if(prev_state == STEP_BY_STEP)begin
                        next_state = SEND_BR;
                    end
                    else begin
                        next_state = IDLE;
                    end
                end
                else begin
                    next_state = SEND_PC;
                end
        end
        READ_BR: begin
            next_state = SEND_BR;
        end
        SEND_BR: begin
            next_br_read = 1'b1; // Read enable = register bank con lectura para debug unit
            tx_start_next       = 1'b1;
            //disable all except br
            next_dm_enable      = 1'b0;

            case(next_count_br_byte)
                2'd0:   next_send_data = i_br_data[31:24];
                2'd1:   next_send_data = i_br_data[23:16];
                2'd2:   next_send_data = i_br_data[15:8];
                2'd3:   next_send_data = i_br_data[7:0];
            endcase

            if(i_tx_done)begin
                next_count_br_byte = next_count_br_byte + 1;
                tx_start_next = 1'b0;

                if(count_br_byte == 2'd3)begin
                    next_count_br_tx_done   = count_br_tx_done + 1; // BR address
                    next_count_br_byte      = 2'd0;
                    next_state              = READ_BR;

                    if(count_br_tx_done == NB_DATA-1)begin
                        next_br_read    = 1'b0;
                        tx_start_next   = 1'b0;
                        next_state      = prev_state;
                        tx_start_next   = 1'b0; 
                        if(prev_state == STEP_BY_STEP) begin
                            next_dm_read_enable     = 1'b1;
                            next_dm_enable          = 1'b1;
                            next_state = READ_MEM;
                        end
                        else begin
                            next_state = IDLE;
                        end                   
                    end
                end
            end
        end
        READ_MEM:begin
            next_state = SEND_MEM;
        end
        SEND_MEM: begin
            tx_start_next           = 1'b1;
            
            case(next_count_dm_byte)
                2'd0:   next_send_data = i_dm_data[31:24];
                2'd1:   next_send_data = i_dm_data[23:16];
                2'd2:   next_send_data = i_dm_data[15:8];
                2'd3:   next_send_data = i_dm_data[7:0];
            endcase

            if(i_tx_done)begin
                next_count_dm_byte = next_count_dm_byte + 1;
                tx_start_next = 1'b0;
                
                if(count_dm_byte == 2'd3)begin
                    count_dm_tx_done_next = count_dm_tx_done + 1;
                    next_count_dm_byte = 2'd0;
                    next_state = READ_MEM;

                    if(count_dm_tx_done == NB_DATA-1)begin
                        next_dm_read_enable  = 1'b0;
                        next_dm_enable       = 1'b0;
                        tx_start_next        = 1'b0;
                        next_state      = prev_state;
                        // if(prev_state == STEP_BY_STEP) begin
                        //     next_state = SEND_BR;
                        // end
                        // else begin
                        //     next_state = IDLE;
                        // end
                    end
                end
            end
        end
    endcase
end

// INSTRUCTION MEMORY
assign o_im_write_enable    = im_write_enable;
assign o_im_data_write      = {instru3,instru2,instru1,instru0};
assign o_im_addr            = im_count;

// DATA MEMORY
assign o_dm_enable          = dm_enable;
assign o_dm_read_enable     = dm_read_enable;
assign o_dm_addr            = count_dm_tx_done; // Cada vez que haya un tx_done, se avanza +1 address

// REGISTER BANK
assign o_br_read            = br_read;
assign o_br_addr            = count_br_tx_done;

// TX
assign o_tx_data            = send_data;
assign o_tx_start           = tx_start;

// STATE
assign o_state              = state;

// PIPELINE REGISTERS
assign o_enable_pipe        = enable_pipe;

assign o_debug_unit_load    = debug_unit_load;

endmodule