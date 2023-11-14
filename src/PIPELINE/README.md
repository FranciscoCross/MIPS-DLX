# Módulo PIPELINE

El módulo `PIPELINE` es una implementación de un procesador segmentado, diseñado para ejecutar instrucciones en múltiples etapas. Cada etapa del pipeline está diseñada para realizar un conjunto específico de tareas, lo que permite una mayor velocidad y eficiencia en la ejecución de instrucciones. A continuación, describiremos cada etapa del pipeline y sus responsabilidades:


## Etapa FETCH (FETCH)
El módulo FETCH se encarga de buscar la próxima instrucción a ejecutar desde la memoria de instrucciones (IMEM) y determinar la dirección de la siguiente instrucción. Para mas informacion detallada de esta estapa [Enlace README FETCH.](1-FETCH\README.md)
- **Entradas**:
  - `i_clock`: Señal de reloj.
  - `i_instru_mem_enable`: Habilita la memoria de instrucciones.
  - `i_branch`: Señal que indica una instrucción de salto.
  - `i_j_jal`: Señal que indica una instrucción de salto absoluto.
  - `i_jr_jalr`: Señal que indica una instrucción de salto indirecto.
  - `i_pc_enable`: Habilita el contador de programa.
  - `i_pc_reset`: Restablece el contador de programa.
  - `i_read_enable`: Habilita la lectura de memoria.
  - `i_write_enable`: Habilita la escritura en memoria.
  - `i_write_data`: Datos a escribir en memoria.
  - `i_write_addr`: Dirección de memoria a escribir.
  - `i_branch_addr`: Dirección de salto.
  - `i_jump_addr`: Dirección de salto absoluto.
  - `i_data_last_register`: Datos del registro de banco (pasados por el pipeline).

- **Salidas**:
  - `o_last_pc`: Dirección actual del contador de programa.
  - `o_adder_result`: Dirección de la siguiente instrucción (PC+4).
  - `o_instruction`: Instrucción recuperada de la memoria de instrucciones.

## Etapa IF_ID_reg (IF to ID Register)

- **Entradas**:
  - `i_clock`: Señal de reloj.
  - `i_reset`: Restablece el registro.
  - `i_pipeline_enable`: Habilita el pipeline.
  - `i_enable`: Habilita el registro (dependiendo de la detección de peligro).
  - `i_flush`: Indica si se debe borrar el registro.
  - `i_adder_result`: Resultado del sumador de dirección.
  - `i_instruction`: Instrucción actual desde la etapa FETCH.

- **Salidas**:
  - `o_adder_result`: Resultado del sumador de dirección (para la etapa ID).
  - `o_instruction`: Instrucción actual (para la etapa DECODE).

## Etapa DECODE (DECODE)

- **Entradas**:
  - `i_clock`: Señal de reloj.
  - `i_pipeline_enable`: Habilita el pipeline.
  - `i_reset`: Restablece la etapa.
  - `i_rb_enable`: Habilita la lectura del registro de banco (depuración).
  - `i_rb_read_enable`: Habilita la lectura de registros (depuración).
  - `i_rb_read_addr`: Dirección de lectura de registros (depuración).
  - `i_unit_control_enable`: Habilita la unidad de control (depuración).
  - `i_inst`: Instrucción actual.
  - `i_pc`: Dirección de programa.
  - `i_write_data`: Datos de escritura (desde la etapa WRITE_BACK).
  - `i_write_reg`: Registro de destino (desde la etapa WRITE_BACK).
  - `i_reg_write`: Señal de escritura en registros (desde la etapa WRITE_BACK).
  - `i_flush_unit_ctrl`: Señal de limpieza (desde la unidad de control).

- **Salidas**:
  - 
## Etapa ID_EX_reg (ID to EX Register)

- **Entradas** 
- **Salidas**:


## Etapa EXECUTE (EXECUTE)

- **Entradas** 
- **Salidas**:

## Etapa EX_MEM_reg (EX to MEM Register)

- **Entradas** 
- **Salidas**:

## Etapa MEMORY (MEMORY)

- **Entradas** 
- **Salidas**:

## Etapa MEM_WB_reg (MEM to WRITE BACK Register)

- **Entradas** 
- **Salidas**:

## Etapa WRITE_BACK (WRITE BACK)

- **Entradas** 
- **Salidas**:

# FORWARDING UNIT y STALL UNIT

- Estos modulos se encargan de gestionar los peligros y el flujo de datos en el pipeline, evitando problemas como el avance de datos (forwarding) y las paradas cuando se requieren instrucciones anteriores.
