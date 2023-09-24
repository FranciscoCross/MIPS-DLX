import serial

def enviar_elemento_crudo(puerto_uart, elemento):
    with serial.Serial(puerto_uart, baudrate=19200) as ser:
        ser.write(bytes([elemento]))  # Convierte el número en un byte y lo envía
        print(f"Elemento {elemento} enviado por UART")

def main():
    puerto_uart = "COM7"
    elemento = 1  # El número que deseas enviar (en este caso, 3)
    
    try:
        enviar_elemento_crudo(puerto_uart, elemento)
    except serial.SerialException as e:
        print(f"Error al abrir el puerto UART: {e}")

if __name__ == "__main__":
    main()
