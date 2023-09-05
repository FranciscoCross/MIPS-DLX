import serial

# Configura la comunicación UART
ser = serial.Serial('COM7', 19200)  # Reemplaza 'COM1' por el puerto UART de tu dispositivo y 9600 por la velocidad deseada

# Datos binarios crudos que deseas enviar
raw_value = 0x01

try:
    # Envía los datos binarios crudos
    ser.write(raw_value)

    # Puedes agregar una pausa si es necesario
    # time.sleep(1)

    print("Datos enviados correctamente")
except Exception as e:
    print(f"Error al enviar datos: {e}")
finally:
    ser.close()  # Cierra la conexión UART cuando hayas terminado
