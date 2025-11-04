# Ensamblador RV32I - Two-Pass Assembler

## Descripción General

Este proyecto implementa un **ensamblador completo de dos pasadas** para el conjunto de instrucciones RISC-V 32-bit Integer (RV32I). El ensamblador traduce código assembly legible por humanos en código máquina binario ejecutable, generando salidas en múltiples formatos para análisis y depuración.

### Características Principales

- ✅ Arquitectura de dos pasadas (two-pass) completa
- ✅ Soporte completo para RV32I base (40+ instrucciones)
- ✅ Expansión automática de 30+ pseudoinstrucciones
- ✅ Manejo de directivas `.text`, `.data`, `.word`
- ✅ Sistema robusto de etiquetas con resolución de referencias forward
- ✅ Registros por número (`x0-x31`) y nombres ABI (`zero, ra, sp, a0-a7`, etc.)
- ✅ Soporte para inmediatos en decimal, hexadecimal (`0x...`) y binario (`0b...`)
- ✅ Tres formatos de salida: `.bin` (binario textual), `.hex` (con direcciones), `.txt` (detallado)
- ✅ Manejo exhaustivo de errores con mensajes descriptivos

---

## Instalación y Uso

### Requisitos

- Python 3.7 o superior
- No requiere librerías externas (solo módulos estándar: `re`, `sys`, `typing`)

### Sintaxis de Uso

```bash
python assembler.py <input.asm> <output.hex> <output.bin>
```

### Ejemplo

```bash
python assembler.py program.asm program.hex program.bin
```

**Archivos generados automáticamente:**
- `program.hex`: Código máquina en hexadecimal con direcciones de memoria
- `program.bin`: Código máquina en binario textual (32 bits por línea)
- `program.txt`: Reporte detallado con assembly, binario y hexadecimal lado a lado

---

## Fundamentos Teóricos

### ¿Qué es un Ensamblador?

Un ensamblador es una herramienta que traduce código assembly (lenguaje de bajo nivel legible para humanos) en código máquina (instrucciones binarias ejecutables por el procesador).

**Ejemplo de traducción:**
```assembly
addi a0, a0, 5    →    0x00550513 (hex)    →    00000000010101010000010100010011 (binario)
```

### Arquitectura de Dos Pasadas (Two-Pass Design)

El diseño de dos pasadas resuelve el problema fundamental de las **referencias forward** (usar una etiqueta antes de definirla):

```assembly
    beq a0, a1, label_adelante  # ❌ ¿Cuál es la dirección de 'label_adelante'?
    addi a0, a0, 1
label_adelante:                  # ✅ Se define aquí
    li a1, 0
```

Sin un diseño de dos pasadas, no podríamos calcular el offset del `beq` porque aún no sabemos dónde está `label_adelante`.

---

## Primera Pasada (First Pass)

### Objetivo
Construir la **tabla de símbolos** (symbol table) que mapea cada etiqueta a su dirección absoluta en memoria.

### Proceso Detallado

```
INICIALIZAR:
    Location Counter (LC) = 0
    Segmento Actual = .text
    Tabla de Símbolos = {}
    
PARA cada línea del archivo:
    1. Parsear línea → (etiqueta, instrucción, operandos)
    
    2. SI hay etiqueta:
        Guardar: etiqueta → LC actual
    
    3. SI es directiva (.text, .data):
        Cambiar segmento actual
        CONTINUAR
    
    4. SI es instrucción o pseudoinstrucción:
        a. Expandir pseudoinstrucciones
        b. Contar cuántas instrucciones reales genera
        c. LC += 4 bytes × número de instrucciones
        
    5. SI es .word en .data:
        a. Contar valores
        b. LC += 4 bytes × número de valores
```

### Ejemplo Práctico

**Código Assembly:**
```assembly
    .text
main:                    # ← Etiqueta: main
    li a0, 100          # Pseudoinstrucción (expande a 1 inst)
    li a1, 0x12345      # Pseudoinstrucción (expande a 2 inst)
    jal sum             # 1 instrucción
loop:                    # ← Etiqueta: loop
    addi a0, a0, -1     # 1 instrucción
    bnez a0, loop       # Pseudoinstrucción (expande a 1 inst)
sum:                     # ← Etiqueta: sum
    ret                 # Pseudoinstrucción (expande a 1 inst)
```

**Tabla de símbolos generada:**
```
main → 0x00000000  (LC = 0 cuando se define)
loop → 0x00000010  (LC = 16 bytes después)
sum  → 0x00000018  (LC = 24 bytes después)
```

**Conteo de bytes:**
```
0x00: main:           (etiqueta, no ocupa espacio)
0x00:   addi a0,x0,100         [li expandida]      → LC = 4
0x04:   lui a1, 0x12            [li expandida pt1]  → LC = 8
0x08:   addi a1,a1,0x345        [li expandida pt2]  → LC = 12
0x0C:   jal ra, sum             [jal]               → LC = 16
0x10: loop:           (etiqueta)
0x10:   addi a0,a0,-1           [addi]              → LC = 20
0x14:   bne a0,x0,loop          [bnez expandida]    → LC = 24
0x18: sum:            (etiqueta)
0x18:   jalr x0,ra,0            [ret expandida]     → LC = 28
```

### Funciones Clave en Primera Pasada

#### `tokenize_line(line: str)`
**Propósito:** Dividir una línea en sus componentes semánticos

**Algoritmo:**
```python
1. Eliminar comentarios (todo después de '#')
2. Buscar etiqueta (texto antes de ':')
3. Extraer instrucción (primera palabra después de etiqueta)
4. Parsear operandos:
   - Separar por comas
   - Respetar paréntesis: "12(sp)" es UN operando
5. Retornar: (etiqueta, instrucción, [operandos])
```

**Ejemplo:**
```python
"loop: addi a0, a0, -1  # decrement" 
  → ("loop", "addi", ["a0", "a0", "-1"])

"sw t0, 8(sp)  # save t0"
  → (None, "sw", ["t0", "8(sp)"])
```

#### `expand_pseudo_instruction(instruction, operands)`
**Propósito:** Expandir pseudoinstrucciones en instrucciones base

**Ejemplos de expansión:**

| Pseudoinstrucción | Expansión | Razón |
|-------------------|-----------|-------|
| `li a0, 100` | `addi a0, x0, 100` | Inmediato cabe en 12 bits |
| `li a0, 0x12345` | `lui a0, 0x12`<br>`addi a0, a0, 0x345` | Inmediato necesita 32 bits |
| `mv a0, a1` | `addi a0, a1, 0` | Copiar = sumar 0 |
| `j label` | `jal x0, label` | Jump sin guardar retorno |
| `ret` | `jalr x0, ra, 0` | Jump a dirección en ra |
| `bgt a0, a1, label` | `blt a1, a0, label` | Mayor = invertir menor |

**Algoritmo para `li` (Load Immediate):**
```python
imm = parse_immediate(operando)

SI -2048 ≤ imm ≤ 2047:
    # Cabe en 12 bits signed
    GENERAR: addi rd, x0, imm
SINO:
    # Necesita 32 bits: usar LUI + ADDI
    upper = (imm + 0x800) >> 12      # Compensar signo
    lower = imm & 0xFFF
    
    SI lower ≥ 0x800:
        lower -= 0x1000               # Convertir a negativo
    
    GENERAR: lui rd, upper
    SI lower ≠ 0:
        GENERAR: addi rd, rd, lower
```

**¿Por qué `+ 0x800`?**
El bit más significativo del inmediato de 12 bits en ADDI es el bit de signo. Si ese bit es 1, el valor se extiende con signo como negativo. Para compensar, ajustamos el valor upper sumando 0x800 antes de dividir.

**Ejemplo numérico:**
```
Cargar: 0x12345678

Sin ajuste:
  upper = 0x12345678 >> 12 = 0x12345
  lower = 0x12345678 & 0xFFF = 0x678
  
  lui rd, 0x12345    → rd = 0x12345000
  addi rd, rd, 0x678 → rd = 0x12345678 ✅

Cargar: 0x12345FFF (bit 11 = 1)

Sin ajuste:
  upper = 0x12345FFF >> 12 = 0x12345
  lower = 0xFFF (se extiende como -1)
  
  lui rd, 0x12345    → rd = 0x12345000
  addi rd, rd, -1    → rd = 0x12344FFF ❌ (incorrecto!)

Con ajuste (+0x800):
  upper = (0x12345FFF + 0x800) >> 12 = 0x12346
  lower = 0xFFF - 0x1000 = -1
  
  lui rd, 0x12346    → rd = 0x12346000
  addi rd, rd, -1    → rd = 0x12345FFF ✅ (correcto!)
```

