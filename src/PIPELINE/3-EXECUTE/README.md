# Módulo EXECUTE 
La etapa de ejecución del procesador es gestionada por el módulo EXECUTE, que se encarga de realizar operaciones aritméticas, lógicas y de control de flujo necesarias para ejecutar una instrucción dada. Es una parte crucial del procesador, encargada de ejecutar instrucciones y determinar los resultados de las operaciones. Durante esta etapa, se interactúa con otros módulos del procesador, como el módulo de memoria (MEM) y el módulo de escritura en registros (WB), para completar la ejecución de instrucciones.


![Esquematico](/img/PIPELINE/3-EXECUTE/schematic.jpg?raw=true "Esquematico")

### Entradas

- `i_signed`: Indicador de que las operaciones deben considerar valores con signo.
- `i_reg_write`: Bandera que señala si se debe escribir en un registro en la etapa de escritura en registros (WB).
- `i_mem_to_reg`: Bandera que especifica si el dato proviene de la memoria.
- `i_mem_read`: Bandera que activa la lectura de memoria en la etapa de MEM.
- `i_mem_write`: Bandera que activa la escritura en memoria en la etapa de MEM.
- `i_branch`: Bandera que señala si se ha tomado un salto condicional en la etapa de MEM.
- `i_alu_src`: Control de selección de fuente para la ALU.
- `i_reg_dest`: Control de selección del registro de destino.
- `i_alu_op`: Código de operación de la ALU.
- `i_pc`: Contador de programa actual.
- `i_data_a`: Datos de entrada A para la ALU.
- `i_data_b`: Datos de entrada B para la ALU.
- `i_immediate`: Valor inmediato utilizado en operaciones.
- `i_shamt`: Cantidad de desplazamiento (shamt) para operaciones de desplazamiento.
- `i_rt`: Número de registro RT.
- `i_rd`: Número de registro RD.
- `i_byte_enable`: Control para habilitar operaciones de byte.
- `i_halfword_enable`: Control para habilitar operaciones de media palabra.
- `i_word_enable`: Control para habilitar operaciones de palabra.
- `i_halt`: Bandera de detención de la ejecución.
- `i_mem_fwd_data`: Datos reenviados desde la etapa MEM.
- `i_wb_fwd_data`: Datos reenviados desde la etapa WB.
- `i_fwd_a`: Selección de fuente A para el reenvío.
- `i_fwd_b`: Selección de fuente B para el reenvío.
- `i_forwarding_mux`: Control de selección de fuente para el reenvío.
- `i_jump`: Bandera que señala una instrucción de salto.

### Salidas

- `o_signed`: Indicador de que las operaciones deben considerar valores con signo.
- `o_reg_write`: Bandera que señala si se debe escribir en un registro en la etapa de escritura en registros (WB).
- `o_mem_to_reg`: Bandera que especifica si el dato proviene de la memoria.
- `o_mem_read`: Bandera que activa la lectura de memoria en la etapa de MEM.
- `o_mem_write`: Bandera que activa la escritura en memoria en la etapa de MEM.
- `o_branch`: Bandera que señala si se ha tomado un salto condicional en la etapa de MEM.
- `o_branch_addr`: Dirección de salto condicional calculada.
- `o_zero`: Indicador de que el resultado de la ALU es igual a cero.
- `o_alu_result`: Resultado de la operación realizada por la ALU.
- `o_data_b`: Datos de entrada B para la ALU.
- `o_selected_reg`: Registro seleccionado como resultado de la etapa de ejecución.
- `o_byte_enable`: Control para habilitar operaciones de byte.
- `o_halfword_enable`: Control para habilitar operaciones de media palabra.
- `o_word_enable`: Control para habilitar operaciones de palabra.
- `o_last_register_ctrl`: Control de selección de registro de retención (last_register).
- `o_pc`: Contador de programa actual.
- `o_halt`: Bandera de detención de la ejecución.
- `o_jump`: Bandera que señala una instrucción de salto.

## Submódulo alu

**Descripción:**

El submódulo `alu` (Unidad de Lógica Aritmética) es un componente fundamental utilizado en la etapa de ejecución de un procesador para llevar a cabo operaciones aritméticas y lógicas en datos. Este submódulo toma dos operandos, realiza una operación basada en una señal de control y produce un resultado.


