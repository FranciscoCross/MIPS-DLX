`timescale 1ns / 1ps

module forwarding_unit #(
        parameter NB_REG    = 5,
        parameter NB_MUX    = 2
    )    
    (   
        input                      i_reset,
        input       [NB_REG-1 : 0] i_EX_MEM_rd,         // RD corresnpondiente a la etapa EXECUTE/MEMORY
        input       [NB_REG-1 : 0] i_MEM_WB_rd,         // RD corresnpondiente a la etapa MEMORY/WRITE-BACK
        input       [NB_REG-1 : 0] i_rt,                // data_b
        input       [NB_REG-1 : 0] i_rs,                // data_a
        input                      i_EX_mem_write,      // Si se quiere escribir en memoria, corresponde a STOREs
        input                      i_MEM_write_reg,     // Si se quiere escribir en un Registro, valor desde la etapa MEMORY
        input                      i_WB_write_reg,      // Si se quiere escribir en un Registro, valor desde la etapa WRITE-BACK
        output reg  [NB_MUX-1:0]   o_forwarding_a,      // Si se forwardea el valor de A
        output reg  [NB_MUX-1:0]   o_forwarding_b,      // Si se forwardea el valor de B
        output reg  [NB_MUX-1:0]   o_forwarding_mux     // Dato normal(10), Dato de WriteBack (01), Dato de Memoria (00)(Elije en el mux de EXECUTE)
    );
    always@(*) begin
        if(i_reset) begin
            o_forwarding_a      = 2'b0;
            o_forwarding_b      = 2'b0;
            o_forwarding_mux    = 2'b10;            // Dato normal
        end
        else begin
            // Si ninguna de las señales de escritura en registros está activa, nuevamente, se restablecen las salidas a valores predeterminados.
            if((i_MEM_write_reg == 0) && (i_WB_write_reg==0)) begin
                o_forwarding_a      = 2'b0;
                o_forwarding_b      = 2'b0;
                o_forwarding_mux    = 2'b10;        // Dato normal
            end
            
            //#############################################################
            //--------------------- OPERANDO A ----------------------------
            //#############################################################

            //Ahora se consideran casos de FORWARD para los operandos A y B:
            //Si el REG de destino en la etapa EXECUTE (i_EX_MEM_rd) coincide con el registro fuente de A (i_rs) 
            //y tambien
            //la señal de escritura en memoria (i_MEM_write_reg) está activa
            //SE establece:
            //      o_forwarding_a en   2'b01 (indicando que el dato proviene de MEM) 
            //      o_forwarding_mux en 2'b10 (dato normal).
            
            if((i_EX_MEM_rd == i_rs) && i_MEM_write_reg) begin
                o_forwarding_a      = 2'b01;        // El dato viene de MEM
                o_forwarding_mux    = 2'b10;        // Dato normal
            end
            // Si el registro de destino en la etapa MEMORY (i_MEM_WB_rd) coincide con el registro fuente de A (i_rs) 
            // y tambien 
            // la señal de escritura en registro en la etapa WRITE-BACK (i_WB_write_reg) está activa
            // SE establece:
            //      o_forwarding_a en     2'b10 (indicando que el dato proviene de WB) 
            //      o_forwarding_mux en   2'b10.
            else if ((i_MEM_WB_rd == i_rs) && i_WB_write_reg) begin
                o_forwarding_a      = 2'b10;        // El dato viene de WB
                o_forwarding_mux    = 2'b10;        // Dato normal
            end
            else begin
                o_forwarding_a      = 2'b0;         // No hay forwarding para A
                o_forwarding_mux    = 2'b10;        // Dato normal
            end

            //#############################################################
            //--------------------- OPERANDO B ----------------------------
            //#############################################################

            // Similarmente, se manejan casos de forwarding para el operando B considerando el registro fuente de B (i_rt)
            // y las señales de escritura en memoria y registros.
            if((i_EX_MEM_rd == i_rt) && i_MEM_write_reg) begin
                if(i_EX_mem_write) begin            // Hay Store
                    o_forwarding_b      = 2'b00;    // No forwardeo
                    o_forwarding_mux    = 2'b00;    // forwardea reg de EX_MEM para store
                end
                else begin
                    o_forwarding_b      = 2'b01;    // El dato viene de MEM
                    o_forwarding_mux    = 2'b10;    // Dato normal
                end
            end
            else if ((i_MEM_WB_rd == i_rt) && i_WB_write_reg) begin
                if(i_EX_mem_write) begin            // Hay store
                    o_forwarding_b      = 2'b00;    // No forwardeo
                    o_forwarding_mux    = 2'b01;
                end
                else begin
                    o_forwarding_b      = 2'b10;    // El dato viene de WB
                    o_forwarding_mux    = 2'b10;    // Dato normal
                end
            end
            else begin
                o_forwarding_b      = 2'b0;         // No hay forwarding para B
                o_forwarding_mux    = 2'b10;        // Dato normal
            end
        end
    end
    
endmodule