---

## Segunda Pasada (Second Pass)

### Objetivo
Generar el **código máquina** de 32 bits para cada instrucción, usando la tabla de símbolos para resolver referencias.

### Proceso Detallado

```
INICIALIZAR:
    Dirección Actual = 0
    Código Máquina = []
    
PARA cada línea parseada:
    1. Obtener tipo de instrucción (R/I/S/B/U/J)
    
    2. SEGÚN tipo:
        R-type: encode_r_type()
        I-type: encode_i_type()
        S-type: encode_s_type()
        B-type: encode_b_type()  # Usa dirección actual
        U-type: encode_u_type()
        J-type: encode_j_type()  # Usa dirección actual
    
    3. Agregar palabra de 32 bits a Código Máquina
    
    4. Dirección Actual += 4 bytes
```

---

## Formatos de Instrucción RISC-V

### Formato R (Register-Register)

```
 31      25 24   20 19   15 14    12 11    7 6       0
┌──────────┬───────┬───────┬────────┬───────┬─────────┐
│  funct7  │  rs2  │  rs1  │ funct3 │   rd  │ opcode  │
└──────────┴───────┴───────┴────────┴───────┴─────────┘
   7 bits    5 bits  5 bits  3 bits  5 bits   7 bits
```

**Instrucciones:** `add, sub, and, or, xor, sll, srl, sra, slt, sltu`

**Codificación:**
```python
def encode_r_type(info, [rd, rs1, rs2]):
    return (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | 
           (funct3 << 12) | (rd << 7) | opcode
```

**Ejemplo:** `add a0, a1, a2`
```
rd=a0=10, rs1=a1=11, rs2=a2=12
funct7=0x00, funct3=0x0, opcode=0x33

= 0000000 01100 01011 000 01010 0110011
= 0x00C58533
```

---

### Formato I (Immediate)

```
 31           20 19   15 14    12 11    7 6       0
┌───────────────┬───────┬────────┬───────┬─────────┐
│   imm[11:0]   │  rs1  │ funct3 │   rd  │ opcode  │
└───────────────┴───────┴────────┴───────┴─────────┘
    12 bits       5 bits  3 bits  5 bits   7 bits
```

**Instrucciones:** `addi, xori, ori, andi, slti, sltiu, lb, lh, lw, jalr`

**Casos especiales:**

#### 1. Shifts (slli, srli, srai)
```
 31      25 24   20 19   15 14    12 11    7 6       0
┌──────────┬───────┬───────┬────────┬───────┬─────────┐
│  funct7  │ shamt │  rs1  │ funct3 │   rd  │ opcode  │
└──────────┴───────┴───────┴────────┴───────┴─────────┘
```
- `shamt` (shift amount) solo usa 5 bits (0-31)
- `funct7` distingue shift lógico vs aritmético

#### 2. Loads (lb, lh, lw)
```assembly
lw a0, 12(sp)
```
- `imm` = offset (12)
- `rs1` = registro base (sp)
- `rd` = destino (a0)

#### 3. JALR
```assembly
jalr ra, t0, 8    # ra = PC+4; PC = t0+8
```

**Codificación:**
```python
def encode_i_type(info, operands):
    rd = get_register(operands[0])
    
    SI es shift (slli/srli/srai):
        rs1 = get_register(operands[1])
        shamt = parse_immediate(operands[2])  # 0-31
        imm = (funct7 << 5) | shamt
        
    SI es load (formato offset(reg)):
        offset, rs1 = parse_memory_operand(operands[1])
        imm = offset
        
    SINO:
        rs1 = get_register(operands[1])
        imm = parse_immediate(operands[2])
    
    VALIDAR: -2048 ≤ imm ≤ 2047
    
    return (imm << 20) | (rs1 << 15) | (funct3 << 12) | 
           (rd << 7) | opcode
```

**Ejemplo:** `addi a0, a0, 5`
```
rd=10, rs1=10, imm=5, funct3=0x0, opcode=0x13

= 000000000101 01010 000 01010 0010011
= 0x00550513
```

---

### Formato S (Store)

```
 31      25 24   20 19   15 14    12 11    7 6       0
┌──────────┬───────┬───────┬────────┬───────┬─────────┐
│imm[11:5] │  rs2  │  rs1  │ funct3 │imm[4:0]│ opcode │
└──────────┴───────┴───────┴────────┴───────┴─────────┘
```

**Instrucciones:** `sb, sh, sw`

**Característica clave:** El inmediato se divide en dos partes

**Codificación:**
```python
def encode_s_type(info, [rs2, "offset(rs1)"]):
    offset, rs1 = parse_memory_operand("offset(rs1)")
    
    imm_high = (offset >> 5) & 0x7F    # bits [11:5]
    imm_low = offset & 0x1F             # bits [4:0]
    
    return (imm_high << 25) | (rs2 << 20) | (rs1 << 15) | 
           (funct3 << 12) | (imm_low << 7) | opcode
```

**Ejemplo:** `sw t0, 12(sp)`
```
rs2=t0=5, rs1=sp=2, offset=12
imm[11:5]=0, imm[4:0]=12

= 0000000 00101 00010 010 01100 0100011
= 0x00512623
```

**¿Por qué dividir el inmediato?**
RISC-V mantiene consistencia: `rs1` y `rs2` siempre están en las mismas posiciones en todos los formatos. Esto simplifica el hardware de decodificación.

---

### Formato B (Branch)

```
 31  30      25 24   20 19   15 14    12 11   8 7  6       0
┌───┬──────────┬───────┬───────┬────────┬──────┬─┬─────────┐
│[12]│imm[10:5] │  rs2  │  rs1  │ funct3 │[4:1] │0│ opcode │
└───┴──────────┴───────┴───────┴────────┴──────┴─┴─────────┘
```

**Instrucciones:** `beq, bne, blt, bge, bltu, bgeu`

**Característica clave:** 
- Offset es relativo al PC (PC-relative)
- Offset siempre es par (bit 0 implícito = 0)
- Rango: -4096 a +4094 bytes

**Codificación:**
```python
def encode_b_type(info, [rs1, rs2, label], current_addr):
    target = labels[label]
    offset = target - current_addr
    
    VALIDAR:
        - offset % 2 == 0 (debe ser par)
        - -4096 ≤ offset ≤ 4094
    
    # Reorganizar bits dispersos
    imm_12 = (offset >> 12) & 0x1      # bit [12]
    imm_10_5 = (offset >> 5) & 0x3F    # bits [10:5]
    imm_4_1 = (offset >> 1) & 0xF      # bits [4:1]
    imm_11 = (offset >> 11) & 0x1      # bit [11]
    
    return (imm_12 << 31) | (imm_10_5 << 25) | (rs2 << 20) | 
           (rs1 << 15) | (funct3 << 12) | (imm_4_1 << 8) | 
           (imm_11 << 7) | opcode
```

**Ejemplo:** `beq a0, a1, loop`
```
Supongamos:
  current_addr = 0x10
  loop = 0x04
  offset = 0x04 - 0x10 = -12 = 0xFFF4 (en complemento a 2)

offset en binario: 1111111110100
Bits dispersos:
  [12]   = 1
  [11]   = 1
  [10:5] = 111111
  [4:1]  = 1010
  [0]    = 0 (implícito)

rs1=a0=10, rs2=a1=11, funct3=0x0

= 1 111111 01011 01010 000 1010 0 1100011
= 0xFEB502E3
```

**¿Por qué este orden tan extraño?**
RISC-V diseñó los bits para minimizar el hardware de decodificación. Los bits más significativos del inmediato están cerca del opcode para facilitar la lógica de extensión de signo.

---

### Formato U (Upper Immediate)

```
 31                    12 11    7 6       0
┌─────────────────────────┬───────┬─────────┐
│      imm[31:12]         │   rd  │ opcode  │
└─────────────────────────┴───────┴─────────┘
        20 bits             5 bits   7 bits
```

**Instrucciones:** `lui, auipc`

