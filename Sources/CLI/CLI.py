import serial
import argparse

def enviar_elemento_uart(elemento, puerto_uart):
    with serial.Serial(puerto_uart, baudrate=9600) as ser:
        ser.write(str(elemento).encode())
        print(f"Elemento enviado por UART: {elemento}")

def enviar_elementos_desde_archivo(archivo, puerto_uart):
    with open(archivo, 'r') as file:
        elementos = file.readlines()
        for elemento in elementos:
            valor_entero = int(elemento.strip(), 2)  # Convierte el binario a decimal
            enviar_elemento_uart(valor_entero, puerto_uart)

def mostrar_lista_valores_y_funciones(lista_de_comandos):
    print("Seleccione un valor para enviar por UART:")
    for i, (valor, funcion) in enumerate(lista_de_comandos, start=1):
        print(f"{i}. {funcion} ({valor})")

def main():
    parser = argparse.ArgumentParser(description="Programa para enviar elementos binarios por UART")
    parser.add_argument("--uart", required=True, help="Puerto UART (por ejemplo, COM1, /dev/ttyS0 o loop:// para UART virtual)")
    parser.add_argument("--inicial", type=int, required=True, help="Elemento inicial en su forma cruda a enviar por UART")
    parser.add_argument("--archivo", required=True, help="Archivo de elementos binarios a enviar")
    
    args = parser.parse_args()

    # Enviar elemento inicial por UART
    enviar_elemento_uart(args.inicial, args.uart)

    # Enviar elementos binarios desde el archivo
    enviar_elementos_desde_archivo(args.archivo, args.uart)

    # Definir una lista de valores y sus funciones asociadas
    lista_de_comandos = [
        (1, "CMD_WRITE_IM"),
        (4, "CMD_SEND_BR"),
        (6, "CMD_SEND_PC"),
        (5, "CMD_SEND_MEM"),
        # Agrega más valores y funciones según tus necesidades
    ]

    mostrar_lista_valores_y_funciones(lista_de_comandos)

    # Solicitar al usuario que seleccione un valor
    seleccion = input("Seleccione un valor (1, 2, 3, etc.): ")

    try:
        seleccion = int(seleccion)
        if 1 <= seleccion <= len(lista_de_comandos):
            elemento_seleccionado, _ = lista_de_comandos[seleccion - 1]
            enviar_elemento_uart(elemento_seleccionado, args.uart)
        else:
            print("Selección no válida.")
    except ValueError:
        print("Entrada no válida. Ingrese un número válido.")

if __name__ == "__main__":
    main()
