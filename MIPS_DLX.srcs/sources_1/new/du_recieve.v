`timescale 1ns / 1ps
`include "parameters.vh"

module du_recieve
	#(
		parameter NB_DATA    = 32,
		parameter N_BITS     = 8,
		parameter N_BYTES    = 4,		
		parameter NB_STATE   = 4			
	)
	(
		input wire i_clock,
		input wire i_reset,
		input wire i_enable,
		input wire i_rx_done_uart,
		input wire [NB_STATE-1:0] i_recieve_state,
		input wire [N_BITS-1:0] i_data_uart_receive,

	
		output wire [N_BITS-1:0] o_number_instructions,
		output wire o_ready_number_instr,
		output wire [NB_DATA-1:0] o_instruction,
		output wire o_ready_full_inst,
		output wire o_ready_all_instr_send,
		output wire [N_BITS-1:0] o_mode_operate,
		output wire o_ready_mode_operate
	);

//Localparams for states
localparam 	[NB_STATE-1:0]  Receive_Number_Instr  	=  	4'b0001;//1
localparam 	[NB_STATE-1:0]	Receive_One_Instr     	=	4'b0010;//2
localparam 	[NB_STATE-1:0]	Check_Send_All_Instr	=	4'b0100;//4
localparam 	[NB_STATE-1:0]	Waiting_operation  		=  	4'b1000;//8

//Regs
reg [N_BITS-1:0] number_instructions;
reg ready_number_instr;
reg ready_full_inst;
reg [NB_DATA-1:0] instruction;
reg [1:0] count_bytes;
reg [N_BITS-1:0] count_instruction_now;
reg all_instr_send;
reg [N_BITS-1:0] mode_operate;
reg ready_mode_operate;

//Assigns
assign o_number_instructions = number_instructions;
assign o_ready_number_instr = ready_number_instr;
assign o_instruction = instruction;
assign o_ready_full_inst = ready_full_inst;
assign o_ready_all_instr_send = all_instr_send;
assign o_mode_operate = mode_operate;
assign o_ready_mode_operate = ready_mode_operate;

always @(posedge i_clock)
begin
	if(i_reset)
	begin
		number_instructions <= {N_BITS{1'b0}};
		ready_full_inst <= 1'b0;
		instruction <= {NB_DATA{1'b0}};
		count_bytes <= {2{1'b0}};
		count_instruction_now <= {N_BITS{1'b0}};
		all_instr_send <= 1'b0;
		mode_operate <= {N_BITS{1'b0}};
		ready_mode_operate <= 1'b0;
		ready_number_instr <= 1'b0;
	end
	else if(i_enable)
	begin
		if(i_rx_done_uart)
		begin
			case (i_recieve_state)
				Receive_Number_Instr:
				begin
					number_instructions <= i_data_uart_receive;
					ready_number_instr  	<= 1'b1;
				end
				Receive_One_Instr:
				begin
					instruction <= {i_data_uart_receive, instruction[31:8]};
					if (count_bytes == N_BYTES-1) 
					begin
						count_instruction_now <= count_instruction_now + 1;
						count_bytes <= 2'b0;
						ready_full_inst <= 1'b1;
					end
					else
					begin
						ready_full_inst <= 1'b0;
						count_bytes <= count_bytes + 1'b1;						
					end
				end
				Waiting_operation:
				begin
					mode_operate <= i_data_uart_receive;
					ready_mode_operate <= 1'b1;	
				end
				default:
                begin
				    number_instructions <= number_instructions;
                    ready_full_inst <= ready_full_inst;
                    instruction <= instruction;
                    count_bytes <= count_bytes;
                    count_instruction_now <= count_instruction_now;
                    all_instr_send <= all_instr_send;
                    mode_operate <= mode_operate;
                    ready_mode_operate <= ready_mode_operate;
				end
			endcase
		end
		else if (count_instruction_now == number_instructions) 
			all_instr_send <= 1'b1;
		else 
		begin
			ready_number_instr <= 1'b0;
			ready_full_inst <= 1'b0;
			ready_mode_operate <= 1'b0;
			all_instr_send <= 1'b0;
		end
		end
end
endmodule