**Propósito:**
- `lui rd, imm`: Cargar inmediato en bits superiores (rd = imm << 12)
- `auipc rd, imm`: Sumar inmediato al PC (rd = PC + (imm << 12))

**Codificación:**
```python
def encode_u_type(info, [rd, imm]):
    VALIDAR: 0 ≤ imm ≤ 0xFFFFF  # 20 bits sin signo
    
    return (imm << 12) | (rd << 7) | opcode
```

**Ejemplo:** `lui a0, 0x12345`
```
rd=10, imm=0x12345, opcode=0x37

= 00010010001101000101 01010 0110111
= 0x12345537
```

**Uso típico (cargar 32 bits):**
```assembly
lui a0, 0x12345      # a0 = 0x12345000
addi a0, a0, 0x678   # a0 = 0x12345678
```

---

### Formato J (Jump)

```
 31  30       21 20  19         12 11    7 6       0
┌───┬───────────┬──┬─────────────┬───────┬─────────┐
│[20]│imm[10:1]  │[11]│imm[19:12] │   rd  │ opcode  │
└───┴───────────┴──┴─────────────┴───────┴─────────┘
```

**Instrucción:** `jal`

**Característica clave:**
- Offset relativo al PC
- Rango: -1MB a +1MB (-2²⁰ a +2²⁰-2)
- Guarda PC+4 en `rd` (dirección de retorno)

**Codificación:**
```python
def encode_j_type(info, [rd, label], current_addr):
    target = labels[label]
    offset = target - current_addr
    
    VALIDAR:
        - offset % 2 == 0
        - -1048576 ≤ offset ≤ 1048574
    
    # Reorganizar bits dispersos
    imm_20 = (offset >> 20) & 0x1       # bit [20]
    imm_10_1 = (offset >> 1) & 0x3FF    # bits [10:1]
    imm_11 = (offset >> 11) & 0x1       # bit [11]
    imm_19_12 = (offset >> 12) & 0xFF   # bits [19:12]
    
    return (imm_20 << 31) | (imm_19_12 << 12) | 
           (imm_11 << 20) | (imm_10_1 << 21) | 
           (rd << 7) | opcode
```

**Ejemplo:** `jal ra, function`
```
current_addr = 0x100
function = 0x200
offset = 0x200 - 0x100 = 256 = 0x100

offset en binario: 00000000000100000000
Bits dispersos:
  [20]    = 0
  [19:12] = 00000001
  [11]    = 0
  [10:1]  = 0000000000

rd=ra=1

= 0 0000000000 0 00000001 00001 1101111
= 0x100000EF
```

---

## Pseudoinstrucciones Completas

### Tabla Completa con Expansiones

