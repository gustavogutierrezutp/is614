# Procesador RISC-V 32 bits en Verilog

Implementación de un procesador RISC-V 32 bits en Verilog para síntesis en FPGA usando Intel Quartus.

## Descripción

Este proyecto implementa un procesador RISC-V de 32 bits con arquitectura Harvard (memorias de instrucciones y datos separadas). El procesador soporta un subconjunto de instrucciones RV32I y está diseñado para ser sintetizado en una FPGA.

### Características

- Arquitectura de 32 bits
- 32 registros de propósito general (x0-x31)
- Memoria de instrucciones: 256 palabras (1 KB)
- Memoria de datos: 256 bytes
- Soporte para instrucciones tipo R, I, Load y Store
- Sistema de visualización con 6 displays de 7 segmentos
- 10 LEDs para depuración
- Switches para seleccionar información a visualizar

## Arquitectura

El procesador implementa las siguientes etapas:

1. **Fetch**: Obtención de instrucción desde memoria
2. **Decode**: Decodificación y lectura de registros
3. **Execute**: Ejecución en ALU
4. **Memory**: Acceso a memoria de datos
5. **Write-Back**: Escritura de resultado en registro

### Componentes principales

- `top_level`: Módulo principal que integra todos los componentes
- `program_counter`: Contador de programa
- `instruction_memory`: Memoria ROM para instrucciones
- `control_unit`: Unidad de control que genera señales
- `register_file`: Banco de 32 registros
- `immediate_generator`: Generador de valores inmediatos
- `alu`: Unidad aritmético-lógica
- `data_memory`: Memoria RAM para datos
- `display_mux`: Multiplexor para visualización
- `hex7seg`: Decodificador para displays de 7 segmentos

## Estructura del proyecto

```
.
├── top_level.v              # Módulo principal
├── alu.v                    # Unidad aritmético-lógica
├── control_unit.v           # Unidad de control
├── display_modules.v        # Módulos de visualización
├── memory_modules.v         # Memorias de datos e instrucciones
├── datapath_modules.v       # Componentes del datapath
└── salida_binario.txt       # Archivo con programa en binario
```

## Instrucciones soportadas

### Tipo R (Registro-Registro)
- `ADD`, `SUB`, `AND`, `OR`, `XOR`
- `SLL`, `SRL`, `SRA`
- `SLT`, `SLTU`

### Tipo I (Inmediato)
- `ADDI`, `ANDI`, `ORI`, `XORI`
- `SLLI`, `SRLI`, `SRAI`
- `SLTI`, `SLTIU`

### Load
- `LB`, `LH`, `LW` (con extensión de signo)
- `LBU`, `LHU` (sin extensión de signo)

### Store
- `SB`, `SH`, `SW`

## Uso

### Requisitos

- Intel Quartus Prime (versión 18.0 o superior recomendada)
- FPGA compatible (DE0, DE1, DE2, etc.)
- Cable USB Blaster para programación

### Compilación

1. Abrir Quartus Prime
2. Crear nuevo proyecto o abrir existente
3. Agregar todos los archivos `.v` al proyecto
4. Configurar el dispositivo FPGA target
5. Asignar pines según la tarjeta FPGA
6. Compilar el diseño

### Programación del procesador

1. Crear un archivo `salida_binario.txt` con las instrucciones en binario
2. Colocar el archivo en la ruta `../salida_binario.txt` (relativo al proyecto)
3. Cada línea debe contener una instrucción de 32 bits en formato binario

Ejemplo de `salida_binario.txt`:
```
00000000000100000000000010010011
00000000001000001000000100010011
00000000001000010000001100110011
```

### Asignación de pines

Configurar según la tarjeta FPGA:

- `clk`: Clock del sistema (típicamente 50 MHz)
- `rst_n`: Botón de reset (activo en bajo)
- `switches[1:0]`: Switches para selección de display
- `display[6:0]` a `display5[6:0]`: Displays de 7 segmentos
- `leds[9:0]`: LEDs de salida

## Sistema de visualización

Los switches permiten visualizar diferentes valores en los displays:

- `00`: Program Counter (PC)
- `01`: Valor inmediato
- `10`: Resultado de ALU
- `11`: Contenido del registro rs1

Los 6 displays muestran 24 bits en hexadecimal (6 nibbles).

## Depuración

Para depurar el procesador:

1. Usar los switches para seleccionar qué información ver
2. Observar los displays de 7 segmentos
3. Monitorear los LEDs para valores adicionales
4. Usar herramientas de simulación de Quartus (ModelSim, etc.)

## Detalles técnicos

### Formato de instrucciones RISC-V

**Tipo R:**
```
[31:25] funct7 | [24:20] rs2 | [19:15] rs1 | [14:12] funct3 | [11:7] rd | [6:0] opcode
```

**Tipo I:**
```
[31:20] imm[11:0] | [19:15] rs1 | [14:12] funct3 | [11:7] rd | [6:0] opcode
```

**Tipo S:**
```
[31:25] imm[11:5] | [24:20] rs2 | [19:15] rs1 | [14:12] funct3 | [11:7] imm[4:0] | [6:0] opcode
```

### Opcodes

- `0110011`: Tipo R
- `0010011`: Tipo I (operaciones inmediatas)
- `0000011`: Load
- `0100011`: Store

## Recursos

- [RISC-V Specification](https://riscv.org/technical/specifications/)
- [RISC-V Instruction Set Manual](https://github.com/riscv/riscv-isa-manual)
- [Intel Quartus Prime Documentation](https://www.intel.com/content/www/us/en/programmable/documentation/lit-index.html)
