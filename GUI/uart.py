import time
import serial
import numpy as np

registers = ['0', '1', '2', '3',
             '4', '5', '6', '7',
             '8', '9', '10', '11',
             '12', '13', '14', '15',
             '16', '17', '18', '19',
             '20', '21', '22', '23',
             '24', '25', '26', '27',
             '28', '29', '30', '31']

NB_mem_data = 128
NB_BANK_REG = 128
PC_SIZE       = 4
# Define los códigos de colores ANSI
class Color:
    RESET = "\033[0m"
    RED = "\033[31m"
    GREEN = "\033[32m"
    YELLOW = "\033[33m"
    # Agrega más colores según tus necesidades
class Uart():
    def __init__(self, port, baudrate=19200):
    
        self.ser = None
        try:
            self.ser = serial.Serial(
                port     = port,	
                baudrate = baudrate,
                parity   = serial.PARITY_NONE,
                stopbits = serial.STOPBITS_ONE,
                bytesize = serial.EIGHTBITS
            )
        except serial.SerialException as e:
            print(f'Invalid port {port} .')
            exit()

        if self.ser is not None: 
            self.allData = []
            self.ser.isOpen()
            self.ser.timeout=None
            self.ser.flushInput()
            self.ser.flushOutput()
            print(f'Port: {self.ser.port} \nBaudrate: {self.ser.baudrate} \nTimeout: {self.ser.timeout}')
        

    def send_command(self, command):
        byte_msg = command.to_bytes(1, 'big')
        self.ser.write(byte_msg)
        

    def send_file(self, instructions):
        print('UART: Sending data...')
        count = 0

        for instruction in instructions:
            for byte in instruction:
                try:
                    print("sending {0}".format(byte))
                    data = self.bistring_to_byte(byte)
                    self.ser.write(data)

                except (FileNotFoundError, serial.SerialException) as e:
                    print("Error during data transmission:", e)    
            print("[{0}] sent instruction: {1}".format(count, instruction))
            count += 1
            
        print("DONE sending instructions.")
        self.ser.reset_output_buffer()
        return count
        
    def write_32bits(self, max_bytes, mem_type):
        """
        Imprime en consola de a 4 bytes. Para esto shiftea los bytes hasta que completa
        4.
        """

        shift = 24
        data = 0
        addr = 0
        bytes_received = 0

        while bytes_received < max_bytes:
            byte_received = self.ser.read(1)
            data = data | (int.from_bytes(byte_received, "big") << shift)
        
            if shift == 0:
                self.write_line(data, addr, mem_type)
                shift = 24
                data = 0
                addr = addr + 1
            else:     
                shift = shift - 8

            bytes_received = bytes_received + 1

    def receive_file(self, max_bytes, mem_type): 
        print("UART: receiving bytes...")
        if((max_bytes % 4) != 0):
            print("UART ERROR: bytes are not multiple of 4.")
            return
        self.write_32bits(max_bytes, mem_type)
        self.ser.reset_input_buffer()       
    
    def write_line_debug(self, mem_type, byte_index, i):
        bistring_32 = ""
        line = f'{[byte_index]}'

        # CREO LA PALABRA DE 32 bits con los cuatro bytes que llegaron
        for j in range(4):
            bistring_32 += self.allData[j + i]

        decimal = int(bistring_32, 2)
        hex_data = hex(decimal)

        # Definir el formato común para todas las líneas excepto para "PC"
        common_format_string = "Address:{:<4}\tDec:{:<4}\tHex:{:<8}\tBin:{:<32}"
        pc_format_string = "Dec:{:<4}\tHex:{:<8}\tBin:{:<32}"

        # Seleccionar el formato según el tipo de memoria
        if mem_type == 'REG' or mem_type == 'MEM':
            line = common_format_string.format(byte_index, decimal, hex_data, bistring_32)
        elif mem_type == "PC":
            line = pc_format_string.format(decimal, hex_data, bistring_32)

        return line
                #(self, PC_SIZE, REGISTER_BANK_SIZE, mem_data_SIZE)
    def receive_all(self, PC_SIZE, REGISTER_BANK_SIZE, MEM_DATA_SIZE):
        """ 
        A diferencia de los otros metodos, este recibe todos los bytes de todas las memorias primero y luego las guarda
        o las imprime en archivos. Esto es para evitar perdidas de datos.
        max_bytes: es el total de bytes de todas las memorias/registros que se quieren recibir por uart.
        """
        
        bytes_received = 0
        byte_index = 0
        max_bytes =  PC_SIZE + REGISTER_BANK_SIZE + MEM_DATA_SIZE
        PC = ""
        BR = ""
        MEM = ""

        while bytes_received < max_bytes:

            byte_received = self.ser.read(1)        # UART RX
            data = int.from_bytes(byte_received, "big")
            self.allData.append(self.byte_to_bistring(data, 8))
            bytes_received = bytes_received + 1

        print("-------------------------------------------------")
        print("--------------------DATA MEMORY------------------")
        print("-------------------------------------------------")
        byte_index = 0 
        for i in range(PC_SIZE, PC_SIZE+MEM_DATA_SIZE, 4):
            line = self.write_line_debug("MEM", byte_index, i)
            MEM += line + "\n"
            print(line)
            byte_index += 1

        print("-------------------------------------------------")
        print("------------------BANK REGISTER------------------")
        print("-------------------------------------------------")
        byte_index = 0
        for i in range(PC_SIZE+MEM_DATA_SIZE, PC_SIZE+MEM_DATA_SIZE+REGISTER_BANK_SIZE, 4):
            line = self.write_line_debug("REG", byte_index, i)
            BR += line + "\n"
            print(line)
            byte_index += 1

        print("-------------------------------------------------")
        print("-------------------------------------------------")
        print("-------------------------------------------------")
        line = self.write_line_debug("PC", byte_index, 0)
        PC = line
        print(line)
     
        self.allData = []
        
        return PC, BR, MEM

 
    def write_line(self, bytes_data, addr, mem_type):

        decimal_data = bytes_data
        binario_data = self.byte_to_bistring(bytes_data, 32)
        hex_data = hex(decimal_data)

        if mem_type == 'REG':
            line = f"{Color.RED}Registro addr:{addr}{Color.RESET}\n\tDec:{decimal_data}\n\tHex:{hex_data}\n\tBin:{binario_data}"
        if mem_type == 'MEM':
            line = f"{Color.GREEN}Memoria addr:{addr}{Color.RESET}\n\tDec:{decimal_data}\n\tHex:{hex_data}\n\tBin:{binario_data}"
        if mem_type == "":
            line = f"{Color.YELLOW}PC:{Color.RESET}\n\tDec:{decimal_data}\n\tHex:{hex_data}\n\tBin:{binario_data}"

        print(line)

    def byte_to_bistring(self, bytes_data, size=8):
        bistring = bin(bytes_data)[2:]  # Obtiene la representación binaria y omite el prefijo "0b"
        bistring = bistring.zfill(size)  # Rellena con ceros a la izquierda hasta tener "size" bits

        return bistring
    
    def ascii_to_int(self, ascii_array):
        """
        Convierte un ascii array de 4 bytes de largo (un string) en un string de representacion binaria de 32 bits de largo.
        """
        byte_string = ""
        for ascii in ascii_array: # TODO: ver si el orden en que se apendean los strings es correcto (LSB al MSB)
            byte_string = byte_string + self.byte_to_bistring(int(ascii))


    def bistring_to_byte(self, bistring):
        byte = int(bistring.strip(), 2).to_bytes(1, 'big')   
        return byte 
