`timescale 1ns / 1ps

module tb_unit_control();

    parameter   NB_OPCODE       = 6;
    //Instruction OPCODEs
    parameter   RTYPE_OPCODE    = 6'h00;
    parameter   BEQ_OPCODE      = 6'h04; // ITYPE BEQ
    parameter   BNE_OPCODE      = 6'h05; // ITYPE BNE
    parameter   ADDI_OPCODE     = 6'h08; // ITYPE ADDI
    parameter   SLTI_OPCODE     = 6'h0a; // ITYPE SLTI
    parameter   ANDI_OPCODE     = 6'h0c; // ITYPE ANDI
    parameter   ORI_OPCODE      = 6'h0d; // ITYPE ORI
    parameter   XORI_OPCODE     = 6'h0e; // ITYPE XORI
    parameter   LUI_OPCODE      = 6'h0f; // ITYPE LUI
    parameter   LB_OPCODE       = 6'h20; // ITYPE LB
    parameter   LH_OPCODE       = 6'h21; // ITYPE LH
    parameter   LHU_OPCODE      = 6'h22; // ITYPE LHU
    parameter   LW_OPCODE       = 6'h23; // ITYPE LW
    parameter   LWU_OPCODE      = 6'h24; // ITYPE LWU
    parameter   LBU_OPCODE      = 6'h25; // ITYPE LBU
    parameter   SB_OPCODE       = 6'h28; // ITYPE SB
    parameter   SH_OPCODE       = 6'h29; // ITYPE SH
    parameter   SW_OPCODE       = 6'h2b; // ITYPE SW
    parameter   JALR_FUNCT      = 6'h09;
    parameter   JR_FUNCT        = 6'h08;
    parameter   HALT_OPCODE      = 6'h3f;
    
    reg                 clock;
    reg                 en;
    reg                 reset;
    reg [NB_OPCODE-1:0] opcode;
    reg                 funct;
    
    wire                 reg_dest;
    wire [NB_OPCODE-1:0] alu_op;
    wire                 alu_src;
    wire                 mem_read;
    wire                 mem_write;
    wire                 branch;
    wire                 reg_write;
    wire                 mem_to_reg;
    wire                 byte_enable;
    wire                 halfword_enable;
    wire                 word_enable;
    wire                 jr_jalr;
    wire                 halt;
    
    initial begin
    
        clock = 1'b0;
        reset = 1'b1;
        en = 1'b0;
        
        #40
        reset = 1'b0;
        en = 1'b1;
        opcode = RTYPE_OPCODE;
        // jumps tipo R
        #40
        funct = JALR_FUNCT; 
        #40
        funct = JR_FUNCT;
        // Tipo I
        #40
        opcode = BEQ_OPCODE;
        #40
        opcode = BNE_OPCODE;
        #40
        opcode = ADDI_OPCODE;
        #40
        opcode = SLTI_OPCODE;
        #40
        opcode = ANDI_OPCODE;
        #40
        opcode = ORI_OPCODE;
        #40
        opcode = XORI_OPCODE;
        #40
        opcode = LUI_OPCODE;
        #40
        opcode = LB_OPCODE;
        #40
        opcode = LH_OPCODE;
        #40
        opcode = LHU_OPCODE;
        #40
        opcode = LW_OPCODE;
        #40
        opcode = LWU_OPCODE;
        #40
        opcode = LBU_OPCODE;
        #40
        opcode = SB_OPCODE;
        #40
        opcode = SH_OPCODE;
        #40
        opcode = SW_OPCODE;
        #40
        opode = HALT_OPCODE;
        
        #200
        
        $finish;
    
    end
    
    always #10 clock = ~clock;
    
    unit_control unit_control(.i_enable(en),
                              .i_reset(reset),
                              .i_opcode(opcode),
                              .i_funct(funct),
                              .o_reg_dest(reg_dest),
                              .o_alu_op(alu_op),
                              .o_alu_src(alu_src),
                              .o_mem_read(mem_read),
                              .o_mem_write(mem_write),
                              .o_branch(branch),
                              .o_reg_write(reg_write),
                              .o_mem_to_reg(mem_to_reg),
                              .o_byte_enable(byte_enable),
                              .o_halfword_enable(halfword_enable),
                              .o_word_enable(word_enable),
                              .o_jr_jalr(jr_jalr),
                              .o_halt(halt));

endmodule
