`timescale 1ns / 1ps
`include "parameters.vh"
module debug_unit#(
    parameter NB_STATE    = 10,
    parameter NB_DATA     = 8,
    parameter NB_ADDR     = 32,
    parameter NB_ADDR_RB  = 5,
    parameter NB_BYTE_CTR = 2,
    parameter NB_ADDR_DM  = 5, 
    parameter DM_DEPTH    = 32,
    parameter DM_WIDTH    = 32,
    parameter RB_DEPTH    = 32,
    parameter NB_PC_CTR   = 2
)    
(
    input                   i_clock,
    input                   i_reset,
    input                   i_halt,                     // proveniente del pipeline
    input                   i_rx_done,                  // meaning: RX tiene un byte listo para ser leido - UART
    input                   i_tx_done,                  // meaning: TX ya envio el byte - UART
    input  [NB_DATA-1:0]    i_rx_data,                  // from RX - UART
    input  [NB_ADDR-1:0]    i_pc_value,                 // data read from PC 
    input  [DM_WIDTH-1:0]   i_mem_data,                 // data read from DATA mem
    input  [NB_ADDR-1:0]    i_bank_reg_data,            // data read from BANK REGISTER
    
    output [NB_DATA-1:0]    o_instru_mem_data,          // data to write in INSTRUCTION mem
    output [NB_DATA-1:0]    o_instru_mem_addr,          // addr to write INSTRUCTION mem
    output [NB_ADDR_RB-1:0] o_rb_addr,                  // addr to read BANK REGISTER
    output [NB_ADDR_DM-1:0] o_mem_data_addr,            // addr to read DATA mem
    output [NB_DATA-1:0]    o_tx_data,                  // to TX - UART
    output                  o_tx_start,                 // to TX - UART
    output                  o_instru_mem_write_enable,  // 
    output                  o_instru_mem_read_enable,   //
    output                  o_instru_mem_enable,        // 
    output                  o_rb_read_enable,           //  
    output                  o_rb_enable,                // Usar solo cuando se active funcionamiento normal de pipeline
    output                  o_mem_data_enable,          // 
    output                  o_mem_data_read_enable,     // 
    output                  o_mem_data_debug_unit,      // 
    output                  o_unit_control_enable,      // 
    output                  o_pc_enable,                // 
    output [NB_STATE-1:0]   o_state,                    // 
    output                  o_pipeline_enable           // 
);

reg [NB_STATE-1:0]      state;
reg [NB_STATE-1:0]      next_state;
reg [NB_STATE-1:0]      prev_state;
reg [NB_STATE-1:0]      next_prev_state;
reg [NB_DATA-1:0]       im_count;
reg [NB_DATA-1:0]       next_instru_mem_count;          
reg [NB_ADDR_DM-1:0]    count_mem_data_tx_done;
reg [NB_ADDR_DM-1:0]    count_mem_data_tx_done_next;  
reg [NB_BYTE_CTR-1:0]   count_mem_byte;
reg [NB_BYTE_CTR-1:0]   next_count_mem_byte;
reg [NB_ADDR_RB-1:0]    count_bank_reg_tx_done; 
reg [NB_ADDR_RB-1:0]    next_count_bank_reg_tx_done; 
reg [NB_BYTE_CTR-1:0]   count_bank_reg_byte;
reg [NB_BYTE_CTR-1:0]   next_count_bank_reg_byte;     
reg [NB_PC_CTR-1:0]     count_pc;
reg [NB_PC_CTR-1:0]     next_count_pc;
reg [NB_DATA-1:0]       send_data;
reg [NB_DATA-1:0]       next_send_data; 

reg     im_write_enable; 
reg     next_instru_mem_write_enable;   
reg     im_read_enable;
reg     next_instru_mem_read_enable;
reg     im_enable;
reg     next_instru_mem_enable;
reg     dm_read_enable;
reg     next_mem_data_read_enable;
reg     dm_enable; 
reg     next_mem_data_enable;
reg     dm_debug_unit;
reg     next_mem_data_debug_unit; 
reg     rb_read_enable;
reg     next_rb_read_enable;
reg     rb_enable;
reg     next_rb_enable;
reg     pc_enable;
reg     next_pc_enable; 
reg     unit_control_enable;
reg     next_unit_control_enable;
reg     tx_start;
reg     tx_start_next;
reg     pipeline_enable;
reg     next_pipeline_enable;


