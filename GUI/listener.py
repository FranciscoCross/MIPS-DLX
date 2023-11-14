import serial

def leer_puerto_serie(puerto, velocidad):
    with serial.Serial(puerto, velocidad, timeout=1) as ser:
        while True:
            dato = ser.read(1)
            if dato:
                # Obtener el dato en formato binario con longitud de 8 bits
                dato_binario = format(ord(dato), '08b')
                print(f'Dato en binario (8 bits): {dato_binario}')

if __name__ == "__main__":
    puerto_serie = "COM2"  # Cambiar a tu puerto serie específico, por ejemplo, "/dev/ttyS1" en Linux
    velocidad_bps = 19200  # Ajustar según la velocidad de tu dispositivo

    leer_puerto_serie(puerto_serie, velocidad_bps)
