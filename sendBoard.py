import serial

# Abre el puerto COM para enviar datos (asegúrate de que el puerto esté configurado correctamente)
puerto_uart = serial.Serial('COM7', 9600)  # Reemplaza 'COM1' y la velocidad baud según tu configuración

# Define el número de 8 bits que deseas enviar (de 0 a 255)
numero_8_bits = 1  # Cambia esto al número que quieras enviar

# Asegúrate de que el número esté en el rango válido (0-255)
if 0 <= numero_8_bits <= 255:
    # Convierte el número en un carácter y envíalo a través del puerto UART
    puerto_uart.write(chr(numero_8_bits).encode())
    print(f"Enviado: {numero_8_bits}")
else:
    print("El número debe estar en el rango de 0 a 255")

# Cierra el puerto UART cuando hayas terminado
puerto_uart.close()
