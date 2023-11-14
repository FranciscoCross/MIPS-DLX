`timescale 1ns / 1ps

module tb_mem_data;

  // Parameters
  localparam  MEMORY_WIDTH = 8;
  localparam  MEMORY_DEPTH = 128;
  localparam  NB_ADDR = 7;
  localparam  NB_DATA = 32;
  localparam  RAM_PERFORMANCE = "LOW_LATENCY";
  localparam  INIT_FILE = "";

  // Ports
  reg i_clock = 0;
  reg i_mem_write_flag = 0;
  reg i_mem_read_flag = 0;
  reg i_word_enable = 0;
  reg i_halfword_enable = 0;
  reg i_byte_enable = 0;
  reg [NB_ADDR-1:0] i_read_addr;
  reg [NB_DATA-1:0] i_write_data;
  wire [NB_DATA-1:0] o_read_data;

  mem_data 
  #(
    .MEMORY_WIDTH(MEMORY_WIDTH ),
    .MEMORY_DEPTH(MEMORY_DEPTH ),
    .NB_ADDR(NB_ADDR ),
    .NB_DATA(NB_DATA ),
    .RAM_PERFORMANCE(RAM_PERFORMANCE ),
    .INIT_FILE (
        INIT_FILE )
  )
  mem_data_1 (
    .i_clock (i_clock ),
    .i_mem_write_flag (i_mem_write_flag ),
    .i_mem_read_flag (i_mem_read_flag ),
    .i_word_enable (i_word_enable ),
    .i_halfword_enable (i_halfword_enable ),
    .i_byte_enable (i_byte_enable ),
    .i_read_addr (i_read_addr ),
    .i_write_data (i_write_data ),
    .o_read_data  ( o_read_data)
  );

  initial begin
    begin
      i_mem_write_flag  = 1'b1;
      i_mem_read_flag   = 1'b0;
      
      i_word_enable         = 1'b1;
      i_halfword_enable     = 1'b0;
      i_byte_enable         = 1'b0;
      i_read_addr         = 7'd0;
      i_write_data      = 32'hffffffff;
      
      #20
      
      i_word_enable         = 1'b0;
      i_halfword_enable     = 1'b0;
      i_byte_enable         = 1'b1;
      i_read_addr         = 7'd0;
      i_write_data      = 32'h0;
      
      #20
      
      i_word_enable         = 1'b0;
      i_halfword_enable     = 1'b1;
      i_byte_enable         = 1'b0;
      i_read_addr         = 7'd10;
      i_write_data      = 32'hffffffff;
      
      #20
      
      i_mem_write_flag  = 1'b0;
      i_mem_read_flag   = 1'b1;
      
      i_word_enable         = 1'b0;
      i_halfword_enable     = 1'b1;
      i_byte_enable         = 1'b0;
      i_read_addr         = 7'd0;
      
      #20
      
      i_word_enable         = 1'b1;
      i_halfword_enable     = 1'b0;
      i_byte_enable         = 1'b0;
      i_read_addr         = 7'd0;
      
      #20
      
      i_word_enable         = 1'b0;
      i_halfword_enable     = 1'b0;
      i_byte_enable         = 1'b1;
      i_read_addr         = 7'd10;
      
      #20
      
      i_word_enable         = 1'b1;
      i_halfword_enable     = 1'b0;
      i_byte_enable         = 1'b0;
      i_read_addr         = 7'd10;
      
      $finish;
    end
  end

  always
    #5  i_clock = ! i_clock ;

endmodule
