# Módulo MEMORY

El módulo `MEMORY` función principal es permitir la escritura y lectura de datos en la memoria, además de proporcionar salidas y controlar el flujo de datos.

![Esquematico](/img/PIPELINE/4-MEMORY/schematic.jpg?raw=true "Esquematico")

Entradas:
- `i_clock`: Señal de reloj para sincronizar operaciones.
- `i_debug_unit_flag`: Indicador de bandera de depuración para leer direcciones y datos desde la unidad de depuración.
- `i_signed`: Habilitación de lectura de datos como firmados.
- `i_memory_data_enable`: Señal de habilitación para permitir la lectura o escritura de datos desde la unidad de depuración.
- `i_memory_data_read_enable`: Habilitación de lectura de datos desde la unidad de depuración.
- `i_memory_data_read_addr`: Dirección de memoria utilizada para lectura desde la unidad de depuración.
- `i_reg_write`: Señal de escritura en registros (WB stage).
- `i_mem_to_reg`: Señal para escribir datos de memoria en registros (WB stage).
- `i_mem_read`: Habilitación de lectura de datos de memoria.
- `i_mem_write`: Habilitación de escritura de datos en memoria.
- `i_word_enable`: Habilitación de operaciones de palabra (word).
- `i_halfword_enable`: Habilitación de operaciones de media palabra (halfword).
- `i_byte_enable`: Habilitación de operaciones de byte.
- `i_branch`: Señal que indica una operación de salto (branch).
- `i_zero`: Señal que indica una comparación de igualdad (zero flag).
- `i_branch_addr`: Dirección de salto utilizada para operaciones de salto.
- `i_alu_result`: Resultado de la unidad aritmético-lógica (ALU) que actúa como dirección de escritura y lectura de datos en la memoria.
- `i_write_data`: Datos a escribir en la memoria (correspondientes a la data B en la etapa EX).
- `i_selected_reg`: Selección de registro (rd o rt) utilizado en la etapa WB.
- `i_last_register_ctrl`: Control para seleccionar el último registro (PC) en la etapa WB.
- `i_pc`: Dirección de programa actual.
- `i_halt`: Señal de parada del sistema.

Salidas:
- `o_mem_data`: Datos leídos desde la memoria de datos, destinados a ser escritos en el banco de registros o utilizados por la unidad de depuración.
- `o_read_dm`: Datos leídos desde la memoria de datos para la unidad de depuración.
- `o_selected_reg`: Selección de registro (rd o rt) que se utiliza en la etapa WB.
- `o_alu_result`: Resultado de la ALU, que actúa como dirección de escritura y lectura de datos en la memoria.
- `o_branch_addr`: Dirección de salto (PC) cuando se realiza una operación de salto.
- `o_branch_zero`: Selector del multiplexor FETCH.
- `o_reg_write`: Señal de escritura en registros (WB stage).
- `o_mem_to_reg`: Señal para escribir datos de memoria en registros (WB stage).
- `o_last_register_ctrl`: Control para seleccionar el último registro (PC) en la etapa WB.
- `o_pc`: Dirección de programa actual.
- `o_halt`: Señal de parada del sistema.

Funcionamiento:

1. El módulo `MEMORY` se encarga de gestionar la memoria de datos (RAM) de un sistema digital. Puede habilitar la lectura (`i_mem_read`) y escritura (`i_mem_write`) de datos en la memoria.

2. Las señales `i_word_enable`, `i_halfword_enable` e `i_byte_enable` determinan la anchura de lectura y escritura. Dependiendo de estas señales, se pueden realizar operaciones de lectura y escritura de palabras (word), medias palabras (halfword) o bytes.

3. La señal `i_signed` controla si la lectura de datos desde la memoria se realiza como valores con signo o sin signo.

4. El módulo permite la lectura y escritura de datos desde y hacia la memoria, utilizando la dirección especificada en `i_alu_result`. Los datos de escritura se proporcionan a través de `i_write_data`.

5. La señal `i_halt` permite detener el sistema según una condición específica.

6. La señal `i_memory_data_enable` se utiliza para habilitar la lectura y escritura de datos desde la degug unit.

7. `o_selected_reg`, `o_reg_write`, `o_mem_to_reg` y otras señales se utilizan en la etapa Write-Back (WB) del pipeline para controlar la escritura en registros y el flujo de datos.

Este módulo desempeña un papel crucial en la interacción entre el procesador y la memoria de datos, lo que permite la transferencia de datos en el sistema y el soporte para operaciones de memoria en el contexto de un sistema digital.

## Submódulo `mem_controller`:
   - `Descripción`: Este submódulo controla las operaciones de lectura y escritura en la memoria. Maneja ajustes de datos en función de las señales habilitadas de ancho de palabra y si la operación de lectura se realiza con signo o sin signo.


## Submódulo `mem_data`:
   - `Descripción`: Este submódulo gestiona la manipulación de datos dentro de la memoria. Maneja operaciones de lectura y escritura y controla las operaciones habilitadas.
