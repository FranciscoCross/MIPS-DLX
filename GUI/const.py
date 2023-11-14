# INTRUCTIONS:
# R-TYPE
ADD = 'add'
ADDU = 'addu' 
SUB = 'sub'
SUBU = 'subu'
AND = 'and'
OR = 'or'
NOR = 'nor'
XOR = 'xor'
SLL = 'sll'
SRL = 'srl'
SRA = 'sra'
SLLV = 'sllv'
SRLV = 'srlv'
SRAV = 'srav'
SLT = 'slt'

# I-TYPE
LB = 'lb'
LH = 'lh'
LHU = 'lhu'
LW = 'lw' # rt=*(int*)(offset+rs)
LWU = 'lwu' 
LBU = 'lbu' 
SB = 'sb'
SH = 'sh'
SW = 'sw'
ADDI = 'addi' # rt=rs+imm
ANDI = 'andi' # rt=rs&imm
ORI = 'ori'
XORI = 'xori'
LUI = 'lui' # rt=imm<<16
SLTI = 'slti' # rt=rs<imm
BEQ = 'beq' # if(rs==rt) pc+=offset*4
BNE = 'bne'
JR = 'jr' #rd=pc; pc=rs
JALR = 'jalr' # pc=rs

#TYPE-J
J = 'j' # pc=pc_upper|(target<<2)
JAL = 'jal' # last_register=pc; pc=target<<2

#NONE 
halt = 'halt'

#Instructions
Inst_R = {"sll": '000000',
          "srl": '000010',
          "sra": '000011',
          "sllv": '000100',
          "srlv": '000110',
          "srav": '000111',
          "addu": '100001',
          "subu": '100011',
          "and": '100100',
          "or": '100101',
          "xor": '100110',
          "nor": '100111',
          "slt": '101010'}

Inst_L_S = {"lb": '100000',
            "lh": '100001',
            "lw": '100011',
            "lwu": '100111',
            "lbu": '100100',
            "lhu": '100101',
            "sb": '101000',
            "sh": '101001',
            "sw": '101011'}


Inst_I = {"addi": '001000',
          "andi": '001100',
          "ori": '001101',
          "xori": '001110',
          "lui": '001111',
          "slti": '001010',
          "beq": '000100',
          "bne": '000101'}

Inst_J = {"j": '000010',
          "jal": '000011'}

Inst_J_R = {"jr": '001000',
            "jalr": '001001'}

Inst_HALT = {"halt": '111111'}

#Registers
registros = {"R0": "00000", "R1": "00001", "R2": "00010", "R3": "00011", "R4": "00100", "R5": "00101", "R6": "00110", "R7": "00111",
             "R8": "01000", "R9": "01001", "R10": "01010", "R11": "01011", "R12": "01100", "R13": "01101", "R14": "01110", "R15": "01111",
             "R16": "10000", "R17": "10001", "R18": "10010", "R19": "10011", "R20": "10100", "R21": "10101", "R22": "10110", "R23": "10111",
             "R24": "11000", "R25": "11001", "R26": "11010", "R27": "11011", "R28": "11100", "R29": "11101", "R30": "11110", "R31": "11111"}