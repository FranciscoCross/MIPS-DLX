`timescale 1ns / 1ps

module tb_PIPELINE;

  // Inputs
  reg clock;
  reg i_reset;
  reg [31:0] i_inst_load;
  reg [31:0] i_addr_inst_load;
  reg i_en_write;
  reg i_en_read;
  reg i_enable_mem;
  reg i_enable_pipe;
  reg i_debug_unit;
  reg [4:0] i_addr_debug_unit;
  reg [31:0] i_addr_mem_debug_unit;
  reg i_ctrl_read_debug_reg;
  reg i_ctrl_wr_debug_mem;
  reg i_ctrl_addr_debug_mem;
  // Declaración del arreglo de instrucciones
  reg [31:0] instrucciones [0:10];

  // Outputs
  wire o_bit_sucio;
  wire [31:0] o_data_send_pc;
  wire [31:0] o_data_reg_debug_unit;
  wire [31:0] o_data_mem_debug_unit;
  wire [7:0] o_count_cycles;
  wire o_halt;
  integer i;

  // Instantiate the pipeline module
  pipeline pipeline (
    .clock(clock),
    .i_reset(i_reset),
    .i_inst_load(i_inst_load),
    .i_addr_inst_load(i_addr_inst_load),
    .i_en_write(i_en_write),
    .i_en_read(i_en_read),
    .i_enable_mem(i_enable_mem),
    .i_enable_pipe(i_enable_pipe),
    .i_debug_unit(i_debug_unit),
    .i_addr_debug_unit(i_addr_debug_unit),
    .i_addr_mem_debug_unit(i_addr_mem_debug_unit),
    .i_ctrl_read_debug_reg(i_ctrl_read_debug_reg),
    .i_ctrl_wr_debug_mem(i_ctrl_wr_debug_mem),
    .i_ctrl_addr_debug_mem(i_ctrl_addr_debug_mem),
    .o_bit_sucio(o_bit_sucio),
    .o_data_send_pc(o_data_send_pc),
    .o_data_reg_debug_unit(o_data_reg_debug_unit),
    .o_data_mem_debug_unit(o_data_mem_debug_unit),
    .o_count_cycles(o_count_cycles),
    .o_halt(o_halt)
  );

  // Proceso para cargar las instrucciones en el arreglo

  always @(posedge clock) begin
    if (i_reset) 
      begin
        // Reiniciar el índice de carga
        i_addr_inst_load <= 0;
        i_inst_load <= 0;
        i <= 0;
      end 
      else if (i_en_write && i < 3) 
        begin
        // Cargar instrucciones en el arreglo
          if (i_debug_unit) 
            begin
              i_inst_load = instrucciones[i];
              i_addr_inst_load = i_addr_inst_load+ 1;  
              i = i + 1;
            end 
          else 
            begin
              i_addr_inst_load <= i_addr_inst_load;
              i_inst_load <= i_inst_load;
            end

        end
  end
  // Clock generation
  always #1 clock = ~clock;

  // Initialize inputs
  initial begin
    clock = 0;
    i_reset = 0;
    i_inst_load = 0;
    i_addr_inst_load = 0;
    i_en_write = 0;
    i_en_read = 0;
    i_enable_mem = 0;
    i_enable_pipe = 0;
    i_debug_unit = 0;
    i_addr_debug_unit = 0;
    i_addr_mem_debug_unit = 0;
    i_ctrl_read_debug_reg = 0;
    i_ctrl_wr_debug_mem = 0;
    i_ctrl_addr_debug_mem = 0;
    instrucciones[0] = 32'b11111000000000000000000000000000;  // NOP
    //LW COMMENT
    //instrucciones[1] = 32'b10001100010001010000000000000000;  // LW $5, 0($2) //100011  00010  00101  0000000000000000 
    
    //ADD COMMENT
    //instrucciones[1] = 32'b00000000001001010010000000100001;  // ADD $4, $1, $5 //000000 00001 00101 00100 00000 100001

    //SW COMMENT
    //instrucciones[1] = 32'b10101100010001110000000000000000;  // SW $7, 0($2) //101011  00010  00111  0000000000000000 

    // instrucciones[1] = 32'h00000002;
    // instrucciones[2] = 32'h00000003;
    // instrucciones[3] = 32'h00000004;
    // instrucciones[4] = 32'h00000005;
    // instrucciones[5] = 32'h00000006;
    // instrucciones[6] = 32'h00000007;
    // instrucciones[7] = 32'h00000008;
    // instrucciones[8] = 32'h00000009;
    // instrucciones[9] = 32'h0000000A;
    

    #2 i_reset = 1; // Apply reset
    #2 i_reset = 0; // Deassert reset
    #4
    i_debug_unit = 1;
    i_en_write = 1;
    #4
    i_debug_unit = 0;
    i_en_write = 0;
    i_inst_load = 0;
    // TODO: Provide test stimulus here
    #11
    i_enable_pipe = 1;
    i_en_read = 1;
    #20 $finish; // End simulation
  end

endmodule







