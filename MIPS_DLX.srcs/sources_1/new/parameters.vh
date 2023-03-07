/* ALU Code */
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

/* OPCODE INSTRUCCIONES*/
/* Tipo R y Tipo J*/
`define R_TYPE_OPCODE   6'b000000   

/* Tipo I*/
`define LB_OPCODE       6'b100000   //Load byte
`define LH_OPCODE       6'b100001   //Load half word
`define LW_OPCODE       6'b100011   //Load word
`define LWU_OPCODE      6'b100111   //Load word unsigned
`define LBU_OPCODE      6'b100100   //Load byte unsigned
`define LHU_OPCODE      6'b100101   //Load half word unsigned
`define SB_OPCODE       6'b101000   //Store byte
`define SH_OPCODE       6'b101001   //Store half word
`define SW_OPCODE       6'b101011   //Store word
`define ADDI_OPCODE     6'b001000   //Add immediate word
`define ANDI_OPCODE     6'b001100   //And immediate
`define ORI_OPCODE      6'b001101   //OR immediate
`define XORI_OPCODE     6'b001110   //XOR immediate
`define LUI_OPCODE      6'b001111   //Load upper immediate
`define SLTI_OPCODE     6'b001010   //Set on less than immediate
`define BEQ_OPCODE      6'b000100   //Branch on equal
`define BNE_OPCODE      6'b000101   //Branch on not equal
`define J_OPCODE        6'b000010   //Jump
`define JAL_OPCODE      6'b000011   //Jump and link
`define NOP_OPCODE	    6'b111110   //No operation
`define HALT_OPCODE     6'b111111   //Halt

/* FUNCTION CODE INSTRUCCIONES*/
/*TIPO R*/
`define SLL_FUNCTION    6'b000000
`define SRL_FUNCTION    6'b000010
`define SRA_FUNCTION    6'b000011
`define SLLV_FUNCTION   6'b000100   //Shift word left logical variable
`define SRLV_FUNCTION   6'b000110   //Shift word rigth logical variable
`define SRAV_FUNCTION   6'b000111   //Shift word right aritmethic variable
`define ADDU_FUNCTION   6'b100001
`define SUBU_FUNCTION   6'b100011
`define AND_FUNCTION    6'b100100
`define OR_FUNCTION     6'b100101
`define XOR_FUNCTION    6'b100110
`define NOR_FUNCTION    6'b100111
`define SLT_FUNCTION    6'b101010   //Set on less than
/* TIPO-J*/
`define JALR_FUNCTION   6'b001001   //Jump and link register
`define JR_FUNCTION     6'b001000   //Jump register

`define N_ELEMENTS 128
`define ADDRWIDTH $clog2(`N_ELEMENTS)

//Defines para usar en DECODE 
`define OP_CODE   31:26
`define RS_BIT    25:21
`define RT_BIT    20:16
`define RD_BIT    15:11
`define INM_BIT   15:0
`define FUNC_BIT  5:0
`define SHAMT_BIT 11:6
`define JUMP_BIT  25:0 
`define PC_BIT    31:28