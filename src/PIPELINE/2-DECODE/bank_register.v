`timescale 1ns / 1ps

module bank_register#(
        parameter   NB_DATA     =   32,
        parameter   NB_ADDR     =   5,
        parameter   BANK_DEPTH  =   32 // 32 Registros diferentes
    )
    (
        input               i_clock,
        input               i_reset,
        input               i_reg_write,  // Señal de control RegWrite proveniente de WB
        input [NB_ADDR-1:0] i_read_reg_a,
        input [NB_ADDR-1:0] i_read_reg_b,
        input [NB_ADDR-1:0] i_write_reg,  // addr 
        input [NB_DATA-1:0] i_write_data, // Data

        input               i_enable,       // Debug Unit
        input               i_read_enable,  // Debug Unit
        input [NB_ADDR-1:0] i_read_addr, // Debug Unit
              
        output [NB_DATA-1:0] o_data_a,
        output [NB_DATA-1:0] o_data_b 
    );
    
    reg [NB_DATA-1:0] o_data_a_next;
    reg [NB_DATA-1:0] o_data_b_next;
    
    reg [NB_DATA-1:0] registers [BANK_DEPTH-1:0];

    generate
        integer reg_index;
        initial
            for (reg_index = 0; reg_index < BANK_DEPTH; reg_index = reg_index + 1)
                registers[reg_index] = {NB_DATA{1'b0}};
    endgenerate
    
    always@(posedge i_clock)begin
        if(i_reset)begin:reset
            o_data_a_next  <=  {NB_DATA{1'b0}};
            o_data_b_next  <=  {NB_DATA{1'b0}};
        end 
        else begin
            if(i_enable) begin // Funcionamiento normal
                
                // Escritura de regs
                if (i_reg_write) begin
                    registers[i_write_reg] = i_write_data;
                end

                // Lectura para evitar raw hazards en el 3er ciclo de clock
                if(i_read_reg_a == i_write_reg && i_reg_write) begin
                    o_data_a_next <= i_write_data;
                    o_data_b_next <= registers[i_read_reg_b];
                end
                else if (i_read_reg_b == i_write_reg && i_reg_write) begin
                    o_data_a_next <= registers[i_read_reg_a];
                    o_data_b_next <= i_write_data;
                end
                else begin
                    // Lectura normal
                    o_data_a_next <= registers[i_read_reg_a];
                    o_data_b_next <= registers[i_read_reg_b];
                end
            end
            else if(i_read_enable) begin     // Lectura del RA desde la Debug Unit
                o_data_a_next = registers[i_read_addr];
            end
        end
    end
    
    assign o_data_a = o_data_a_next;
    assign o_data_b = o_data_b_next;
    
endmodule
