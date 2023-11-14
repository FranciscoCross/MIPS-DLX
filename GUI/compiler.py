from const import Inst_I, Inst_R, Inst_L_S, Inst_J, Inst_J_R, Inst_HALT, registros

R = lambda op_code, rs, rt, rd, shamp, funct: op_code + str(rs) + str(rt) + str(rd) + shamp + str(funct)
I = lambda op_code, rs, rt, address: str(op_code) + str(rs) + str(rt) + str(address)
J = lambda op_code, address: str(op_code) + str(address)

def make_R(instruccion, file):
  opcode = "000000"
  shamp = "00000"
  rd = "00000"
  rs = "00000"
  rt = "00000"
  if(instruccion[0] in Inst_R.keys()):
    funct = Inst_R[instruccion[0]].lower()
    rd = registros[instruccion[1]].upper()
    rs = registros[instruccion[2]].upper()
    rt = registros[instruccion[3]].upper()

  print(R(opcode, rs, rt, rd, shamp, funct))
  return R(opcode, rs, rt, rd, shamp, funct)

def make_I(instruccion, file):
  opcode = "000000"
  inm = "0000000000000000"
  rs = "00000"
  rt = "00000"

  if(instruccion[0] in Inst_I.keys()):
    #Type I
    opcode = Inst_I[instruccion[0]].lower()
    if(opcode == Inst_I["lui"]):
      rt = registros[instruccion[1].upper()]
      inm = format(int(instruccion[2]), '016b')
    elif((opcode == Inst_I["beq"]) or (opcode == Inst_I["bne"])):
      rs = registros[instruccion[1].upper()]
      rt = registros[instruccion[2].upper()]
      inm = format(int(instruccion[3]), '016b')
    else:
      rt = registros[instruccion[1].upper()]
      inm = format(int(instruccion[2]), '016b')
  elif(instruccion[0] in Inst_HALT.keys()):
    #HALT
    opcode = Inst_HALT[instruccion[0]]
  else:
    #Load/Store
    opcode = Inst_L_S[instruccion[0]]
    rt = registros[instruccion[1].upper()]
    dst = instruccion[2].split('(')[1].replace(')', '')
    if(dst in registros.keys()):
      rs =  registros[dst.upper()]
    else:
      rs = format(int(dst), '05b')
    inm = format(int(instruccion[2].split('(')[0]), '016b')
  print(I(opcode, rs, rt, inm))
  return I(opcode, rs, rt, inm) 

def make_J(instruccion, file):
    instr = instruccion[0].lower()
    if(instr in Inst_J.keys()):
        opcode = Inst_J[instruccion[0]].lower()
        inm = format(int(instruccion[1]), '026b')
    else:
        opcode = "000000"
        funct = "000000"
        funct = Inst_J_R[instruccion[0]]
        if(funct == Inst_J_R["jalr"]):
            rs = registros[instruccion[2].upper()]
        elif(funct == Inst_J_R["jr"]):
            rs = registros[instruccion[1].upper()]
        inm = str(rs) + "000000000000000" + str(funct)
    print(J(opcode, inm))
    return J(opcode, inm)

def compilar(file : str):
    archivo = open(file)
    string = archivo.read().strip().replace(",", "")
    archivo.close()

    programa = string.split('\n')
    compiled = open ('compiled.txt', 'w')
    assembled = []
    line_count = 0
    for linea in programa:
        print("Compiling instruction: ", linea)
        instruccion = linea.split(" ")
        func = instruccion[0]
        asm = ""
        #Type R
        if(func in Inst_R.keys()):
            asm = make_R(instruccion, compiled)
        #Type I
        if(func in Inst_I.keys() or func in Inst_HALT.keys() or func in Inst_L_S.keys()):
            asm = make_I(instruccion, compiled)
        #Type J
        if(func in Inst_J.keys() or func in Inst_J_R.keys()):
            asm = make_J(instruccion, compiled)
        compiled.write(asm + "\n")
        assembled.append(asm)
        line_count = line_count + 1

    for line in range(line_count, 64, 1):
        assembled.append("00000000000000000000000000000000")
    
    print(assembled)
    print(len(assembled))
    compiled.close()
    return assembled
