# RISC-V Assembler

A comprehensive two-pass assembler for the RISC-V RV32I instruction set architecture, implemented in Python.

## Features

### Instruction Support
- **Complete RV32I Base Integer Instruction Set**
  - R-type instructions (register-register operations)
  - I-type instructions (immediate operations)
  - S-type instructions (store operations)
  - B-type instructions (branch operations)
  - U-type instructions (upper immediate operations)
  - J-type instructions (jump operations)

### Pseudoinstructions
- `nop` - No operation
- `mv` - Move register
- `not` - Bitwise NOT
- `neg` - Negate
- `seqz`, `snez`, `sltz`, `sgtz` - Set if equal/not equal/less than/greater than zero
- `beqz`, `bnez`, `blez`, `bgez`, `bltz`, `bgtz` - Branch if zero/non-zero/less/greater
- `bgt`, `ble`, `bgtu`, `bleu` - Branch greater/less than (signed/unsigned)
- `j`, `jal`, `jr`, `jalr`, `ret` - Jump operations and return

### Assembler Directives
- `.data` - Data section declaration
- `.text` - Text section declaration
- `.word` - 32-bit word definition
- `.half` - 16-bit halfword definition
- `.byte` - 8-bit byte definition
- `.ascii` - ASCII string (non-null-terminated)
- `.asciiz` / `.string` - ASCII string (null-terminated)
- `.space` - Reserve memory space

### Register Support
- **ABI Names**: `zero`, `ra`, `sp`, `gp`, `tp`, `t0-t6`, `s0-s11`, `a0-a7`, `fp`
- **Numeric Names**: `x0-x31`

## Architecture

### Two-Pass Assembly Process
1. **First Pass**: Identifies labels and calculates their memory addresses
2. **Second Pass**: Generates binary and hexadecimal machine code

### Output Files
- `program.bin` - Binary representation of assembled code
- `program.hex` - Hexadecimal representation of assembled code

## Installation

### Prerequisites
```bash
pip install sly
```

### Usage
1. Create your RISC-V assembly program in a file named `program.asm`
2. Run the assembler:
```bash
python assembler.py
```

## Assembly Language Syntax

### Basic Instruction Format
```assembly
# R-type instructions
add rd, rs1, rs2
sub rd, rs1, rs2
xor rd, rs1, rs2

# I-type instructions  
addi rd, rs1, immediate
lw rd, offset(rs1)

# S-type instructions
sw rs2, offset(rs1)

# B-type instructions
beq rs1, rs2, label
bne rs1, rs2, label

# J-type instructions
jal rd, label

# U-type instructions
lui rd, immediate
auipc rd, immediate
```

### Data Definitions
```assembly
.data
    value: .word 0x12345678    # 32-bit word
    array: .word 1, 2, 3, 4    # Array of words
    byte_val: .byte 0xFF       # 8-bit byte
    string: .asciiz "Hello"    # Null-terminated string
    buffer: .space 100         # Reserve 100 bytes

.text
    # Your code here
```

### Example Program
```assembly
.data
    number: .word 42
    message: .asciiz "Hello, RISC-V!"

.text
main:
    # Load immediate value
    addi t0, zero, 10
    
    # Arithmetic operations
    add t2, t0, t1
    sub t3, t2, t0
    
    # Branch example
    beq t2, t1, equal
    bne t2, t1, not_equal
    
equal:
    addi a0, zero, 1
    j end
    
not_equal:
    addi a0, zero, 0
    
end:
    # System call
    ecall
```

## Technical Details

### Immediate Value Ranges
- **12-bit signed**: -2048 to 2047 (I, S, B types)
- **12-bit unsigned**: 0 to 4095 (for unsigned operations)
- **20-bit**: -524288 to 524287 (U-type)
- **21-bit**: -1048576 to 1048574 (J-type)
- **5-bit**: 0 to 31 (shift amounts)

### Memory Layout
- **Text Section**: Contains executable instructions
- **Data Section**: Contains initialized data and variables
- **Address Calculation**: Automatic label resolution and PC-relative addressing

### Error Handling
The assembler provides comprehensive error checking for:
- Invalid instruction formats
- Out-of-range immediate values
- Undefined labels and registers
- Malformed assembly directives
- Invalid token sequences

## Code Structure

### Main Components
- **Lexer Classes**: Specialized lexers for different instruction types
- **Instruction Type Classes**: Define opcodes and function codes
- **Register Mappings**: ABI and numeric register name translations
- **Two's Complement Function**: Handles signed immediate values
- **Assembly Passes**: Label resolution and code generation

### Key Files
- `assembler.py` - Main assembler implementation
- `program.asm` - Input assembly source file
- `program.bin` - Generated binary output
- `program.hex` - Generated hexadecimal output

## Contributing

This assembler supports the complete RV32I base instruction set as specified in the RISC-V ISA specification. The implementation follows standard two-pass assembly techniques and provides detailed error reporting.

### Future Enhancements
- Support for additional RISC-V extensions (M, A, F, D)
- Macro support
- Include file processing
- Enhanced debugging features
- ELF file output format

## License

This project is open source and available under the MIT License.

---

**Note**: This assembler generates machine code compatible with RV32I processors and simulators. Ensure your target platform supports the RV32I instruction set architecture.