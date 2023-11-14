# Módulo WRITE_BACK

El módulo `WRITE_BACK` es una parte esencial de la etapa de escritura de un pipeline en un procesador. Su función principal es determinar si se realizará una escritura en los registros del procesador y seleccionar los datos que se escribirán.

![Esquematico](/img/PIPELINE/5-WRITE_BACK/schematic.jpg?raw=true "Esquematico")

Entradas:
- `i_reg_write`: Señal que indica si se debe realizar una escritura en los registros del procesador.
- `i_mem_to_reg`: Selector de multiplexor que decide si los datos de la memoria deben escribirse en los registros.
- `i_mem_data`: Datos desde la memoria que se escribirán en los registros (cuando `i_mem_to_reg` es 1).
- `i_alu_result`: Resultado de la ALU que se escribirá en los registros (cuando `i_mem_to_reg` es 0).
- `i_selected_reg`: Número de registro seleccionado para la escritura.
- `i_last_register_ctrl`: Control de registro especial que se utiliza en instrucciones específicas (como JAL y JALR).
- `i_pc`: Valor del contador de programa.
- `i_halt`: Señal que puede utilizarse para detener la operación del procesador.

Salidas:
- `o_reg_write`: Señal que indica si se debe realizar una escritura en los registros del procesador.
- `o_selected_data`: Datos seleccionados para escribirse en los registros (dependiendo de `i_mem_to_reg` y `i_last_register_ctrl`).
- `o_selected_reg`: Número de registro seleccionado para la escritura.
- `o_halt`: Señal que puede utilizarse para detener la operación del procesador.

Operación:
- El módulo `WRITE_BACK` toma varias entradas, incluida la decisión de escribir en los registros (`i_reg_write`) y la selección de datos para la escritura, que dependen del selector `i_mem_to_reg` y el control `i_last_register_ctrl`.

- Un multiplexor (`mux2_10`) decide si los datos de la memoria (`i_mem_data`) o el resultado de la ALU (`i_alu_result`) se deben escribir en los registros, según el valor de `i_mem_to_reg`.

- Otro multiplexor (`mux2_11`) selecciona los datos que se escribirán en los registros entre los datos de salida del primer multiplexor y el contador de programa (`i_pc`), dependiendo del control `i_last_register_ctrl`.

- Las salidas del módulo incluyen señales para controlar la escritura en los registros, los datos seleccionados para escribirse en los registros, el número de registro seleccionado y una señal de detención opcional.

