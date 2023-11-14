`timescale 1ns / 1ps

module tb_bank_register();

    parameter   NB_DATA     =   32;
    parameter   NB_ADDR     =   5;
    parameter   BANK_DEPTH  =   32;
    
    reg                 clock;
    reg                 reset;
    reg                 reg_write;
    reg                 jr_jalr;
    reg [NB_ADDR-1:0]   read_reg_a;
    reg [NB_ADDR-1:0]   read_reg_b;
    reg [NB_ADDR-1:0]   write_reg;
    reg [NB_DATA-1:0]   write_data;
    
    wire [NB_DATA-1:0] data_a;
    wire [NB_DATA-1:0] data_b;
    
    
    initial begin
        
        //Inicializaci�n
        clock      = 1'b0;
        reset      = 1'b1;
        reg_write  = 1'b0;
        read_reg_a = 5'd0;
        read_reg_b = 5'd0;
        write_reg  = 5'd0;
        write_data = 32'd0;
        
        //Se escribe el valor 99 en el registro 10
        #40
        reset = 1'b0;
        reg_write = 1'b1;
        write_reg = 5'd10;
        write_data = 32'd99;
        
        //Se leen los registros 10 y 0
        #40
        reg_write = 1'b0;
        read_reg_a = 5'd10;
        read_reg_b = 5'd0;
        
        //Se escribe el valor 555 en el registro 1
        #40
        reg_write = 1'b1;
        write_reg = 5'd1;
        write_data = 32'd555;
        
        //Se escribe el valor 111 en el registro 31
        #40
        reg_write = 1'b1;
        write_reg = 5'd11111;
        write_data = 32'd111;
        
        //Se leen los registros 1 y 0
        #40
        reg_write = 1'b0;
        read_reg_a = 5'd1;
        read_reg_b = 5'd0;
        
        //Se lee registro 31
        #40
        jr_jalr = 1'b1;

        #40
        reset = 1'b1;
        
        #200
        
        $finish;
    
    end
    
    always #10 clock = ~clock;
    
    bank_register bank_register(.i_clock(clock),
                                  .i_reset(reset),
                                  .i_reg_write(reg_write),
                                  .i_jr_jalr(jr_jalr),
                                  .i_read_reg_a(read_reg_a),
                                  .i_read_reg_b(read_reg_b),
                                  .i_write_reg(write_reg),
                                  .i_write_data(write_data),
                                  .o_data_a(data_a),
                                  .o_data_b(data_b)
                                  );

endmodule