| Pseudo | Operandos | Expansión | Descripción |
|--------|-----------|-----------|-------------|
| **Básicas** |
| `nop` | - | `addi x0, x0, 0` | No operation |
| `mv rd, rs` | 2 | `addi rd, rs, 0` | Copy register |
| `not rd, rs` | 2 | `xori rd, rs, -1` | Bitwise NOT |
| `neg rd, rs` | 2 | `sub rd, x0, rs` | Negate (two's complement) |
| **Set Conditionals** |
| `seqz rd, rs` | 2 | `sltiu rd, rs, 1` | Set if == 0 |
| `snez rd, rs` | 2 | `sltu rd, x0, rs` | Set if != 0 |
| `sltz rd, rs` | 2 | `slt rd, rs, x0` | Set if < 0 |
| `sgtz rd, rs` | 2 | `slt rd, x0, rs` | Set if > 0 |
| **Branches con Zero** |
| `beqz rs, label` | 2 | `beq rs, x0, label` | Branch if == 0 |
| `bnez rs, label` | 2 | `bne rs, x0, label` | Branch if != 0 |
| `blez rs, label` | 2 | `bge x0, rs, label` | Branch if ≤ 0 |
| `bgez rs, label` | 2 | `bge rs, x0, label` | Branch if ≥ 0 |
| `bltz rs, label` | 2 | `blt rs, x0, label` | Branch if < 0 |
| `bgtz rs, label` | 2 | `blt x0, rs, label` | Branch if > 0 |
| **Branches Invertidos** |
| `bgt rs, rt, label` | 3 | `blt rt, rs, label` | Branch if rs > rt |
| `ble rs, rt, label` | 3 | `bge rt, rs, label` | Branch if rs ≤ rt |
| `bgtu rs, rt, label` | 3 | `bltu rt, rs, label` | Branch if rs > rt (unsigned) |
| `bleu rs, rt, label` | 3 | `bgeu rt, rs, label` | Branch if rs ≤ rt (unsigned) |
| **Jumps** |
| `j label` | 1 | `jal x0, label` | Jump |
| `jal label` | 1 | `jal ra, label` | Jump and link |
| `jr rs` | 1 | `jalr x0, rs, 0` | Jump to register |
| `jalr rs` | 1 | `jalr ra, rs, 0` | Jump register and link |
| `ret` | - | `jalr x0, ra, 0` | Return from function |
| **Far Calls** |
| `call label` | 1 | `auipc ra, %hi(label)`<br>`jalr ra, ra, %lo(label)` | Call far function |
| `tail label` | 1 | `auipc t1, %hi(label)`<br>`jalr x0, t1, %lo(label)` | Tail call |
| **Load Immediate/Address** |
| `li rd, imm` | 2 | `addi rd, x0, imm`<br>*o*<br>`lui rd, %hi(imm)`<br>`addi rd, rd, %lo(imm)` | Load 32-bit immediate |
| `la rd, label` | 2 | Similar a `li` | Load address |
| **Global Loads/Stores** |
| `lw rd, symbol` | 2 | `la t0, symbol`<br>`lw rd, 0(t0)` | Load from symbol |
| `sw rs, symbol` | 2 | `la t0, symbol`<br>`sw rs, 0(t0)` | Store to symbol |

---

## Formatos de Salida

### 1. Archivo `.bin` (Binario Textual)

Cada línea contiene 32 bits en formato textual:

```
00000000010101010000010100010011
00000000101100000000010110110111
00000000000000010010010100010011
```

**Características:**
- Un carácter por bit ('0' o '1')
- 32 caracteres por línea
- Fácil de leer para humanos
- Útil para depuración bit a bit

### 2. Archivo `.hex` (Hexadecimal con Direcciones)

Formato: `dirección: código_hex`

```
00000000: 00550513
00000004: 00b00537
00000008: 00250513
0000000c: 008000ef
```

**Características:**
- Dirección en hexadecimal de 8 dígitos
- Código máquina en hexadecimal de 8 dígitos
- Fácil comparación con otros ensambladores
- Compatible con herramientas de análisis

### 3. Archivo `.txt` (Reporte Detallado)

Formato completo con assembly, binario y hexadecimal:

```
RISC-V Assembly to Machine Code
==================================================

Address: 0x00000000
Assembly: addi a0, x0, 100
Binary:   00000000010101010000010100010011
Hex:      00550513
----------------------------------------
Address: 0x00000004
Assembly: lui a1, 0x12
Binary:   00000000101100000000010110110111
Hex:      00012537
----------------------------------------
```

**Características:**
- Correlación completa entre código fuente, binario y hexadecimal
- Útil para verificar codificación paso a paso
- Perfecto para propósitos educativos y debugging

---

## Manejo de Errores

El ensamblador implementa detección exhaustiva de errores con mensajes descriptivos que incluyen número de línea y dirección de memoria.

### Tipos de Errores Detectados

#### 1. **Errores de Sintaxis**
```
Error: Formato de memoria inválido: 12sp
       Esperado: 12(sp)
```

#### 2. **Registro Inválido**
```
Error en línea 5: Registro inválido: q1
Registros válidos: x0-x31, zero, ra, sp, a0-a7, t0-t6, s0-s11
```

#### 3. **Inmediato Fuera de Rango**
```
[L10] Inmediato fuera de rango (-2048..2047): 999999
Instrucción: addi a0, a0, 999999
```

#### 4. **Número Incorrecto de Operandos**
```
[L7] R-type requiere 3 operandos
Encontrado: add a0, a1
Esperado: add a0, a1, a2
```

#### 5. **Etiqueta No Definida**
```
[L15] Label indefinida en branch: undefined_loop
Asegúrese de definir la etiqueta con 'undefined_loop:' antes de usarla
```

#### 6. **Etiqueta Duplicada**
```
[Primera pasada] Línea 20: Label duplicada: 'main'
Primera definición en línea 3
```

#### 7. **Offset de Branch Fuera de Rango**
```
Error en dirección 0x00000100: Offset de branch fuera de rango: 5000
Rango permitido: -4096 a +4094 bytes
Considere usar 'j' (jump) en lugar de branch para distancias largas
```

#### 8. **Operación Inválida en Segmento**
```
[Primera pasada] Línea 12: Operación inválida en .data: 'addi'
Solo se permiten directivas .word en la sección .data
```

---

## Directivas del Ensamblador

### `.text`
**Propósito:** Marca el inicio del segmento de código

**Uso:**
```assembly
    .text
main:
    li a0, 10
    addi a1, a0, 5
```

**Características:**
- Las instrucciones en `.text` comienzan en dirección 0x00000000
- Cada instrucción ocupa 4 bytes
- Es el segmento por defecto si no se especifica

### `.data`
**Propósito:** Marca el inicio del segmento de datos

**Uso:**
```assembly
    .data
array:
    .word 1, 2, 3, 4, 5
constant:
    .word 0x12345678
```

**Características:**
- Los datos en `.data` se colocan después del segmento `.text`
- Dirección inicial = tamaño de `.text`
- Cada `.word` ocupa 4 bytes

### `.word`
**Propósito:** Reserva palabras de 32 bits en el segmento de datos

**Sintaxis:**
```assembly
.word valor1, valor2, valor3, ...
```

**Ejemplos:**
```assembly
    .data
numbers:
    .word 10, 20, 30          # Tres valores literales
hex_value:
    .word 0xDEADBEEF          # Valor hexadecimal
binary_value:
    .word 0b11111111          # Valor binario
label_ref:
    .word main                # Referencia a etiqueta
```

---

## Arquitectura del Código

### Estructura de la Clase `RISCVAssembler`

```python
class RISCVAssembler:
    # Tablas de configuración
    registers: Dict[str, int]           # x0-x31 + nombres ABI
    instructions: Dict[str, Dict]       # Especificaciones de instrucciones
    pseudo_instructions: Set[str]       # Lista de pseudos
    
    # Tablas de símbolos
    label_positions: Dict[str, Tuple]   # (segmento, offset)
    labels: Dict[str, int]              # label → dirección absoluta
    
    # Estado del ensamblador
    parsed_lines: List[Tuple]           # Líneas parseadas
    current_segment: str                # 'text' o 'data'
    text_size: int                      # Tamaño del segmento .text
    data_size: int                      # Tamaño del segmento .data
```

### Flujo de Ejecución Completo

```
main()
  ↓
assemble_file(input, hex_out, bin_out)
  ↓
  ├─→ first_pass(lines)
  │     ↓
  │     ├─→ tokenize_line() para cada línea
  │     ├─→ expand_pseudo_instruction() si es pseudo
  │     ├─→ Actualizar Location Counter (LC)
  │     └─→ Construir label_positions y labels
  │
  ├─→ second_pass()
  │     ↓
  │     └─→ Para cada línea parseada:
  │           ├─→ encode_r_type()
  │           ├─→ encode_i_type()
  │           ├─→ encode_s_type()
  │           ├─→ encode_b_type()
  │           ├─→ encode_u_type()
  │           └─→ encode_j_type()
  │
  └─→ Escribir archivos de salida:
        ├─→ .bin (binario textual)
        ├─→ .hex (con direcciones)
        └─→ .txt (reporte detallado)
```

---

## Funciones Clave Explicadas

### `parse_immediate(s: str) -> int`

**Propósito:** Convertir strings de números en enteros

**Algoritmo:**
```python
1. SI empieza con '-0x': negativo hexadecimal
   → -int(s[3:], 16)
   
2. SI empieza con '0x': hexadecimal
   → int(s, 16)
   
3. SI empieza con '0b': binario
   → int(s, 2)
   
4. SINO: decimal
   → int(s, 0)
```

**Ejemplos:**
```python
parse_immediate("42")       → 42
parse_immediate("0xFF")     → 255
parse_immediate("-0x10")    → -16
parse_immediate("0b1010")   → 10
```

### `parse_memory_operand(operand: str) -> Tuple[int, int]`

**Propósito:** Analizar operandos tipo `offset(registro)`

**Regex:** `^([-\w+]+)\((\w+)\)# Ensamblador RV32I - Two-Pass Assembler

## Descripción General

Este proyecto implementa un **ensamblador completo de dos pasadas** para el conjunto de instrucciones RISC-V 32-bit Integer (RV32I). El ensamblador traduce código assembly legible por humanos en código máquina binario ejecutable, generando salidas en múltiples formatos para análisis y depuración.

### Características Principales

- ✅ Arquitectura de dos pasadas (two-pass) completa
- ✅ Soporte completo para RV32I base (40+ instrucciones)
- ✅ Expansión automática de 30+ pseudoinstrucciones
- ✅ Manejo de directivas `.text`, `.data`, `.word`
- ✅ Sistema robusto de etiquetas con resolución de referencias forward
- ✅ Registros por número (`x0-x31`) y nombres ABI (`zero, ra, sp, a0-a7`, etc.)
- ✅ Soporte para inmediatos en decimal, hexadecimal (`0x...`) y binario (`0b...`)
- ✅ Tres formatos de salida: `.bin` (binario textual), `.hex` (con direcciones), `.txt` (detallado)
- ✅ Manejo exhaustivo de errores con mensajes descriptivos

---

## Instalación y Uso

### Requisitos

- Python 3.7 o superior
- No requiere librerías externas (solo módulos estándar: `re`, `sys`, `typing`)

### Sintaxis de Uso

```bash
python assembler.py <input.asm> <output.hex> <output.bin>
```

### Ejemplo

```bash
python assembler.py program.asm program.hex program.bin
```

**Archivos generados automáticamente:**
- `program.hex`: Código máquina en hexadecimal con direcciones de memoria
- `program.bin`: Código máquina en binario textual (32 bits por línea)
- `program.txt`: Reporte detallado con assembly, binario y hexadecimal lado a lado

---

## Fundamentos Teóricos

### ¿Qué es un Ensamblador?

Un ensamblador es una herramienta que traduce código assembly (lenguaje de bajo nivel legible para humanos) en código máquina (instrucciones binarias ejecutables por el procesador).

**Ejemplo de traducción:**
```assembly
addi a0, a0, 5    →    0x00550513 (hex)    →    00000000010101010000010100010011 (binario)
```

### Arquitectura de Dos Pasadas (Two-Pass Design)

El diseño de dos pasadas resuelve el problema fundamental de las **referencias forward** (usar una etiqueta antes de definirla):

```assembly
    beq a0, a1, label_adelante  # ❌ ¿Cuál es la dirección de 'label_adelante'?
    addi a0, a0, 1
label_adelante:                  # ✅ Se define aquí
    li a1, 0
```

Sin un diseño de dos pasadas, no podríamos calcular el offset del `beq` porque aún no sabemos dónde está `label_adelante`.

---

## Primera Pasada (First Pass)

### Objetivo
Construir la **tabla de símbolos** (symbol table) que mapea cada etiqueta a su dirección absoluta en memoria.

### Proceso Detallado

```
INICIALIZAR:
    Location Counter (LC) = 0
    Segmento Actual = .text
    Tabla de Símbolos = {}
    
PARA cada línea del archivo:
    1. Parsear línea → (etiqueta, instrucción, operandos)
    
    2. SI hay etiqueta:
        Guardar: etiqueta → LC actual
    
    3. SI es directiva (.text, .data):
        Cambiar segmento actual
        CONTINUAR
    
    4. SI es instrucción o pseudoinstrucción:
        a. Expandir pseudoinstrucciones
        b. Contar cuántas instrucciones reales genera
        c. LC += 4 bytes × número de instrucciones
        
    5. SI es .word en .data:
        a. Contar valores
        b. LC += 4 bytes × número de valores
```

### Ejemplo Práctico

**Código Assembly:**
```assembly
    .text
main:                    # ← Etiqueta: main
    li a0, 100          # Pseudoinstrucción (expande a 1 inst)
    li a1, 0x12345      # Pseudoinstrucción (expande a 2 inst)
    jal sum             # 1 instrucción
loop:                    # ← Etiqueta: loop
    addi a0, a0, -1     # 1 instrucción
    bnez a0, loop       # Pseudoinstrucción (expande a 1 inst)
sum:                     # ← Etiqueta: sum
    ret                 # Pseudoinstrucción (expande a 1 inst)
```

**Tabla de símbolos generada:**
```
main → 0x00000000  (LC = 0 cuando se define)
loop → 0x00000010  (LC = 16 bytes después)
sum  → 0x00000018  (LC = 24 bytes después)
```

**Conteo de bytes:**
```
0x00: main:           (etiqueta, no ocupa espacio)
0x00:   addi a0,x0,100         [li expandida]      → LC = 4
0x04:   lui a1, 0x12            [li expandida pt1]  → LC = 8
0x08:   addi a1,a1,0x345        [li expandida pt2]  → LC = 12
0x0C:   jal ra, sum             [jal]               → LC = 16
0x10: loop:           (etiqueta)
0x10:   addi a0,a0,-1           [addi]              → LC = 20
0x14:   bne a0,x0,loop          [bnez expandida]    → LC = 24
0x18: sum:            (etiqueta)
0x18:   jalr x0,ra,0            [ret expandida]     → LC = 28
```

### Funciones Clave en Primera Pasada

#### `tokenize_line(line: str)`
**Propósito:** Dividir una línea en sus componentes semánticos

**Algoritmo:**
```python
1. Eliminar comentarios (todo después de '#')
2. Buscar etiqueta (texto antes de ':')
3. Extraer instrucción (primera palabra después de etiqueta)
4. Parsear operandos:
   - Separar por comas
   - Respetar paréntesis: "12(sp)" es UN operando
5. Retornar: (etiqueta, instrucción, [operandos])
```

**Ejemplo:**
```python
"loop: addi a0, a0, -1  # decrement" 
  → ("loop", "addi", ["a0", "a0", "-1"])

"sw t0, 8(sp)  # save t0"
  → (None, "sw", ["t0", "8(sp)"])
```

#### `expand_pseudo_instruction(instruction, operands)`
**Propósito:** Expandir pseudoinstrucciones en instrucciones base

**Ejemplos de expansión:**

| Pseudoinstrucción | Expansión | Razón |
|-------------------|-----------|-------|
| `li a0, 100` | `addi a0, x0, 100` | Inmediato cabe en 12 bits |
| `li a0, 0x12345` | `lui a0, 0x12`<br>`addi a0, a0, 0x345` | Inmediato necesita 32 bits |
| `mv a0, a1` | `addi a0, a1, 0` | Copiar = sumar 0 |
| `j label` | `jal x0, label` | Jump sin guardar retorno |
| `ret` | `jalr x0, ra, 0` | Jump a dirección en ra |
| `bgt a0, a1, label` | `blt a1, a0, label` | Mayor = invertir menor |

**Algoritmo para `li` (Load Immediate):**
```python
imm = parse_immediate(operando)

SI -2048 ≤ imm ≤ 2047:
    # Cabe en 12 bits signed
    GENERAR: addi rd, x0, imm
SINO:
    # Necesita 32 bits: usar LUI + ADDI
    upper = (imm + 0x800) >> 12      # Compensar signo
    lower = imm & 0xFFF
    
    SI lower ≥ 0x800:
        lower -= 0x1000               # Convertir a negativo
    
    GENERAR: lui rd, upper
    SI lower ≠ 0:
        GENERAR: addi rd, rd, lower
```

**¿Por qué `+ 0x800`?**
El bit más significativo del inmediato de 12 bits en ADDI es el bit de signo. Si ese bit es 1, el valor se extiende con signo como negativo. Para compensar, ajustamos el valor upper sumando 0x800 antes de dividir.

**Ejemplo numérico:**
```
Cargar: 0x12345678

Sin ajuste:
  upper = 0x12345678 >> 12 = 0x12345
  lower = 0x12345678 & 0xFFF = 0x678
  
  lui rd, 0x12345    → rd = 0x12345000
  addi rd, rd, 0x678 → rd = 0x12345678 ✅

Cargar: 0x12345FFF (bit 11 = 1)

Sin ajuste:
  upper = 0x12345FFF >> 12 = 0x12345
  lower = 0xFFF (se extiende como -1)
  
  lui rd, 0x12345    → rd = 0x12345000
  addi rd, rd, -1    → rd = 0x12344FFF ❌ (incorrecto!)

Con ajuste (+0x800):
  upper = (0x12345FFF + 0x800) >> 12 = 0x12346
  lower = 0xFFF - 0x1000 = -1
  
  lui rd, 0x12346    → rd = 0x12346000
  addi rd, rd, -1    → rd = 0x12345FFF ✅ (correcto!)
```

---

## Segunda Pasada (Second Pass)

### Objetivo
Generar el **código máquina** de 32 bits para cada instrucción, usando la tabla de símbolos para resolver referencias.

### Proceso Detallado

```
INICIALIZAR:
    Dirección Actual = 0
    Código Máquina = []
    
PARA cada línea parseada:
    1. Obtener tipo de instrucción (R/I/S/B/U/J)
    
    2. SEGÚN tipo:
        R-type: encode_r_type()
        I-type: encode_i_type()
        S-type: encode_s_type()
        B-type: encode_b_type()  # Usa dirección actual
        U-type: encode_u_type()
        J-type: encode_j_type()  # Usa dirección actual
    
    3. Agregar palabra de 32 bits a Código Máquina
    
    4. Dirección Actual += 4 bytes
```

---

## Formatos de Instrucción RISC-V

### Formato R (Register-Register)

```
 31      25 24   20 19   15 14    12 11    7 6       0
┌──────────┬───────┬───────┬────────┬───────┬─────────┐
│  funct7  │  rs2  │  rs1  │ funct3 │   rd  │ opcode  │
└──────────┴───────┴───────┴────────┴───────┴─────────┘
   7 bits    5 bits  5 bits  3 bits  5 bits   7 bits
```

**Instrucciones:** `add, sub, and, or, xor, sll, srl, sra, slt, sltu`

**Codificación:**
```python
def encode_r_type(info, [rd, rs1, rs2]):
    return (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | 
           (funct3 << 12) | (rd << 7) | opcode
```

**Ejemplo:** `add a0, a1, a2`
```
rd=a0=10, rs1=a1=11, rs2=a2=12
funct7=0x00, funct3=0x0, opcode=0x33

= 0000000 01100 01011 000 01010 0110011
= 0x00C58533
```

---

### Formato I (Immediate)

```
 31           20 19   15 14    12 11    7 6       0
┌───────────────┬───────┬────────┬───────┬─────────┐
│   imm[11:0]   │  rs1  │ funct3 │   rd  │ opcode  │
└───────────────┴───────┴────────┴───────┴─────────┘
    12 bits       5 bits  3 bits  5 bits   7 bits
```

**Instrucciones:** `addi, xori, ori, andi, slti, sltiu, lb, lh, lw, jalr`

**Casos especiales:**

#### 1. Shifts (slli, srli, srai)
```
 31      25 24   20 19   15 14    12 11    7 6       0
┌──────────┬───────┬───────┬────────┬───────┬─────────┐
│  funct7  │ shamt │  rs1  │ funct3 │   rd  │ opcode  │
└──────────┴───────┴───────┴────────┴───────┴─────────┘
```
- `shamt` (shift amount) solo usa 5 bits (0-31)
- `funct7` distingue shift lógico vs aritmético

#### 2. Loads (lb, lh, lw)
```assembly
lw a0, 12(sp)
```
- `imm` = offset (12)
- `rs1` = registro base (sp)
- `rd` = destino (a0)

#### 3. JALR
```assembly
jalr ra, t0, 8    # ra = PC+4; PC = t0+8
```

**Codificación:**
```python
def encode_i_type(info, operands):
    rd = get_register(operands[0])
    
    SI es shift (slli/srli/srai):
        rs1 = get_register(operands[1])
        shamt = parse_immediate(operands[2])  # 0-31
        imm = (funct7 << 5) | shamt
        
    SI es load (formato offset(reg)):
        offset, rs1 = parse_memory_operand(operands[1])
        imm = offset
        
    SINO:
        rs1 = get_register(operands[1])
        imm = parse_immediate(operands[2])
    
    VALIDAR: -2048 ≤ imm ≤ 2047
    
    return (imm << 20) | (rs1 << 15) | (funct3 << 12) | 
           (rd << 7) | opcode
```

**Ejemplo:** `addi a0, a0, 5`
```
rd=10, rs1=10, imm=5, funct3=0x0, opcode=0x13

= 000000000101 01010 000 01010 0010011
= 0x00550513
```

---

### Formato S (Store)

```
 31      25 24   20 19   15 14    12 11    7 6       0
┌──────────┬───────┬───────┬────────┬───────┬─────────┐
│imm[11:5] │  rs2  │  rs1  │ funct3 │imm[4:0]│ opcode │
└──────────┴───────┴───────┴────────┴───────┴─────────┘
```

**Instrucciones:** `sb, sh, sw`

**Característica clave:** El inmediato se divide en dos partes

**Codificación:**
```python
def encode_s_type(info, [rs2, "offset(rs1)"]):
    offset, rs1 = parse_memory_operand("offset(rs1)")
    
    imm_high = (offset >> 5) & 0x7F    # bits [11:5]
    imm_low = offset & 0x1F             # bits [4:0]
    
    return (imm_high << 25) | (rs2 << 20) | (rs1 << 15) | 
           (funct3 << 12) | (imm_low << 7) | opcode
```

**Ejemplo:** `sw t0, 12(sp)`
```
rs2=t0=5, rs1=sp=2, offset=12
imm[11:5]=0, imm[4:0]=12

= 0000000 00101 00010 010 01100 0100011
= 0x00512623
```

**¿Por qué dividir el inmediato?**
RISC-V mantiene consistencia: `rs1` y `rs2` siempre están en las mismas posiciones en todos los formatos. Esto simplifica el hardware de decodificación.

---

### Formato B (Branch)

```
 31  30      25 24   20 19   15 14    12 11   8 7  6       0
┌───┬──────────┬───────┬───────┬────────┬──────┬─┬─────────┐
│[12]│imm[10:5] │  rs2  │  rs1  │ funct3 │[4:1] │0│ opcode │
└───┴──────────┴───────┴───────┴────────┴──────┴─┴─────────┘
```

**Instrucciones:** `beq, bne, blt, bge, bltu, bgeu`

**Característica clave:** 
- Offset es relativo al PC (PC-relative)
- Offset siempre es par (bit 0 implícito = 0)
- Rango: -4096 a +4094 bytes

**Codificación:**
```python
def encode_b_type(info, [rs1, rs2, label], current_addr):
    target = labels[label]
    offset = target - current_addr
    
    VALIDAR:
        - offset % 2 == 0 (debe ser par)
        - -4096 ≤ offset ≤ 4094
    
    # Reorganizar bits dispersos
    imm_12 = (offset >> 12) & 0x1      # bit [12]
    imm_10_5 = (offset >> 5) & 0x3F    # bits [10:5]
    imm_4_1 = (offset >> 1) & 0xF      # bits [4:1]
    imm_11 = (offset >> 11) & 0x1      # bit [11]
    
    return (imm_12 << 31) | (imm_10_5 << 25) | (rs2 << 20) | 
           (rs1 << 15) | (funct3 << 12) | (imm_4_1 << 8) | 
           (imm_11 << 7) | opcode
```

**Ejemplo:** `beq a0, a1, loop`
```
Supongamos:
  current_addr = 0x10
  loop = 0x04
  offset = 0x04 - 0x10 = -12 = 0xFFF4 (en complemento a 2)

offset en binario: 1111111110100
Bits dispersos:
  [12]   = 1
  [11]   = 1
  [10:5] = 111111
  [4:1]  = 1010
  [0]    = 0 (implícito)

rs1=a0=10, rs2=a1=11, funct3=0x0

= 1 111111 01011 01010 000 1010 0 1100011
= 0xFEB502E3
```

**¿Por qué este orden tan extraño?**
RISC-V diseñó los bits para minimizar el hardware de decodificación. Los bits más significativos del inmediato están cerca del opcode para facilitar la lógica de extensión de signo.

---

### Formato U (Upper Immediate)

```
 31                    12 11    7 6       0
┌─────────────────────────┬───────┬─────────┐
│      imm[31:12]         │   rd  │ opcode  │
└─────────────────────────┴───────┴─────────┘
        20 bits             5 bits   7 bits
```

**Instrucciones:** `lui, auipc`

**Propósito:**
- `lui rd, imm`: Cargar inmediato en bits superiores (rd = imm << 12)
- `auipc rd, imm`: Sumar inmediato al PC (rd = PC + (imm << 12))

**Codificación:**
```python
def encode_u_type(info, [rd, imm]):
    VALIDAR: 0 ≤ imm ≤ 0xFFFFF  # 20 bits sin signo
    
    return (imm << 12) | (rd << 7) | opcode
```

**Ejemplo:** `lui a0, 0x12345`
```
rd=10, imm=0x12345, opcode=0x37

= 00010010001101000101 01010 0110111
= 0x12345537
```

**Uso típico (cargar 32 bits):**
```assembly
lui a0, 0x12345      # a0 = 0x12345000
addi a0, a0, 0x678   # a0 = 0x12345678
```

---

### Formato J (Jump)

```
 31  30       21 20  19         12 11    7 6       0
┌───┬───────────┬──┬─────────────┬───────┬─────────┐
│[20]│imm[10:1]  │[11]│imm[19:12] │   rd  │ opcode  │
└───┴───────────┴──┴─────────────┴───────┴─────────┘
```

**Instrucción:** `jal`

**Característica clave:**
- Offset relativo al PC
- Rango: -1MB a +1MB (-2²⁰ a +2²⁰-2)
- Guarda PC+4 en `rd` (dirección de retorno)

**Codificación:**
```python
def encode_j_type(info, [rd, label], current_addr):
    target = labels[label]
    offset = target - current_addr
    
    VALIDAR:
        - offset % 2 == 0
        - -1048576 ≤ offset ≤ 1048574
    
    # Reorganizar bits dispersos
    imm_20 = (offset >> 20) & 0x1       # bit [20]
    imm_10_1 = (offset >> 1) & 0x3FF    # bits [10:1]
    imm_11 = (offset >> 11) & 0x1       # bit [11]
    imm_19_12 = (offset >> 12) & 0xFF   # bits [19:12]
    
    return (imm_20 << 31) | (imm_19_12 << 12) | 
           (imm_11 << 20) | (imm_10_1 << 21) | 
           (rd << 7) | opcode
```

**Ejemplo:** `jal ra, function`
```
current_addr = 0x100
function = 0x200
offset = 0x200 - 0x100 = 256 = 0x100

offset en binario: 00000000000100000000
Bits dispersos:
  [20]    = 0
  [19:12] = 00000001
  [11]    = 0
  [10:1]  = 0000000000

rd=ra=1

= 0 0000000000 0 00000001 00001 1101111
= 0x100000EF
```

---

## Pseudoinstrucciones Completas

### Tabla Completa con Expansiones

| Pseudo | Operandos | Expansión | Descripción |
|--------|-----------|-----------|-------------|
| **Básicas** |
| `nop` | - | `addi x0, x0, 0` | No operation |
| `mv rd, rs` | 2 | `addi rd, rs, 0` | Copy register |
| `not rd, rs` | 2 | `xori rd, rs, -1` | Bitwise NOT |
| `neg rd, rs` | 2 | `sub rd, x0, rs` | Negate (two's complement) |
| **Set Conditionals** |
| `seqz rd, rs` | 2 | `sltiu rd, rs, 1` | Set if == 0 |
| `snez rd, rs` | 2 | `sltu rd, x0, rs` | Set if != 0 |
| `sltz rd, rs` | 2 | `slt rd, rs, x0` | Set if < 0 |
| `sgtz rd, rs` | 2 | `slt rd, x0, rs` | Set if > 0 |
| **Branches con Zero** |
| `beqz rs, label` | 2 | `beq rs, x0, label` | Branch if == 0 |
| `bnez rs, label` | 2 | `bne rs, x0, label` | Branch if != 0 |
| `blez rs, label` | 2 | `bge x0, rs, label` | Branch if ≤ 0 |
| `bgez rs, label` | 2 | `bge rs, x0, label` | Branch if ≥ 0 |
| `bltz rs, label` | 2 | `blt rs, x0, label` | Branch if < 0 |
| `bgtz rs, label` | 2 | `blt x0, rs, label` | Branch if > 0 |
| **Branches Invertidos** |
| `bgt rs, rt, label` | 3 | `blt rt, rs, label` | Branch if rs > rt |
| `ble rs, rt, label` | 3 | `bge rt, rs, label` | Branch if rs ≤ rt |
| `bgtu rs, rt, label` | 3 | `bltu rt, rs, label` | Branch if rs > rt (unsigned) |
| `bleu rs, rt, label` | 3 | `bgeu rt, rs, label` | Branch if rs ≤ rt (unsigned) |
| **Jumps** |
| `j label` | 1 | `jal x0, label` | Jump |
| `jal label` | 1 | `jal ra, label` | Jump and link |
| `jr rs` | 1 | `jalr x0, rs, 0` | Jump to register |
| `jalr rs` | 1 | `jalr ra, rs, 0` | Jump register and link |
| `ret` | - | `jalr x0, ra, 0` | Return from function |
| **Far Calls** |
| `call label` | 1 | `auipc ra, %hi(label)`<br>`jalr ra, ra, %lo(label)` | Call far function |
| `tail label` | 1 | `auipc t1, %hi(label)`<br>`jalr x0, t1, %lo(label)` | Tail call |
| **Load Immediate/Address** |
| `li rd, imm` | 2 | `addi rd, x0, imm`<br>*o*<br>`lui rd, %hi(imm)`<br>`addi rd, rd, %lo(imm)` | Load 32-bit immediate |
| `la rd, label` | 2 | Similar a `li` | Load address |
| **Global Loads/Stores** |
| `lw rd, symbol` | 2 | `la t0, symbol`<br>`lw rd, 0(t0)` | Load from symbol |
| `sw rs, symbol` | 2 | `la t0, symbol`<br>`sw rs, 0(t0)` | Store to symbol |

---

## Formatos de Salida

### 1. Archivo `.bin` (Binario Textual)

Cada línea contiene 32 bits en formato textual:

```
00000000010101010000010100010011
00000000101100000000010110110111
00000000000000010010010100010011
```

**Características:**
- Un carácter por bit ('0' o '1')
- 32 caracteres por línea
- Fácil de leer para humanos
- Útil para depuración bit a bit

### 2. Archivo `.hex` (Hexadecimal con Direcciones)

Formato: `dirección: código_hex`

```
00000000: 00550513
00000004: 00b00537
00000008: 00250513
0000000c: 008000ef
```

**Características:**
- Dirección en hexadecimal de 8 dígitos
- Código máquina en hexadecimal de 8 dígitos
- Fácil comparación con otros ensambladores
- Compatible con herramientas de análisis

### 3. Archivo `.txt` (Reporte Detallado)

Formato completo con assembly, binario y hexadecimal:

```
RISC-V Assembly to Machine Code
==================================================

Address: 0x00000000
Assembly: addi a0, x0, 100
Binary:   00000000010101010000010100010011
Hex:      00550513
----------------------------------------
Address: 0x00000004
Assembly: lui a1, 0x12
Binary:   00000000101100000000010110110111
Hex:      00012537
----------------------------------------
```



**Algoritmo:**
```python
1. Extraer offset_str y reg_str usando regex
2. Intentar parsear offset_str como número
3. SI falla:
   a. Buscar en tabla de labels (ya resuelta)
   b. SI no existe: usar 0 como placeholder
4. Obtener número de registro para reg_str
5. Retornar (offset, registro)
```

**Ejemplos:**
```python
"12(sp)"      → (12, 2)     # offset literal
"label(x0)"   → (addr, 0)   # offset desde label
"-8(s0)"      → (-8, 8)     # offset negativo
```

### `expand_pseudo_instruction()` - Casos Especiales

#### Caso: `call` y `tail`

Estas pseudoinstrucciones permiten llamadas a funciones más allá del rango de `jal` (±1MB):

```assembly
call function
```

**Expansión:**
```assembly
auipc ra, %pcrel_hi(function)    # ra = PC + (upper << 12)
jalr ra, ra, %pcrel_lo(function)  # ra_new = PC+4; PC = ra + lower
```

**¿Cómo funciona?**
1. `auipc` suma el PC actual con los 20 bits superiores del offset
2. `jalr` suma los 12 bits inferiores y salta
3. Juntos pueden alcanzar ±2GB (todo el espacio de direcciones)

**Implementación en el código:**
```python
elif instruction == 'call':
    label = operands[0]
    out.append(('auipc', ['ra', label]))
    out.append(('jalr', ['ra', 'ra', label]))
```

En segunda pasada, el encoder U-type detecta que el operando es una etiqueta y calcula automáticamente los bits upper/lower.

#### Caso: `lw rd, symbol` (Load Global)

```assembly
lw a0, data_value
```

**Expansión:**
```assembly
la t0, data_value    # Cargar dirección de data_value
lw a0, 0(t0)         # Cargar desde esa dirección
```

**Implementación:**
```python
elif instruction in ('lb','lh','lw') and len(operands)==2 and '(' not in operands[1]:
    rd, sym = operands[0], operands[1]
    # Expandir 'la t0, sym'
    out.extend(self.expand_pseudo_instruction('la', ['t0', sym]))
    # Agregar load real
    out.append((instruction, [rd, '0(t0)']))
```

---

## Ejemplo Completo Paso a Paso

### Código Assembly Fuente

```assembly
    .text
main:
    li a0, 0x1000       # Pseudoinstrucción: cargar inmediato grande
    li a1, 10           # Pseudoinstrucción: cargar inmediato pequeño
    call sum            # Pseudoinstrucción: far call
    j end               # Pseudoinstrucción: jump

sum:
    add a2, a0, a1      # Instrucción real R-type
    mv a0, a2           # Pseudoinstrucción: move
    ret                 # Pseudoinstrucción: return

end:
    nop                 # Pseudoinstrucción: no operation
    
    .data
result:
    .word 0, 0, 0       # Reservar 3 palabras
```

### Primera Pasada - Construcción de Tabla de Símbolos

**Iteración línea por línea:**

```
Línea 2: "main:"
  → label_positions['main'] = ('text', 0)
  → LC_text = 0

Línea 3: "li a0, 0x1000"
  → Es pseudo, expandir:
     - lui a0, 0x1        [4 bytes]
     - addi a0, a0, 0     [4 bytes]
  → LC_text += 8

Línea 4: "li a1, 10"
  → Es pseudo, expandir:
     - addi a1, x0, 10    [4 bytes]
  → LC_text += 4

Línea 5: "call sum"
  → Es pseudo, expandir:
     - auipc ra, sum      [4 bytes]
     - jalr ra, ra, sum   [4 bytes]
  → LC_text += 8

Línea 6: "j end"
  → Es pseudo, expandir:
     - jal x0, end        [4 bytes]
  → LC_text += 4

Línea 8: "sum:"
  → label_positions['sum'] = ('text', 24)
  → LC_text = 24

Línea 9: "add a2, a0, a1"
  → Instrucción real R-type [4 bytes]
  → LC_text += 4

Línea 10: "mv a0, a2"
  → Es pseudo, expandir:
     - addi a0, a2, 0     [4 bytes]
  → LC_text += 4

Línea 11: "ret"
  → Es pseudo, expandir:
     - jalr x0, ra, 0     [4 bytes]
  → LC_text += 4

Línea 13: "end:"
  → label_positions['end'] = ('text', 36)
  → LC_text = 36

Línea 14: "nop"
  → Es pseudo, expandir:
     - addi x0, x0, 0     [4 bytes]
  → LC_text += 4

Línea 17: "result:"
  → label_positions['result'] = ('data', 0)
  → LC_data = 0

Línea 18: ".word 0, 0, 0"
  → Reservar 3 palabras [12 bytes]
  → LC_data += 12
```

**Tabla de símbolos final:**
```
main   → 0x00000000  (text segment)
sum    → 0x00000018  (text segment)
end    → 0x00000024  (text segment)
result → 0x00000028  (data segment: 0x28 = text_size + 0)
```

### Segunda Pasada - Generación de Código Máquina

```
Dirección 0x00: lui a0, 0x1
  → U-type: rd=10, imm=0x1, opcode=0x37
  → 0x00001537

Dirección 0x04: addi a0, a0, 0
  → I-type: rd=10, rs1=10, imm=0, funct3=0x0, opcode=0x13
  → 0x00050513

Dirección 0x08: addi a1, x0, 10
  → I-type: rd=11, rs1=0, imm=10, funct3=0x0, opcode=0x13
  → 0x00A00593

Dirección 0x0C: auipc ra, sum
  → Calcular offset relativo: sum(0x18) - PC(0x0C) = 0x0C
  → upper = (0x0C + 0x800) >> 12 = 0
  → U-type: rd=1, imm=0, opcode=0x17
  → 0x00000097

Dirección 0x10: jalr ra, ra, sum
  → lower = 0x0C & 0xFFF = 0x00C
  → I-type: rd=1, rs1=1, imm=0x00C, funct3=0x0, opcode=0x67
  → 0x00C08067

Dirección 0x14: jal x0, end
  → Calcular offset: end(0x24) - PC(0x14) = 0x10
  → J-type: rd=0, offset=0x10, opcode=0x6F
  → 0x0100006F

Dirección 0x18: add a2, a0, a1
  → R-type: rd=12, rs1=10, rs2=11, funct3=0x0, funct7=0x00
  → 0x00B50633

Dirección 0x1C: addi a0, a2, 0
  → I-type: rd=10, rs1=12, imm=0, funct3=0x0, opcode=0x13
  → 0x00060513

Dirección 0x20: jalr x0, ra, 0
  → I-type: rd=0, rs1=1, imm=0, funct3=0x0, opcode=0x67
  → 0x00008067

Dirección 0x24: addi x0, x0, 0
  → I-type: rd=0, rs1=0, imm=0, funct3=0x0, opcode=0x13
  → 0x00000013

Data segment:
Dirección 0x28: .word 0 → 0x00000000
Dirección 0x2C: .word 0 → 0x00000000
Dirección 0x30: .word 0 → 0x00000000
```

### Archivos de Salida

**program.hex:**
```
00000000: 00001537
00000004: 00050513
00000008: 00a00593
0000000c: 00000097
00000010: 00c08067
00000014: 0100006f
00000018: 00b50633
0000001c: 00060513
00000020: 00008067
00000024: 00000013
00000028: 00000000
0000002c: 00000000
00000030: 00000000
```

**program.bin:**
```
00000000000000010101001100110111
00000000000001010000010100010011
00000000101000000000010110010011
00000000000000000000000010010111
00001100000000001000000001100111
00000001000000000000000001101111
00000000101101010000011000110011
00000000000001100000010100010011
00000000000000001000000001100111
00000000000000000000000000010011
00000000000000000000000000000000
00000000000000000000000000000000
00000000000000000000000000000000
```

---

## Casos de Prueba

### Test 1: Instrucciones Básicas

```assembly
    .text
main:
    add a0, a1, a2    # R-type
    addi a0, a0, 100  # I-type
    sw a0, 0(sp)      # S-type
    beq a0, a1, main  # B-type
    lui a0, 0x12345   # U-type
    jal ra, main      # J-type
```

### Test 2: Todas las Pseudoinstrucciones

```assembly
    .text
    nop
    mv a0, a1
    not a0, a1
    neg a0, a1
    seqz a0, a1
    snez a0, a1
    sltz a0, a1
    sgtz a0, a1
    beqz a0, label
    bnez a0, label
    blez a0, label
    bgez a0, label
    bltz a0, label
    bgtz a0, label
    bgt a0, a1, label
    ble a0, a1, label
    bgtu a0, a1, label
    bleu a0, a1, label
    j label
    jr a0
    ret
    call function
    tail function
    li a0, 0x12345678
    la a0, data_label
label:
    nop
function:
    ret
```

### Test 3: Segmento de Datos

```assembly
    .data
array:
    .word 1, 2, 3, 4, 5
hex_val:
    .word 0xDEADBEEF
bin_val:
    .word 0b11111111
    
    .text
main:
    la a0, array
    lw a1, 0(a0)
```

---

## Comparación con Otros Ensambladores

### GNU RISC-V Assembler

```bash
# Compilar con GCC
riscv32-unknown-elf-as program.asm -o program.o
riscv32-unknown-elf-objdump -d program.o > program.dump

# Comparar salidas
diff program.hex program.dump
```

### RARS (RISC-V Assembler and Runtime Simulator)

Compatible con RARS para verificación de código.

---

## Limitaciones Conocidas

1. **No soporta macros**: No hay expansión de macros definidas por el usuario
2. **Sin optimización**: No optimiza código generado
3. **Segmento único de datos**: `.data` y `.text` deben estar bien separados
4. **Sin directivas avanzadas**: No soporta `.align`, `.string`, `.byte`, etc.
5. **Sin soporte para relocations**: Todo el código debe ser position-dependent

---

## Posibles Extensiones

### Características Adicionales Sugeridas

1. **Soporte para `.string` y `.byte`**
```assembly
.data
message:
    .string "Hello, World!"
byte_array:
    .byte 0x01, 0x02, 0x03
```

2. **Directiva `.align`**
```assembly
.data
.align 8
aligned_data:
    .word 0x12345678
```

3. **Soporte para comentarios multi-línea**
```assembly
/*
  Este es un comentario
  de varias líneas
*/
```

4. **Macros definidos por usuario**
```assembly
.macro push reg
    addi sp, sp, -4
    sw \reg, 0(sp)
.endm
```

5. **Generación de archivos ELF**
```python
def write_elf(machine_code, filename):
    # Generar archivo ELF ejecutable
    pass
```

---

## Referencias y Recursos

### Documentación Oficial

- [RISC-V ISA Specification](https://riscv.org/technical/specifications/)
- [RISC-V Assembly Programmer's Manual](https://github.com/riscv-non-isa/riscv-asm-manual)
- [RISC-V Green Card (Quick Reference)](https://www.cs.sfu.ca/~ashriram/Courses/CS295/assets/notebooks/RISCV/RISCV_CARD.pdf)

### Herramientas Relacionadas

- [RARS](https://github.com/TheThirdOne/rars) - RISC-V Assembler and Runtime Simulator
- [Spike](https://github.com/riscv-software-src/riscv-isa-sim) - RISC-V ISA Simulator
- [GNU RISC-V Toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain)

### Tutoriales

- [RISC-V Assembly Language Programming](https://web.eecs.utk.edu/~smarz1/courses/ece356/notes/assembly/)
- [Introduction to RISC-V Assembly](https://riscv-programming.org/book.html)

---

## Solución de Problemas

### Error: "Registro inválido"

**Problema:**
```
Error: Registro inválido: A0
```

**Solución:**
Los nombres de registros son case-sensitive y deben estar en minúsculas:
```assembly
add A0, A1, A2    # ❌ Incorrecto
add a0, a1, a2    # ✅ Correcto
```

### Error: "Inmediato fuera de rango"

**Problema:**
```
[L5] Inmediato fuera de rango (-2048..2047): 5000
```

**Solución:**
Use `li` en lugar de `addi` para inmediatos grandes:
```assembly
addi a0, x0, 5000    # ❌ Fuera de rango
li a0, 5000          # ✅ Expande automáticamente
```

### Error: "Offset de branch fuera de rango"

**Problema:**
```
Offset de branch fuera de rango: 5000
```

**Solución:**
Los branches tienen rango limitado (±4KB). Use jump en su lugar:
```assembly
beq a0, a1, far_label    # ❌ Si far_label está muy lejos
# Solución:
bne a0, a1, skip
j far_label
skip:
```

### Archivo .hex está vacío

**Problema:**
El archivo de salida no contiene datos.

**Solución:**
Verifique que el código tenga al menos una instrucción en `.text`:
```assembly
    .text        # ✅ Debe haber código aquí
main:
    nop
```

## Conclusión

Este ensamblador implementa un diseño completo y robusto de dos pasadas para RV32I, con soporte exhaustivo para pseudoinstrucciones y manejo detallado de errores. Es una herramienta educativa ideal para comprender:

1. **Arquitectura de ensambladores**: Diseño de dos pasadas
2. **Codificación de instrucciones**: Formatos R/I/S/B/U/J
3. **Resolución de símbolos**: Tablas de etiquetas y referencias forward
4. **Expansión de pseudoinstrucciones**: Traducción de azúcar sintáctica
5. **Generación de código máquina**: Del texto al binario ejecutable

