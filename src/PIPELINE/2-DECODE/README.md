# Módulo Decode

El módulo Decode es responsable de interpretar y decodificar las instrucciones. El objetivo del módulo Decode es analizar el tipo de instrucción entrante y generar señales de control y campos de datos para las etapas posteriores del pipeline. Se encarga de realizar las siguientes tareas:

1. Decodificar el código de operación (**opcode**) y el código de función (**funct**) de la instrucción de entrada.
2. Determinar el tipo de instrucción (R-Type, I-Type, J-Type).
3. Generar señales de control adecuadas para configurar las unidades funcionales relevantes en las etapas posteriores del pipeline (por ejemplo, ALU, unidad de registro, memoria de datos).
4. Proporcionar información sobre los registros fuente (fuente A y fuente B) y la ubicación del registro de destino.
5. Identificar instrucciones especiales como saltos (jump) y paradas (halt).

![Esquematico](/img/PIPELINE/2-DECODE/schematic.jpg?raw=true "Esquematico")

### Submódulo Unit Control

El submódulo Unit Control se encarga de generar señales de control en función del tipo de instrucción. Recibe el **código de operación** y el **código de función** como entradas y genera señales de control como:

- **o_alu_op**: Señal que configura la operación que realizará la ALU (por ejemplo, suma, resta, AND, OR).
- **o_signed**: Indica si se requiere una operación con signo.
- **o_reg_dest**: Controla si se debe escribir en un registro de destino.
- Otras señales relacionadas con la lectura y escritura de registros, acceso a memoria y operaciones de salto y halts.

### Submódulo Banco de Registros (reg_file)

El submódulo Banco de Registros es responsable de leer y escribir en los registros del procesador. El módulo Decode se comunica con el submódulo de registro para obtener los valores de los registros fuente (fuente A y fuente B) y especificar el registro de destino en caso de instrucciones de escritura.

### Submódulo de Extensión de Signo (ext_sign)

El submódulo de extensión de signo se utiliza para extender el bit de signo de los valores de entrada, lo que es necesario para operaciones que involucran números con signo. Se comunica con el módulo Decode para realizar la extensión de signo según sea necesario.

### Submódulo de Extensión (extend)

El submódulo de extensión se utiliza para extender el tamaño de un campo de datos. Por ejemplo, cuando se desea extender un campo de 5 bits a 32 bits, este submódulo se encarga de realizar la extensión. El módulo Decode se comunica con este submódulo para realizar extensiones de datos según sea necesario.
