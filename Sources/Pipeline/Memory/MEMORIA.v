`timescale 1ns / 1ps

`include "parameters.vh"

`define MEM_READ 5
`define MEM_WRITE 4

module MEMORIA
	#(
		parameter NB_DATA = 32,
		parameter NB_MEM_CTRL = 6,
		parameter NB_WB_CTRL = 3
	)
	(
		input wire i_clock,
		input wire i_reset,
		input wire i_enable_mem,
		input wire i_dm_enable_read,
		input wire [NB_MEM_CTRL-1:0] i_MEM_control,
		input wire [NB_WB_CTRL-1:0] i_WB_control,
		input wire [`ADDRWIDTH-1:0] i_alu_result,                   //address
		input wire [NB_DATA-1:0] i_data_write,                      //dato a escribir en memoria

		input wire [`ADDRWIDTH-1:0] i_dm_addr,
		input wire i_dm_enable_addr,                           //addres para seleccionar mem or debug
		input wire i_dm_enable,                             //selector si es debug o no 

		output wire [NB_WB_CTRL-1:0] o_WB_control,
		output wire [NB_DATA-1:0] o_data_mem_debug_unit,
		output wire [NB_DATA-1:0] o_mem_data		
	);		
	wire [NB_DATA-1:0] wire_data_mem_read;
	wire [NB_DATA-1:0] wire_data_mem_write;

	wire [`ADDRWIDTH-1:0] wire_addr_mem;
	wire [NB_MEM_CTRL-1:0] MEM_control;

	wire [NB_DATA-1:0] wire_mem_data;

	reg [NB_DATA-1:0] reg_mem_data;
	reg [NB_DATA-1:0] reg_data_mem_debug_unit;

	reg [NB_WB_CTRL-1:0] WB_control_reg;

	assign o_data_mem_debug_unit = reg_data_mem_debug_unit;
	assign o_mem_data = reg_mem_data;
	assign o_WB_control = WB_control_reg;


	always @(posedge i_clock)
	begin
		if(i_reset)
		begin
			reg_data_mem_debug_unit <= 0;
			reg_mem_data <= 0;
			WB_control_reg <= 0;
			
		end
		else
		begin
			WB_control_reg <= i_WB_control;
			reg_data_mem_debug_unit <= wire_data_mem_read;
			reg_mem_data <= wire_mem_data;
		end
	end

	mux2#(.NB_DATA(`ADDRWIDTH)) mux_addr_debug_mem
	(
		.i_A(i_alu_result),         //0
		.i_B(i_dm_addr),//1
		.i_SEL(i_dm_enable_addr),
		.o_OUT(wire_addr_mem)
	);
	mux2#(.NB_DATA(NB_MEM_CTRL)) mux_wr_debug_mem
	(
		.i_A(i_MEM_control),
		.i_B(6'b101001), //lectura signed para debug
		.i_SEL(i_dm_enable),
		.o_OUT(MEM_control)
	);

	mem_controller mem_controller
	(		
		.i_data_write(i_data_write),
		.i_data_read(wire_data_mem_read),
		.i_MEM_control(MEM_control),
		.o_data_write(wire_data_mem_write),
		.o_data_read(wire_mem_data)		
	);

	dmem memory_data
	(
		.i_clock(i_clock),
		.i_mem_enable(i_enable_mem),
		.i_addr(wire_addr_mem),		
		.i_data(wire_data_mem_write),
		.i_read(MEM_control[`MEM_READ] || i_dm_enable_read),
		.i_write(MEM_control[`MEM_WRITE]),
		.o_data(wire_data_mem_read)
	);
endmodule