**Entradas:**

- `i_A`: Primer operando de la ALU (ancho de NB_REG bits).
- `i_B`: Segundo operando de la ALU (ancho de NB_REG bits).
- `i_alu_ctrl`: Señal de control que especifica el tipo de operación a realizar.

**Salidas:**

- `o_zero`: Indica si el resultado de la operación es igual a cero.
- `o_result`: Resultado de la operación realizada por la ALU (ancho de NB_REG bits).

**Comportamiento:**

El submódulo `alu` realiza una operación aritmética o lógica en los operandos `i_A` e `i_B`, dependiendo de la señal de control `i_alu_ctrl`. La operación a realizar se define según el valor de `i_alu_ctrl`, y el resultado se proporciona en `o_result`. La señal `o_zero` se activa si el resultado es cero.


## Submódulo alu_control

**Descripción:**

El submódulo `alu_control` se encarga de generar las señales de control para la Unidad de Lógica Aritmética (ALU) en la etapa de ejecución de un procesador. Recibe como entradas el código de función (`i_funct_code`) y el código de operación (`i_alu_op`) y genera señales de control que indican a la ALU qué tipo de operación debe realizar.

**Parámetros:**

- `NB_FCODE`: Ancho del código de función (por defecto 6 bits).
- `NB_OPCODE`: Ancho del código de operación (por defecto 6 bits).
- `NB_ALU_CTRLI`: Ancho de la señal de control de la ALU (por defecto 4 bits).
- Parámetros de función: Códigos de función para operaciones de la ALU, como suma, resta y operaciones lógicas.
- Parámetros de operación: Códigos de operación para instrucciones, como R-type, JAL, BEQ, etc.

**Entradas:**

- `i_funct_code`: Código de función para instrucciones de tipo R (ancho de 6 bits).
- `i_alu_op`: Código de operación de la instrucción (ancho de 6 bits).

**Salidas:**

- `o_alu_ctrl`: Señal de control que indica el tipo de operación de la ALU.
- `o_shamt_ctrl`: Señal de control para el multiplexor que selecciona entre `i_shamt` e `i_data_a`.
- `o_last_register_ctrl`: Señal de control para seleccionar el registro `last_register`.


## Submódulo `adder`

### Descripción

El submódulo `adder` es una unidad lógica que se utiliza para realizar operaciones de suma y resta. Es fundamental para el cálculo de direcciones de salto condicional, así como para la ejecución de instrucciones que involucran operaciones aritméticas.

### Entradas

- `i_A`: Entrada que representa el primer operando de la operación de suma o resta.
- `i_B`: Entrada que representa el segundo operando de la operación de suma o resta.

### Salidas

