`timescale 1ns / 1ps

module IF_ID_reg#(
        parameter NB_PC             = 32,
        parameter NB_INSTRUCTION    = 32
    )
    (
        input                       i_clock,
        input                       i_reset,
        input                       i_pipeline_enable,  // DEBUG UNIT
        input                       i_enable, // STALL UNIT: 1 -> data hazard (stall) 0 -> !data_hazard
        input                       i_flush,            // STALL UNIT: 1 -> control hazards     0 -> !control_hazard
        input [NB_PC-1:0]           i_adder_result,
        input [NB_INSTRUCTION-1:0]  i_instruction,
        
        output [NB_PC-1:0]          o_adder_result,
        output [NB_INSTRUCTION-1:0] o_instruction
    );
    
    reg [NB_PC-1:0]             adder_result;
    reg [NB_INSTRUCTION-1:0]    instruction;

    always @(negedge i_clock) begin
        if(i_reset)begin
            adder_result    <= {32{1'b0}};
            instruction <= {32{1'b0}};
        end
        else begin
            if(i_pipeline_enable) begin
                if(i_enable) begin
                    if(i_flush) begin
                        adder_result    <= i_adder_result;
                        instruction <= {32{1'b0}};
                    end
                    else begin
                        adder_result    <= i_adder_result;
                        instruction <= i_instruction;
                    end
                end
                else begin
                    adder_result    <= adder_result;
                    instruction <= instruction;
                end
            end
            else begin
                adder_result    <= adder_result;
                instruction <= instruction;
            end
        end    
    end

    assign o_adder_result      = adder_result;
    assign o_instruction   = instruction;
    
endmodule
