//Instruction OPCODEs
`define RTYPE_OPCODE 6'h00
`define BEQ_OPCODE   6'h04
`define BNE_OPCODE   6'h05 
`define ADDI_OPCODE  6'h08 
`define SLTI_OPCODE  6'h0a 
`define ANDI_OPCODE  6'h0c 
`define ORI_OPCODE   6'h0d 
`define XORI_OPCODE  6'h0e 
`define LUI_OPCODE   6'h0f 
`define LB_OPCODE    6'h20 
`define LH_OPCODE    6'h21 
`define LHU_OPCODE   6'h22 
`define LW_OPCODE    6'h23 
`define LWU_OPCODE   6'h24 
`define LBU_OPCODE   6'h25 
`define SB_OPCODE    6'h28 
`define SH_OPCODE    6'h29 
`define SW_OPCODE    6'h2b 
`define J_OPCODE     6'h02 
`define JAL_OPCODE   6'h03 
`define JALR_FUNCT   6'h09
`define JR_FUNCT     6'h08
`define HALT_OPCODE  6'h3f
//Function codes
`define SLL_FCODE    6'h00
`define SRL_FCODE    6'h02
`define SRA_FCODE    6'h03
`define SLLV_FCODE   6'h04
`define SRLV_FCODE   6'h06
`define SRAV_FCODE   6'h07
`define JALR_FCODE   6'h09
`define ADD_FCODE    6'h20
`define ADDU_FCODE   6'h21
`define SUB_FCODE    6'h22
`define SUBU_FCODE   6'h23
`define AND_FCODE    6'h24
`define OR_FCODE     6'h25
`define XOR_FCODE    6'h26
`define NOR_FCODE    6'h27
`define SLT_FCODE    6'h2a
//Word Size
`define COMPLETE_WORD   3'b100
`define HALF_WORD       3'b010
`define BYTE_WORD       3'b001                   

//Debug Unit
// States
`define INITIAL            10'b0000000001
`define WRITE_IM           10'b0000000010
`define READY              10'b0000000100
`define START              10'b0000001000
`define STEP_BY_STEP       10'b0000010000
`define SEND_PC            10'b0000100000
`define READ_BR            10'b0001000000
`define SEND_BR            10'b0010000000
`define READ_MEM           10'b0100000000
`define SEND_MEM           10'b1000000000

// External commands
`define CMD_WRITE_IM        8'd1 // Escribir programa
`define CMD_CONTINUE        8'd2 // Ejecucion continua
`define CMD_STEP_BY_STEP    8'd3 // Step-by-step
`define CMD_SEND_INFO       8'd4 // Leer TODO
`define CMD_STEP            8'd5 // Send step