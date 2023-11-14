# Módulo FETCH

El módulo FETCH se encarga de buscar la próxima instrucción a ejecutar desde la memoria de instrucciones (IMEM) y determinar la dirección de la siguiente instrucción. 

![Esquematico](/img/PIPELINE/1-FETCH/schematic.jpg?raw=true "Esquematico")


### Parámetros

- `NB_PC`: Ancho de la dirección del contador de programa.
- `NB_INSTRUCTION`: Ancho de las instrucciones.
- `NB_IMEM_DEPTH`: Profundidad de la memoria de instrucciones.
- `NB_MEM_WIDTH`: Ancho de los datos de memoria.

### Entradas

- `i_clock`: Señal de reloj que controla el módulo.
- `i_branch`, `i_j_jal`, `i_jr_jalr`: Señales para indicar operaciones de salto o branch.
- `i_pc_enable`: Habilita el contador de programa.
- `i_pc_reset`: Restablece el contador de programa.
- `i_read_enable`: Habilita la lectura de la memoria de instrucciones.
- `i_instru_mem_enable`: Habilita la memoria de instrucciones.
- `i_write_enable`: Habilita la escritura en la memoria de instrucciones.
- `i_write_data`, `i_write_addr`: Datos y dirección para escribir en la memoria de instrucciones.
- `i_branch_addr`, `i_jump_addr`, `i_data_last_register`: Direcciones utilizadas para determinar la próxima instrucción.
- `i_pc_stall`: Señal de STALL que puede detener el contador de programa.

### Salidas

- `o_last_pc`: Dirección actual del contador de programa.
- `o_adder_result`: Dirección de la siguiente instrucción (PC+4).
- `o_instruction`: Instrucción recuperada de la memoria de instrucciones.


### Submódulos

El módulo FETCH utiliza varios submódulos para realizar las siguientes tareas:

- `program_counter`: Controla el contador de programa.
- `adder`: Realiza la suma de 4 al contador de programa.
- `latch`: Registra la dirección de la siguiente instrucción.
- Multiplexores (`mux2_1`, `mux2_2`, `mux2_3`): Se utilizan para seleccionar entre diferentes direcciones basadas en las señales de control.
- `instru_mem`: Accede a la memoria de instrucciones y recupera la instrucción.

## Submódulo `instru_mem`

El submódulo `instru_mem` es una implementación de una memoria de instrucciones:

### Parámetros

- `MEMORY_WIDTH`: Ancho de los datos de la memoria.
- `MEMORY_DEPTH`: Profundidad de la memoria.
- `NB_ADDR_DEPTH`: Ancho de la dirección de la memoria.
- `NB_ADDR`: Ancho de la dirección de lectura/escritura.
- `NB_INSTRUCTION`: Ancho de las instrucciones.

### Entradas

- `i_clock`: Señal de reloj que controla el módulo.
- `i_enable`: Control de la unidad de depuración.
- `i_read_enable`: Habilita la lectura de la memoria de instrucciones.
- `i_write_enable`: Habilita la escritura en la memoria de instrucciones.
- `i_write_data`, `i_write_addr`: Datos y dirección para escribir en la memoria de instrucciones.
- `i_read_addr`: Dirección desde la que se lee la instrucción.

### Salida

- `o_read_data`: Datos leídos desde la memoria de instrucciones.


## Submódulo `latch`

El submódulo `latch` es un registro que captura y retiene el valor de la señal de entrada en el flanco de subida del reloj.

### Entradas

- `i_clock`: Señal de reloj que controla el módulo.
- `i_next_pc`: Valor a capturar y retener en el registro.

### Salida

- `o_next_pc`: Salida del registro, que contiene el valor capturado.

### Registro `next_pc`

- Almacena el valor de entrada en el flanco de subida del reloj.

## Submódulo `program_counter`

El submódulo `program_counter` es un contador de programa que almacena la dirección de la siguiente instrucción.

### Entradas

- `i_enable`: Habilita el módulo del contador de programa.
- `i_clock`: Señal de reloj que controla el módulo.
- `i_reset`: Señal de reset para restablecer el contador de programa.
- `i_mux_pc`: Valor para actualizar el contador de programa.
- `i_pc_stall`: Señal para detener el contador de programa.

### Salida

- `o_pc`: Salida que representa la dirección de la siguiente instrucción.
