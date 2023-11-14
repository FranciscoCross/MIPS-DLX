module select_mode#(
        parameter NB_MEM_ADDR   = 5,
        parameter NB_DATA       = 32
    )(
        input wire i_debug_unit_flag,
        input wire i_memory_data_read_enable,
        input wire [NB_MEM_ADDR-1:0] i_memory_data_read_addr,
        input wire i_mem_read,
        input wire i_mem_write,
        input wire [NB_MEM_ADDR-1:0] i_alu_result,
        output reg [NB_MEM_ADDR-1:0] o_addr,
        output reg o_mem_read,
        output reg o_mem_write
    );

//  Este modulo sirve para elegir entre la debug unit para leer o el funcionamiento normal de la pipeline

    always @(*) begin
        if (i_debug_unit_flag) begin
            o_mem_read    = i_memory_data_read_enable;
            o_mem_write   = 1'b0;
            o_addr        = i_memory_data_read_addr;
        end else begin
            o_mem_read    = i_mem_read;
            o_mem_write   = i_mem_write;
            o_addr        = i_alu_result;
        end
    end
endmodule