// mem
always @(negedge i_clock) begin
    if(i_reset) begin
        state                   <= `INITIAL;
        prev_state              <= `INITIAL;
        im_write_enable         <= 1'b0;
        im_read_enable          <= 1'b0;
        im_enable               <= 1'b0;
        im_count                <= 8'hff;
        count_mem_data_tx_done  <= 5'b0;
        count_mem_byte          <= 2'b0;
        dm_enable               <= 1'b0;
        dm_read_enable          <= 1'b0;
        dm_debug_unit           <= 1'b0;
        count_bank_reg_tx_done  <= 5'b0;
        count_bank_reg_byte     <= 2'b0;
        rb_enable               <= 1'b0;
        rb_read_enable          <= 1'b0;
        pc_enable               <= 1'b0;
        count_pc                <= 2'b0;
        unit_control_enable     <= 1'b0;
        send_data               <= 8'b0;
        tx_start                <= 1'b0;
        pipeline_enable         <= 1'b0;


    end
    else begin
        state                   <= next_state;
        prev_state              <= next_prev_state;
        im_write_enable         <= next_instru_mem_write_enable;
        im_read_enable          <= next_instru_mem_read_enable;
        im_enable               <= next_instru_mem_enable;
        im_count                <= next_instru_mem_count;
        dm_enable               <= next_mem_data_enable;
        dm_read_enable          <= next_mem_data_read_enable;
        count_mem_byte          <= next_count_mem_byte;
        count_mem_data_tx_done  <= count_mem_data_tx_done_next;
        dm_debug_unit           <= next_mem_data_debug_unit;
        rb_enable               <= next_rb_enable;
        rb_read_enable          <= next_rb_read_enable;
        count_bank_reg_byte     <= next_count_bank_reg_byte;
        count_bank_reg_tx_done  <= next_count_bank_reg_tx_done;
        tx_start                <= tx_start_next;
        pc_enable               <= next_pc_enable;
        count_pc                <= next_count_pc;
        unit_control_enable     <= next_unit_control_enable;
        send_data               <= next_send_data;
        pipeline_enable         <= next_pipeline_enable;

    end
end