- `o_result`: Salida que proporciona el resultado de la operación de suma o resta entre `i_A

## Submódulo `mux2 DataB o Valor inmediato`

### Descripción

El submódulo `mux2_dataB_or_Inm` es un multiplexor de 2 entradas que se utiliza para seleccionar entre dos fuentes de datos: `i_data_b` e `i_immediate`. La elección depende del valor de `i_alu_src`.

### Entradas

- `i_alu_src`: Control de selección para elegir entre `i_data_b` e `i_immediate`.
- `i_data_b`: Primera entrada para selección.
- `i_immediate`: Segunda entrada para selección.

### Salidas

- `o_data`: Salida que proporciona el valor seleccionado entre `i_data_b` e `i_immediate`.

## Submódulo `mux2 de RT o RD`

### Descripción

El submódulo `mux2_RT_or_RD` es un multiplexor de 2 entradas que se utiliza para seleccionar entre dos registros, `i_rt` e `i_rd`. La elección depende del valor de `i_reg_dest`.

### Entradas

- `i_reg_dest`: Control de selección para elegir entre `i_rt` e `i_rd`.
- `i_rt`: Primera entrada para selección.
- `i_rd`: Segunda entrada para selección.

### Salidas

- `o_data`: Salida que proporciona el valor seleccionado entre `i_rt` e `i_rd`.

## Submódulo `mux2 RT/RD o LAST_REG`

### Descripción

El submódulo `mux2_RT_RD_or_LAST_REG` es un multiplexor de 2 entradas que se utiliza para seleccionar entre tres fuentes de datos: `RT_or_RD`, `i_mem_fwd_data`, y `i_wb_fwd_data`. La elección depende del valor de `last_register_ctrl`.

### Entradas

- `last_register_ctrl`: Control de selección para elegir entre `RT_or_RD`, `i_mem_fwd_data`, e `i_wb_fwd_data`.
- `RT_or_RD`: Primera entrada para selección.
- `i_mem_fwd_data`: Segunda entrada para selección.
- `i_wb_fwd_data`: Tercera entrada para selección.

### Salidas

- `o_data`: Salida que proporciona el valor seleccionado entre `RT_or_RD`, `i_mem_fwd_data`, e `i_wb_fwd_data`.

## Submódulo `mux2 valor shamt o DataA`

### Descripción

El submódulo `mux2_shamt_OR_dataA` es un multiplexor de 2 entradas que se utiliza para seleccionar entre `i_shamt` e `i_data_a`. La elección depende del valor de `select_shamt`.

### Entradas

- `select_shamt`: Control de selección para elegir entre `i_shamt` e `i_data_a`.
- `i_shamt`: Primera entrada para selección.
- `i_data_a`: Segunda entrada para selección.

### Salidas

- `o_data`: Salida que proporciona el valor seleccionado entre `i_shamt` e `i_data_a`.

## Submódulo `mux4, mux que elige entre la salida de los demas mux`

### Descripción

El submódulo `mux4_shamt_dataA_OR_mem_data_OR_forward_data` es un multiplexor de 4 entradas que se utiliza para seleccionar entre `out_mux2_shamt_OR_dataA`, `i_mem_fwd_data`, `i_wb_fwd_data`, y una cuarta entrada no especificada. La elección depende del valor de `i_fwd_a`.

### Entradas

- `i_fwd_a`: Control de selección para elegir entre las cuatro fuentes de datos.
- `out_mux2_shamt_OR_dataA`: Primera entrada para selección.
- `i_mem_fwd_data`: Segunda entrada para selección.
- `i_wb_fwd_data`: Tercera entrada para selección.

### Salidas

- `o_data`: Salida que proporciona el valor seleccionado entre `out_mux2_shamt_OR_dataA`, `i_mem_fwd_data`, `i_wb_fwd_data`, o la cuarta entrada no especificada.

## Submódulo `mux4_dataB_Inm_OR_mem_data_OR_forward_data`

### Descripción

El submódulo `mux4_dataB_Inm_OR_mem_data_OR_forward_data` es un multiplexor de 4 entradas que se utiliza para seleccionar entre `dataB_or_Inm`, `i_mem_fwd_data`, `i_wb_fwd_data`, y una cuarta entrada no especificada. La elección depende del valor de `i_fwd_b`.

### Entradas

- `i_fwd_b`: Control de selección para elegir entre las cuatro fuentes de datos.
- `dataB_or_Inm`: Primera entrada para selección.
- `i_mem_fwd_data`: Segunda entrada para selección.
- `i_wb_fwd_data`: Tercera entrada para selección.

### Salidas

- `o_data`: Salida que proporciona el valor seleccionado entre `dataB_or_Inm`, `i_mem_fwd_data`, `i_wb_fwd_data`, o la cuarta entrada no especificada.

## Submódulo `mux4_mem_data_OR_wb_data_OR_dataB`

### Descripción

El submódulo `mux4_mem_data_OR_wb_data_OR_dataB` es un multiplexor de 4 entradas que se utiliza para seleccionar entre `i_mem_fwd_data`, `i_wb_fwd_data`, `i_data_b`, y una cuarta entrada no especificada. La elección depende del valor de `i_forwarding_mux`.

### Entradas

- `i_forwarding_mux`: Control de selección para elegir entre las cuatro fuentes de datos.
- `i_mem_fwd_data`: Primera entrada para selección.
- `i_wb_fwd_data`: Segunda entrada para selección.
- `i_data_b`: Tercera entrada para selección.

### Salidas

- `o_data`: Salida que proporciona el valor seleccionado entre `i_mem_fwd_data`, `i_wb_fwd_data`, `i_data_b`, o la cuarta entrada no especificada.
