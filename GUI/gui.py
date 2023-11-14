import tkinter as tk
import tkinter.messagebox as messagebox
import os 

from tkinter import filedialog
from uart import Uart
from compiler import compilar
import serial.tools.list_ports

COMMAND_1 = "Escribir programa"
COMMAND_2 = "Ejecucion continua"
COMMAND_3 = "Step by step"
COMMAND_4 = "Obtener INFO"
COMMAND_5 = "Send step"

commands = {1: COMMAND_1,
            2: COMMAND_2,
            3: COMMAND_3,
            4: COMMAND_4,
            5: COMMAND_5
            }

mem_data_SIZE = 128  # 128 bytes of depth
REGISTER_BANK_SIZE = 128  # 32 * 4 bytes
PC_SIZE = 4  # 4 bytes
INS_MEM_SIZE = 256  # lineas
mem_data_FILE = 'mem_data.txt'
REGISTER_BANK_FILE = 'register_bank.txt'
PC_FILE = 'program_counter.txt'

commands_files = {4: [REGISTER_BANK_SIZE],
                  5: [mem_data_SIZE],
                  6: [PC_SIZE]}

class GUI:

    def __init__(self, uart_port='loop://', baudrate=19200):

        self.next_action = {1: self.send_program,
                            4: self.receive_file,
                            5: self.receive_file,
                            6: self.receive_file, }

        # file_name = translate_file(instruction_file)
        #
        
        #self.instruction_file = instruction_file
        self.instruction_size = 0  # Necesario para saber cuantos steps mandar
        self.compiled = []
        self.ventana = tk.Tk()  # Main menu
        self.ventana.title("MIPS-DLX")
        self.ventana.geometry("200x150")
        self.selected_port = None
        self.selected_baudrate = None
        self.uart = None
        self.file_ventana = None  # File ventana
        self.ex_ventana = None  # Execution ventana
        self.debug_ventana = None  # Debug ventana
        self.maximum_steps = None
        self.last_command = 0
        self.sent_step = 0

        ports = ["COM1", "COM2", "COM3","COM4", "COM5", "COM6","COM7"]
        
        self.port_var = tk.StringVar()
        if ports:
            self.port_var.set(ports[0])

        port_menu = tk.OptionMenu(self.ventana, self.port_var, *ports)
        port_menu.pack()
        
        baudrate_var = tk.StringVar()
        baudrate_var.set(baudrate)  # Set the default baudrate
        baudrate_options = [9600, 19200, 38400, 57600, 115200]  # Add more options as needed

        port_label = tk.Label(self.ventana, text="Select Port:")
        port_label.pack()

        baudrate_label = tk.Label(self.ventana, text="Baudrate:")
        baudrate_label.pack()
        baudrate_menu = tk.OptionMenu(self.ventana, baudrate_var, *baudrate_options)
        baudrate_menu.pack()

        def on_select():
            self.selected_port = self.port_var.get()
            self.selected_baudrate = int(baudrate_var.get())
            print("Selected port:", self.selected_port)
            print("Selected baudrate:", self.selected_baudrate)

            try:
                self.uart = Uart(self.selected_port, self.selected_baudrate)
                if self.uart:
                    message = f"UART Creada en puerto {self.selected_port} a {self.selected_baudrate} baudios"
                    messagebox.showinfo("UART Creada", message)
                    self.open_read_file()
                else:
                    messagebox.showerror("Error", "No se pudo crear la UART.")
            except Exception as e:
                messagebox.showerror("Error", f"Error al crear la UART: {str(e)}")
            
            print("Selected port:", self.selected_port)
            print("Selected baudrate:", self.selected_baudrate)

        select_button = tk.Button(self.ventana, text="Seleccionar Puerto", command=on_select)
        select_button.pack()


        self.sent_step = 0
       
        self.ventana.mainloop()

 
    def open_read_file(self):
        self.ventana.withdraw()
        self.file_ventana = tk.Toplevel(self.ventana)
        self.file_ventana.geometry("1020x820")
        self.file_ventana.resizable(0, 0)
        self.file_ventana.title("MIPSNEITOR 2000")

        select_file_frame = tk.Frame(self.file_ventana)
        select_file_frame.grid(row=0, column=0, padx=10, pady=10, sticky="w")

        select_button = tk.Button(select_file_frame, text="Seleccionar archivo", command=self.select_file, width=15)
        select_button.pack(side=tk.LEFT)

        self.file_label = tk.Label(select_file_frame, text="Archivo seleccionado: ", anchor="w")
        self.file_label.pack(side=tk.LEFT)

        label_text_frame = tk.Frame(self.file_ventana)
        label_text_frame.grid(row=1, column=0, padx=10, pady=10)

        assembly_code_label = tk.Label(label_text_frame, text="Assembly Code")
        assembly_code_label.grid(row=0, column=0, padx=(0, 10))

        machine_code_label = tk.Label(label_text_frame, text="Machine Code")
        machine_code_label.grid(row=0, column=2, padx=(10, 0))

        left_content_frame = tk.Frame(label_text_frame)
        left_content_frame.grid(row=1, column=0, padx=(0, 10), sticky="nsew")

        self.line_numbers = tk.Text(left_content_frame, wrap=tk.NONE, width=2, height=20, state=tk.DISABLED)
        self.line_numbers.grid(row=0, column=0, sticky="nsew")

        self.text_widget = tk.Text(left_content_frame, wrap=tk.NONE, width=40, height=20)
        self.text_widget.grid(row=0, column=1)
        self.text_widget.configure(state='disabled')

        right_content_frame = tk.Frame(label_text_frame)
        right_content_frame.grid(row=1, column=2, padx=(10, 0))

        self.compiled_text_widget = tk.Text(right_content_frame, wrap=tk.NONE, width=40, height=20)
        self.compiled_text_widget.grid(row=0, column=0)
        self.compiled_text_widget.configure(state='disabled')

        self.scrollbar = tk.Scrollbar(left_content_frame, command=self.text_widget.yview)
        self.scrollbar.grid(row=0, column=2, sticky="ns")
        self.text_widget.config(yscrollcommand=self.scrollbar.set)

        self.compiled_scrollbar = tk.Scrollbar(right_content_frame, command=self.compiled_text_widget.yview)
        self.compiled_scrollbar.grid(row=0, column=1, sticky="ns")
        self.compiled_text_widget.config(yscrollcommand=self.compiled_scrollbar.set)

        bottom_text_frame = tk.Frame(self.file_ventana)
        bottom_text_frame.grid(row=2, column=0, padx=10, pady=10, sticky="nsew")

        bank_register_label = tk.Label(bottom_text_frame, text="Bank Register")
        bank_register_label.grid(row=0, column=0)

        memory_label = tk.Label(bottom_text_frame, text="Memory")
        memory_label.grid(row=0, column=1)

        pc_label = tk.Label(bottom_text_frame, text="PC")
        pc_label.grid(row=0, column=2)

        self.bank_register_text_widget = tk.Text(bottom_text_frame, wrap=tk.NONE, width=40, height=20)
        self.bank_register_text_widget.grid(row=1, column=0, padx=5)
        self.bank_register_text_widget.configure(state='disabled')

        self.memory_text_widget = tk.Text(bottom_text_frame, wrap=tk.NONE, width=40, height=20)
        self.memory_text_widget.grid(row=1, column=1, padx=5)
        self.memory_text_widget.configure(state='disabled')   # Para deshabilitar la escritura

        self.pc_text_widget = tk.Text(bottom_text_frame, wrap=tk.NONE, width=40, height=20)
        self.pc_text_widget.grid(row=1, column=2, padx=5)
        self.pc_text_widget.configure(state='disabled')

        # Crear un Frame para contener los botones "Enviar programa", "Ejecución CONTINUA", "Ejecución STEP" y "Compilar"
        button_frame = tk.Frame(self.file_ventana)
        button_frame.grid(row=4, column=0, pady=5)

        # Botón para compilar el archivo
        compile_button = tk.Button(button_frame, text="Compilar", command=self.compile_file)
        compile_button.grid(row=0, column=0, padx=10)

        # Botón para enviar el programa
        send_program_button = tk.Button(button_frame, text="Enviar programa", command=self.send_program)
        send_program_button.grid(row=0, column=1, padx=10)

        # Botón para ejecución CONTINUA
        execute_continuous_button = tk.Button(button_frame, text="Ejecución CONTINUA", command=self.ejecucion_continua)
        execute_continuous_button.grid(row=0, column=2, padx=10)

        # Botón para ejecución STEP
        execute_step_button = tk.Button(button_frame, text="Ejecución STEP", command=self.ejecucion_step)
        execute_step_button.grid(row=0, column=3, padx=10)

        # Botón para Obtener info
        obtener_info_button = tk.Button(button_frame, text="Obtener INFO", command=self.obtener_info)
        obtener_info_button.grid(row=0, column=4, padx=10)

        # Centrar los botones en el frame
        button_frame.grid_columnconfigure((0, 1, 2, 3), weight=1)

    def update_bank_register_text(self, new_text):
        self.bank_register_text_widget.configure(state='normal')
        self.bank_register_text_widget.delete(1.0, tk.END)  # Borra el contenido anterior
        self.bank_register_text_widget.insert(tk.END, new_text)  # Inserta el nuevo contenido
        self.bank_register_text_widget.configure(state='disabled')

    def update_memory_text(self, new_text):
        self.memory_text_widget.configure(state='normal')
        self.memory_text_widget.delete(1.0, tk.END)
        self.memory_text_widget.insert(tk.END, new_text)
        self.memory_text_widget.configure(state='disabled')

    def update_pc_text(self, new_text):
        self.pc_text_widget.configure(state='normal')
        self.pc_text_widget.delete(1.0, tk.END)
        self.pc_text_widget.insert(tk.END, new_text)
        self.pc_text_widget.configure(state='disabled')

    def update_line_numbers(self):
        line_count = self.text_widget.index(tk.END).split(".")[0]
        line_numbers = '\n'.join(map(str, range(1, int(line_count) + 1)))
        self.line_numbers.config(state=tk.NORMAL)
        self.line_numbers.delete(1.0, tk.END)
        self.line_numbers.insert(tk.END, line_numbers)
        self.line_numbers.config(state=tk.DISABLED)

    def select_file(self):
        initial_directory = os.getcwd()
        file_path = filedialog.askopenfilename(
            filetypes=[("Archivos de texto", "*.txt")],
            initialdir=initial_directory
        )
        self.selected_file = file_path
        self.file_label.config(text=f"Archivo seleccionado: {self.selected_file}")
        # Actualiza el contenido de las cajas de texto
        self.text_widget.configure(state='normal')

        with open(self.selected_file, 'r') as file:
            file_content = file.read()
            self.text_widget.delete(1.0, tk.END)  # Borra el contenido anterior
            self.text_widget.insert(tk.END, file_content)
            self.update_line_numbers()  # Actualiza los números de línea
        self.compiled_text_widget.delete(1.0, tk.END)
        self.text_widget.configure(state='disenabled')

    def compile_file(self):
        self.compiled_text_widget.configure(state='normal')
        if self.selected_file:
            try:
                # Llama a la función compilar con el archivo seleccionado
                self.compiled = compilar(self.selected_file)
                self.compiled_text_widget.delete(1.0, tk.END)
                for asm in self.compiled:
                    self.compiled_text_widget.insert(tk.END, asm + "\n")
            except Exception as e:
                # Muestra un mensaje de error con messagebox
                messagebox.showerror("Error", f"Error al compilar: {str(e)}")
        else:
            # Muestra un mensaje de advertencia si no se ha seleccionado un archivo
            messagebox.showwarning("Advertencia", "Primero selecciona un archivo")
        self.compiled_text_widget.configure(state='disabled')

    def send_command(self):
        print(commands.get(self.option.get()))
        # Se envía comando por UART
        command = self.option.get()
        self.uart.send_command(command)

        # Siguiente funcion a ejecutar
        if command == 1:
            self.next_action.get(command)()
        else:
            self.next_action.get(command)(commands_files.get(command)[0])

    def split_instruction(self, instruccion_binaria):
        if len(instruccion_binaria) != 32:
            raise ValueError("La instrucción debe tener 32 bits")
        
        palabras = [instruccion_binaria[i:i+8] for i in range(0, 32, 8)]
        return palabras

    def send_program(self):
        if not self.compiled:
            messagebox.showerror("Error", "No se han compilado las instrucciones previamente.")
            return
        
        command = 1 #Enviar programa
        self.last_command = command

        # Se convierte el archivo con instrucciones a 'binario'
        n_instructions = len(self.compiled)
        n_bytes = [self.split_instruction(self.compiled[i]) for i in range(0, n_instructions, 1)]
        self.uart.send_command(command)
        if self.uart.send_file(n_bytes):
            success_msg = f"Instrucciones enviadas correctamente. Total de instrucciones: {n_instructions} "
            messagebox.showinfo("Éxito", success_msg)      
        print("Sent: ", commands.get(command))
        self.maximum_steps = n_instructions + 3

    def receive_file(self, file_size):
        # Se envía comando por UART
        command = self.option.get()
        print("Command: ", commands.get(command))
        self.uart.send_command(command)
        self.uart.receive_all(PC_SIZE, REGISTER_BANK_SIZE, mem_data_SIZE)

    def ejecucion_continua(self):   
        command = 2

        self.uart.send_command(command) #EJECUCION CONTINUA
        self.last_command = command
        msg = f'Cantidad de Ciclos: {self.sent_step} \n'
        print("Sent: ", commands.get(command))
        PC, BR, MEM = self.uart.receive_all(PC_SIZE, REGISTER_BANK_SIZE, mem_data_SIZE)
        self.update_bank_register_text(BR)
        self.update_memory_text(MEM)
        self.update_pc_text(PC)

    def ejecucion_step(self): 

        if(self.last_command == 1): #Escribir programa
            command = 3
            self.uart.send_command(command) #MODO STEP
            print("Sent: ", commands.get(command))
        
        command = 5
        self.sent_step += 1
        self.uart.send_command(command) #EJECUCION STEP
        self.last_command = command

        print("Sent: ", commands.get(command))

        PC, BR, MEM = self.uart.receive_all(PC_SIZE, REGISTER_BANK_SIZE, mem_data_SIZE)
        self.update_bank_register_text(BR)
        self.update_memory_text(MEM)
        self.update_pc_text(PC)

    def obtener_info(self): 
        result = tk.messagebox.askquestion("Advertencia", "No se puede obtener información si ya se envió el programa. ¿Quieres enviar igualmente?")

        if result == 'yes':
            # Código para manejar el caso en que el usuario elige "Override"
            # Aquí debes poner la lógica que deseas ejecutar al hacer clic en "Override"
            print("Usuario ha elegido Override")

            command = 4
            self.uart.send_command(command)
            print("Sent: ", commands.get(command))

            PC, BR, MEM = self.uart.receive_all(PC_SIZE, REGISTER_BANK_SIZE, mem_data_SIZE)
            self.update_bank_register_text(BR)
            self.update_memory_text(MEM)
            self.update_pc_text(PC)
        else:
            # Código para manejar el caso en que el usuario elige no hacer override
            print("Usuario ha optado por no hacer Override")
        return

if __name__ == '__main__':  
    gui = GUI()
