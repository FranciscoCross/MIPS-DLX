`timescale 1ns / 1ps

module tb_alu();

    reg clock;
    
    parameter   SLL_FCODE       = 6'h00;
    parameter   SRL_FCODE       = 6'h02;
    parameter   SRA_FCODE       = 6'h03;
    parameter   SLLV_FCODE      = 6'h04;
    parameter   SRLV_FCODE      = 6'h06;
    parameter   SRAV_FCODE      = 6'h07;
    parameter   JALR_FCODE      = 6'h09;
    parameter   ADD_FCODE       = 6'h20;
    parameter   ADDU_FCODE      = 6'h21;
    parameter   SUB_FCODE       = 6'h22;
    parameter   SUBU_FCODE      = 6'h23;
    parameter   AND_FCODE       = 6'h24;
    parameter   OR_FCODE        = 6'h25;
    parameter   XOR_FCODE       = 6'h26;
    parameter   NOR_FCODE       = 6'h27;
    parameter   SLT_FCODE       = 6'h2a;
    
    parameter   RTYPE_OPCODE    = 6'h00;
    parameter   J_OPCODE        = 6'h02;
    parameter   JAL_OPCODE      = 6'h03;
    parameter   BEQ_OPCODE      = 6'h04;
    parameter   BNE_OPCODE      = 6'h05;
    parameter   ADDI_OPCODE     = 6'h08;
    parameter   SLTI_OPCODE     = 6'h0a;
    parameter   ANDI_OPCODE     = 6'h0c;
    parameter   ORI_OPCODE      = 6'h0d;
    parameter   XORI_OPCODE     = 6'h0e;
    parameter   LUI_OPCODE      = 6'h0f;
    parameter   LB_OPCODE       = 6'h20;
    parameter   LH_OPCODE       = 6'h21;
    parameter   LHU_OPCODE      = 6'h22;
    parameter   LW_OPCODE       = 6'h23;
    parameter   LWU_OPCODE      = 6'h24;
    parameter   LBU_OPCODE      = 6'h25;
    parameter   SB_OPCODE       = 6'h28;
    parameter   SH_OPCODE       = 6'h29;
    parameter   SW_OPCODE       = 6'h2b;
    
    // ALU Control parameters
    parameter NB_FCODE = 6;
    parameter NB_OPCODE = 6;
    parameter NB_ALU_CTRLI = 4;
    
    // ALU parameters
    parameter NB_REG = 32;
    
    // ALU Control inputs
    reg [NB_FCODE-1:0]  function_code;
    reg [NB_OPCODE-1:0] instruction_opcode;
    
    // ALU inputs
    reg [NB_REG-1:0] a;
    reg [NB_REG-1:0] b;
    
    // ALU Control outputs
    wire [NB_ALU_CTRLI-1:0] alu_control_input;
    wire                    shamt_ctrl;
    wire                    last_register_ctrl;
    
    // ALU outputs
    wire              zero;
    wire [NB_REG-1:0] result;
    
    
    initial begin
    
        clock = 1'b0;
        
        a = 2;
        b = 1;
        
        #20
        instruction_opcode = RTYPE_OPCODE;
        
        #20
        function_code      = ADD_FCODE;
        #20
        function_code      = ADDU_FCODE;
        #20
        function_code      = SUB_FCODE;
        #20
        function_code      = SUBU_FCODE;
        #20
        function_code      = AND_FCODE;
        #20
        function_code      = OR_FCODE;
        #20
        function_code      = XOR_FCODE;
        #20
        function_code      = NOR_FCODE;
        #20
        function_code      = SLT_FCODE;
        #20
        function_code      = SLL_FCODE;
        #20
        function_code      = SRL_FCODE;
        #20
        function_code      = SRA_FCODE;
        #20
        function_code      = SLLV_FCODE;
        #20
        function_code      = SRLV_FCODE;
        #20
        function_code      = SRAV_FCODE;
        
        
        #20
        instruction_opcode = BEQ_OPCODE;
        #20
        instruction_opcode = BNE_OPCODE;
        #20
        instruction_opcode = ADDI_OPCODE;
        #20
        instruction_opcode = SLTI_OPCODE;
        #20
        instruction_opcode = ANDI_OPCODE;
        #20
        instruction_opcode = ORI_OPCODE;
        #20
        instruction_opcode = XORI_OPCODE;
        #20
        instruction_opcode = LUI_OPCODE;
        #20
        instruction_opcode = LB_OPCODE;
        #20
        instruction_opcode = LH_OPCODE;
        #20
        instruction_opcode = LHU_OPCODE;
        #20
        instruction_opcode = LW_OPCODE;
        #20
        instruction_opcode = LWU_OPCODE;
        #20
        instruction_opcode = LBU_OPCODE;
        #20
        instruction_opcode = SB_OPCODE;
        #20
        instruction_opcode = SH_OPCODE;
        #20
        instruction_opcode = SW_OPCODE;
        
        
        
        
        #200
        
        $finish;
    
    end
    
    always #10 clock = ~clock;
    
    alu_control alu_control(.i_funct_code(function_code),
                            .i_ALU_op(instruction_opcode),
                            .o_ALU_ctrl(alu_control_input),
                            .o_shamt_ctrl(shamt_ctrl),
                            .o_last_register_ctrl(last_register_ctrl)
                            );
    
    alu alu(.i_A(a),
            .i_B(b),
            .i_ALU_ctrl(alu_control_input),
            .o_zero(zero),
            .o_result(result)
            );

endmodule
