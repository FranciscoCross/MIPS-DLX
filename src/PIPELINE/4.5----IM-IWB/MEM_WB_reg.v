`timescale 1ns / 1ps

module MEM_WB_reg#(
        parameter NB_DATA = 32,
        parameter NB_REG  = 5,
        parameter NB_PC   = 32
    )
    (   
        input                   i_clock,
        input                   i_reset,
        input                   i_pipeline_enable,      //  DEBUG UNIT

        input                   i_reg_write,            // Si se necesita escribir en un registro
        input                   i_mem_to_reg,           // Si es de Memoria a Registro
        input [NB_DATA-1:0]     i_mem_data,             // Valor que viene de la Memoria
        input [NB_DATA-1:0]     i_alu_result,           // Resultado de la ALU
        input [NB_REG-1:0]      i_selected_reg,         // Valor de la addr del registro donde escribir
        input                   i_last_register_ctrl,   // Si es necesario el ULTIMO REG
        input [NB_PC-1:0]       i_pc,                   // Valor de PC
        input                   i_halt,                 // HALT

        // Como es un LATCH esto corresponde a hacer un delay de las entradas por ende no hace falta comentarios abajo :V
        output                  o_reg_write,
        output                  o_mem_to_reg,           
        output [NB_DATA-1:0]    o_mem_data,             
        output [NB_DATA-1:0]    o_alu_result,           
        output [NB_REG-1:0]     o_selected_reg,
        output                  o_last_register_ctrl,
        output [NB_PC-1:0]      o_pc,
        output                  o_halt                  
    );

    reg                 reg_write;
    reg                 mem_to_reg;                     
    reg [NB_DATA-1:0]   mem_data;                       
    reg [NB_DATA-1:0]   alu_result;                     
    reg [NB_REG-1:0]    selected_reg;
    reg                 last_register_ctrl;
    reg [NB_PC-1:0]     pc;
    reg                 halt;

    always@(negedge i_clock) begin
        if(i_reset) begin
            reg_write               <= 1'b0;
            mem_to_reg              <= 1'b0;
            mem_data                <= 32'b0;
            alu_result              <= 32'b0;
            selected_reg            <= 5'b0;
            last_register_ctrl      <= 1'b0;
            pc                      <= 32'b0;
            halt                    <= 1'b0;
        end
        else begin
            if(i_pipeline_enable) begin
                reg_write           <= i_reg_write;
                mem_to_reg          <= i_mem_to_reg;
                mem_data            <= i_mem_data;
                alu_result          <= i_alu_result;
                selected_reg        <= i_selected_reg;
                last_register_ctrl  <= i_last_register_ctrl;
                pc                  <= i_pc;
                halt                <= i_halt;
            end
            else begin
            reg_write               <= reg_write;
            mem_to_reg              <= mem_to_reg;
            mem_data                <= mem_data;
            alu_result              <= alu_result;
            selected_reg            <= selected_reg;
            last_register_ctrl      <= last_register_ctrl;
            pc                      <= pc;
            halt                    <= halt;
        end
        end
    end

    assign o_reg_write           = reg_write;
    assign o_mem_to_reg          = mem_to_reg;
    assign o_mem_data            = mem_data;
    assign o_alu_result          = alu_result;
    assign o_selected_reg        = selected_reg;
    assign o_last_register_ctrl  = last_register_ctrl;
    assign o_pc                  = pc;
    assign o_halt                = halt;

endmodule