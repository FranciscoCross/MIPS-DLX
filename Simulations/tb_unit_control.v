`timescale 1ns / 1ps

module tb_unit_control;

    localparam NB_OPCODE   = 6;
    localparam NB_FUNCTION = 6;
    localparam NB_EX_CTRL  = 7;
    localparam NB_MEM_CTRL = 6;
    localparam NB_WB_CTRL  = 3;

    reg clock = 0;
    reg i_enable = 0;
    reg [NB_OPCODE-1:0] 	i_op_code;
    reg [NB_FUNCTION-1:0]   i_function;

    wire [NB_EX_CTRL-1:0] 	o_EX_control;
    wire [NB_MEM_CTRL-1:0] 	o_M_control;
    wire [NB_WB_CTRL-1:0] 	o_WB_control;

    wire [1:0] 				o_pc_src;
    wire 					o_beq;
    wire 					o_bne;
    wire 					o_jump;
    wire 				    o_halt_detected;

    unit_control unit_control
	(	
		.i_enable(i_enable),	
		.i_op_code(i_op_code),
		.i_function(i_function),

		.o_EX_control(o_EX_control),
		.o_M_control(o_M_control), 
		.o_WB_control(o_WB_control),
		.o_pc_src(o_pc_src),
		.o_beq(o_beq),
		.o_bne(o_bne),
		.o_jump(o_jump),
		.o_halt_detected(o_halt_detected)
		
	);
    
    always #1 clock = ~clock; // # < timeunit > delay
       initial begin
            #10
            i_enable = 1;
            i_function = 0;
            i_op_code = 62;
            #2
            i_op_code = 15;
            i_function = 10;
            #2
            i_function = 20;
            #2
            i_function = 30;
            #2
            i_op_code = 0;
            i_function = 33;
            #6
            i_op_code = 4;
            i_function = 7;
            #2
            i_op_code = 8;
            i_function = 10;
            #2
            i_op_code = 2;
            i_function = 8;
            #2
            i_op_code = 62;
            i_function = 9;
            #4
            i_op_code = 35;
            #2
            i_op_code = 43;
            i_function = 1;
            #2
            i_op_code = 63;
            i_function = 0;
            #8
            $finish;
        end
endmodule