`timescale 1ns / 1ps

module tb_PIPELINE;

  // Parameters
  localparam  NB_PC = 32;
  localparam  NB_INSTRUCTION = 32;
  localparam  NB_DATA = 32;
  localparam  NB_REG = 5;
  localparam  NB_ADDR = 32;
  localparam  NB_memory_data_ADDR = 7;
  localparam  NB_OPCODE = 6;
  localparam  NB_MEM_WIDTH = 8;

  // Ports
  reg i_clock;
  reg i_pc_enable;
  reg i_pc_reset;
  reg i_read_enable;
  reg i_ID_reset;
  reg i_reset_forward_stall;

  reg 						        i_instru_mem_enable;         // Debug Unit
  reg 						        i_instru_mem_write_enable;   // Debug Unit
  reg [NB_MEM_WIDTH-1:0] 	i_instru_mem_data;           // Debug Unit
  reg [NB_ADDR-1:0]			  i_instru_mem_addr;        // Debug Unit
  reg 						        i_bank_register_enable;         // Debug Unit
  reg 						        i_bank_register_read_enable;    // Debug Unit
  reg [NB_REG-1:0]			  i_bank_register_addr;        // Debug Unit
  reg 						        i_mem_data_enable;         // Debug Unit
  reg 						        i_mem_data_read_enable;    // Debug Unit
  reg [NB_memory_data_ADDR-1:0]		i_mem_data_read_addr;   // Debug Unit
  reg 					        	i_unit_control_enable;         // Debug Unit

  wire [NB_PC-1:0]			  o_pc_value;          // Debug Unit
  wire [NB_DATA-1:0]		  o_bank_register_data;           // Debug Unit
  wire [NB_MEM_WIDTH-1:0]	o_mem_data_data;           // Debug Unit
  wire 						        o_halt;               // Debug Unit

  PIPELINE 
  #(.NB_PC(NB_PC),
    .NB_INSTRUCTION(NB_INSTRUCTION),
    .NB_DATA(NB_DATA),
    .NB_REG(NB_REG),
    .NB_ADDR(NB_ADDR),
    .NB_memory_data_ADDR(NB_memory_data_ADDR),
    .NB_OPCODE(NB_OPCODE),
    .NB_MEM_WIDTH(NB_MEM_WIDTH) // Todas las memorias, excepto bank register tienen WIDTH = 8
)
  PIPELINE_1 (.i_clock(i_clock),
                .i_pc_enable(i_pc_enable),
                .i_pc_reset(i_pc_reset),
                .i_read_enable( i_read_enable),
                .i_ID_reset(i_ID_reset),
                .i_reset_forward_stall(i_reset_forward_stall),           // Forwarding unit
                .i_pipeline_enable(),
                .i_MEM_debug_unit_flag(),
                .i_instru_mem_enable(i_instru_mem_enable),             // Debug Unit
                .i_instru_mem_write_enable(i_instru_mem_write_enable), // Debug Unit
                .i_instru_mem_data(i_instru_mem_data),                 // Debug Unit
                .i_instru_mem_addr(i_instru_mem_addr),           // Debug Unit
                .i_bank_register_enable(i_bank_register_enable),             // Debug Unit
                .i_bank_register_read_enable(i_bank_register_read_enable),   // Debug Unit
                .i_bank_register_addr(i_bank_register_addr),           // Debug Unit
                .i_mem_data_enable(i_mem_data_enable),             // Debug Unit
                .i_mem_data_read_enable(i_mem_data_read_enable),   // Debug Unit
                .i_mem_data_read_addr(i_mem_data_read_addr), // Debug Unit
                .i_unit_control_enable(i_unit_control_enable),             // Debug Unit
                .o_halt(o_halt),                         // Debug Unit
                .o_bank_register_data(o_bank_register_data),                 // Debug Unit
                .o_mem_data_data(o_mem_data_data),                 // Debug Unit
                .o_last_pc(o_pc_value)                 // Debug Unit
                );                        

  initial begin
    i_clock 			    = 1'b0;
    i_pc_enable 		  = 1'b0;
    i_pc_reset 			  = 1'b1;
    i_reset_forward_stall      = 1'b1;
    i_read_enable 		= 1'b0;
    i_ID_reset 	= 1'b1;

    i_instru_mem_enable 		  = 1'b0;
    i_instru_mem_write_enable = 1'b0;
    i_instru_mem_data 			  = 8'd0;
    i_instru_mem_addr 		  = 32'd0;

    i_bank_register_enable 		  = 1'b0;
    i_bank_register_read_enable 	= 1'b0;
    i_bank_register_addr 		  = 5'd0;

    i_mem_data_enable 		  = 1'b0;
    i_mem_data_read_enable 	= 1'b0;
    i_mem_data_read_addr = 7'd0;

    i_unit_control_enable = 0;

    #20
    i_pc_enable       = 1'b1;
    i_reset_forward_stall      = 1'b0;
    i_pc_reset        = 1'b0;
    i_ID_reset  = 1'b0;
    i_read_enable     = 1'b1;

    i_instru_mem_enable = 1'b1;
    i_bank_register_enable = 1'b1;
    i_mem_data_enable = 1'b1;
    i_unit_control_enable = 1'b1;
        
    #700
    $finish;
  end

  always
    #5  i_clock = ! i_clock ;

endmodule