// Next sate logic
always @(*) begin
    next_state                      = state;
    next_prev_state                 = prev_state;
    next_mem_data_enable            = dm_enable;
    next_mem_data_read_enable       = dm_read_enable;
    next_mem_data_debug_unit        = dm_debug_unit;
    next_count_mem_byte             = count_mem_byte;
    count_mem_data_tx_done_next     = count_mem_data_tx_done;
    next_count_bank_reg_byte        = count_bank_reg_byte;
    next_count_bank_reg_tx_done     = count_bank_reg_tx_done;
    next_count_pc                   = count_pc;
    next_pc_enable                  = pc_enable;
    next_instru_mem_enable          = im_enable;
    next_instru_mem_write_enable    = im_write_enable;
    next_instru_mem_read_enable     = im_read_enable;
    next_instru_mem_count           = im_count;
    next_rb_enable                  = rb_enable;
    next_rb_read_enable             = rb_read_enable;
    next_send_data                  = send_data;
    next_unit_control_enable        = unit_control_enable;
    next_pipeline_enable            = pipeline_enable;
    tx_start_next                   = tx_start;

    case(state)
        `INITIAL: begin
            next_instru_mem_enable          = 1'b0;
            next_instru_mem_write_enable    = 1'b0;
            next_instru_mem_read_enable     = 1'b0;
            next_rb_enable                  = 1'b0;
            next_rb_read_enable             = 1'b0;
            next_mem_data_enable            = 1'b0;
            next_mem_data_read_enable       = 1'b0;
            next_mem_data_debug_unit        = 1'b0;
            next_unit_control_enable        = 1'b0;
            next_pc_enable                  = 1'b0;
            next_pipeline_enable            = 1'b0;
            next_send_data                  = 8'b0;

            if(i_rx_done) begin
                case (i_rx_data)
                    `CMD_WRITE_IM:  begin
                        next_state          = `WRITE_IM;
                        next_prev_state     = `INITIAL;
                    end

                    `CMD_SEND_INFO:begin
                        next_state          = `SEND_PC;
                        next_prev_state     = `INITIAL;
                    end

                endcase
            end
        end
        `READY: begin

            if(i_rx_done)begin
                case(i_rx_data)
                    `CMD_STEP_BY_STEP:   next_state = `STEP_BY_STEP;
                    `CMD_CONTINUE:       next_state = `START;
                endcase
            end
        end
        `START: begin
            next_instru_mem_enable          = 1'b1;
            next_instru_mem_read_enable     = 1'b1;
            next_rb_enable                  = 1'b1;
            next_mem_data_enable            = 1'b1;
            next_unit_control_enable        = 1'b1;
            next_pc_enable                  = 1'b1;
            next_pipeline_enable            = 1'b1;

            if(i_halt)begin
                next_state = `SEND_PC;
            end
        end
        `STEP_BY_STEP: begin
            if(i_rx_done)begin
                next_pipeline_enable = 1'b1;
                case (i_rx_data)
                    `CMD_STEP: begin
                        next_state                  = `SEND_PC;
                        next_prev_state             = `STEP_BY_STEP;
                        next_instru_mem_enable      = 1'b1;
                        next_instru_mem_read_enable = 1'b1;
                        next_rb_enable              = 1'b1;
                        next_mem_data_enable        = 1'b1;
                        next_unit_control_enable    = 1'b1;
                        next_pc_enable              = 1'b1;
                    end
                    `CMD_CONTINUE: begin
                        next_state      = `START;
                        next_prev_state = `INITIAL;
                    end    
                endcase
            end

            if(i_halt)begin
                next_state      = `SEND_PC;
                next_prev_state = `INITIAL;
            end
        end
        `WRITE_IM: begin
            if(im_count == 8'd254)begin
                next_state                      = `READY;
                next_instru_mem_enable          = 1'b0;
                next_instru_mem_read_enable     = 1'b0;
                next_instru_mem_write_enable    = 1'b0;
                next_instru_mem_count           = 8'hff;
            end
            else begin
                if(i_rx_done)begin
                    next_instru_mem_enable          = 1'b1;
                    next_instru_mem_write_enable    = 1'b1;
                    next_instru_mem_read_enable     = 1'b0;
                    next_instru_mem_count           = im_count + 1;
                    next_state                      = `WRITE_IM;
                end
                else begin
                    next_instru_mem_enable          = 1'b0;
                    next_instru_mem_write_enable    = 1'b0;
                    next_instru_mem_read_enable     = 1'b0;
                end
            end
        end
        `SEND_PC: begin
            tx_start_next               = 1'b1;
            next_instru_mem_enable      = 1'b0;
            next_instru_mem_read_enable = 1'b0;
            next_rb_enable              = 1'b0;
            next_mem_data_enable        = 1'b0;
            next_unit_control_enable    = 1'b0;
            next_pc_enable              = 1'b0;
            next_pipeline_enable        = 1'b0;
            case(count_pc)
                2'd0:   next_send_data = i_pc_value[31:24];
                2'd1:   next_send_data = i_pc_value[23:16];
                2'd2:   next_send_data = i_pc_value[15:8];
                2'd3:   next_send_data = i_pc_value[7:0];
            endcase
            if(i_tx_done)begin
                tx_start_next = 1'b0;
                if(count_pc == 2'd3)begin
                    next_pipeline_enable    = 1'b0; // por que aca?
                    tx_start_next           = 1'b0;
                    next_count_pc           = 2'b0;
                    next_state              = `SEND_MEM;
                end
                else begin
                    next_count_pc   = count_pc + 1;
                    next_state      = `SEND_PC;
                end
            end
        end
        `READ_BR: begin
            next_state = `SEND_BR;
        end
        `SEND_BR: begin
            next_rb_read_enable         = 1'b1; // Read en = register bank con lectura para debug unit
            next_rb_enable              = 1'b0; // en = register bank con lectura en funcionamiento normal
            tx_start_next               = 1'b1;
            next_pc_enable              = 1'b0;
            next_unit_control_enable    = 1'b0;
            next_mem_data_enable        = 1'b0;

            case(next_count_bank_reg_byte)
                2'd0:   next_send_data = i_bank_reg_data[31:24];
                2'd1:   next_send_data = i_bank_reg_data[23:16];
                2'd2:   next_send_data = i_bank_reg_data[15:8];
                2'd3:   next_send_data = i_bank_reg_data[7:0];
            endcase

            if(i_tx_done)begin
                next_count_bank_reg_byte = next_count_bank_reg_byte + 1;
                tx_start_next = 1'b0;

                if(count_bank_reg_byte == 2'd3)begin
                    next_count_bank_reg_tx_done     = count_bank_reg_tx_done + 1; // BR addr
                    next_count_bank_reg_byte        = 2'd0;
                    next_state                      = `READ_BR;

                    if(count_bank_reg_tx_done == RB_DEPTH-1)begin
                        next_rb_read_enable  = 1'b0;
                        tx_start_next        = 1'b0;
                        if(prev_state == `STEP_BY_STEP) begin
                            next_state = prev_state;
                        end
                        else begin
                            next_state = `INITIAL;
                        end
                        tx_start_next        = 1'b0;                    
                    end
                end
            end
        end
        `READ_MEM:begin
            next_state = `SEND_MEM;
        end
        `SEND_MEM: begin
            next_mem_data_read_enable    = 1'b1;
            next_mem_data_enable         = 1'b1;
            next_mem_data_debug_unit     = 1'b1; // select DU as addr and read en source
            tx_start_next                = 1'b1;
            next_instru_mem_enable       = 1'b0;
            next_instru_mem_read_enable  = 1'b0;
            next_rb_enable               = 1'b0;
            next_unit_control_enable     = 1'b0;
            next_pc_enable               = 1'b0;

            case(next_count_mem_byte)
                2'd0:   next_send_data = i_mem_data[31:24];
                2'd1:   next_send_data = i_mem_data[23:16];
                2'd2:   next_send_data = i_mem_data[15:8];
                2'd3:   next_send_data = i_mem_data[7:0];
            endcase

            if(i_tx_done)begin
                next_count_mem_byte = next_count_mem_byte + 1;
                tx_start_next = 1'b0;
                
                if(count_mem_byte == 2'd3)begin
                    count_mem_data_tx_done_next     = count_mem_data_tx_done + 1;
                    next_count_mem_byte             = 2'd0;
                    next_state                      = `READ_MEM;

                    if(count_mem_data_tx_done == DM_DEPTH-1)begin
                        next_mem_data_read_enable   = 1'b0;
                        next_mem_data_enable        = 1'b0;
                        next_mem_data_debug_unit    = 1'b0;
                        tx_start_next               = 1'b0;
                        next_state                  = `SEND_BR;
                    end
                end
            end
        end
    endcase
end

assign o_instru_mem_enable              = im_enable;
assign o_instru_mem_write_enable        = im_write_enable;
assign o_instru_mem_read_enable         = im_read_enable;
assign o_instru_mem_data                = i_rx_data;
assign o_instru_mem_addr                = im_count;
assign o_mem_data_enable                = dm_enable;
assign o_mem_data_read_enable           = dm_read_enable;
assign o_mem_data_debug_unit            = dm_debug_unit;
assign o_mem_data_addr                  = count_mem_data_tx_done; 
assign o_rb_enable                      = rb_enable;
assign o_rb_read_enable                 = rb_read_enable;
assign o_rb_addr                        = count_bank_reg_tx_done;
assign o_pc_enable                      = pc_enable;
assign o_unit_control_enable            = unit_control_enable;
assign o_tx_data                        = send_data;
assign o_tx_start                       = tx_start;
assign o_state                          = state;
assign o_pipeline_enable                = pipeline_enable;

endmodule