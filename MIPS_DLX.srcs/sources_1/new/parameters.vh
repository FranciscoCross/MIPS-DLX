/* alu code */
`define R_ALUCODE        3'b000
`define L_S_ADDI_ALUCODE 3'b001
`define ANDI_ALUCODE     3'b010
`define ORI_ALUCODE      3'b011
`define XORI_ALUCODE     3'b100
`define LUI_ALUCODE      3'b101
`define SLTI_ALUCODE     3'b110

/* OPERACIONES ALU*/
`define SLL             4'b0000       
`define SRL             4'b0001
`define SRA             4'b0010
`define ADD             4'b0011
`define SUB             4'b0100
`define AND             4'b0101
`define OR              4'b0110
`define XOR             4'b0111
`define NOR             4'b1000
`define SLT             4'b1001
`define LUI             4'b1010


/* codigo op de las instrucciones*/
`define R_TYPE_OPCODE   6'b000000   
`define LB_OPCODE       6'b100000   
`define LH_OPCODE       6'b100001   
`define LW_OPCODE       6'b100011
`define LWU_OPCODE      6'b100111
`define LBU_OPCODE      6'b100100
`define LHU_OPCODE      6'b100101
`define SB_OPCODE       6'b101000
`define SH_OPCODE       6'b101001
`define SW_OPCODE       6'b101011
`define ADDI_OPCODE     6'b001000
`define ANDI_OPCODE     6'b001100    
`define ORI_OPCODE      6'b001101  
`define XORI_OPCODE     6'b001110    
`define LUI_OPCODE      6'b001111    
`define SLTI_OPCODE     6'b001010    
`define BEQ_OPCODE      6'b000100        
`define BNE_OPCODE      6'b000101
`define J_OPCODE        6'b000010  
`define JAL_OPCODE      6'b000011   
`define NOP_OPCODE	    6'b111110
`define HALT_OPCODE     6'b111111

`define SLL_FUNCTION    6'b000000
`define SRL_FUNCTION    6'b000010
`define SRA_FUNCTION    6'b000011
`define SRLV_FUNCTION   6'b000110
`define SRAV_FUNCTION   6'b000111
`define ADDU_FUNCTION   6'b100001
`define SLLV_FUNCTION   6'b000100
`define SUBU_FUNCTION   6'b100011
`define AND_FUNCTION    6'b100100
`define OR_FUNCTION     6'b100101
`define XOR_FUNCTION    6'b100110
`define NOR_FUNCTION    6'b100111
`define SLT_FUNCTION    6'b101010
`define JALR_FUNCTION   6'b001001
`define JR_FUNCTION     6'b001000   

`define N_ELEMENTS 128
`define ADDRWIDTH $clog2(`N_ELEMENTS)