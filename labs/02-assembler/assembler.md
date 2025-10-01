# Project Assignment: Building an RV32I Two-Pass Assembler


## Introduction

The goal of this project is to deepen your understanding of the relationship
between assembly language and machine code by building your own two-pass
assembler for the RISC-V 32-bit integer instruction set (RV32I).

Your task is to write a program, in a language of your choice, that reads a text
file containing RV32I assembly code and translates it into equivalent 32-bit
machine code in **both** binary and hexadecimal formats. A key requirement is
the proper handling of pseudoinstructions, which are essential for writing
concise and readable assembly programs.


## Core Requirements

### Two pass assembler design

You must implement a two-pass assembler. This is a standard technique for
resolving forward references (i.e., using a label before it is defined).

- First Pass:

    - Read through the entire source file.

    - The primary goal is to build a symbol table. This table will map every
      label defined in the code to a specific memory address.

    - To do this, you must maintain a location counter (LC) that mimics the
      Program Counter (PC). Increment the LC by 4 for each instruction
      encountered.

    - No machine code is generated during this pass.

- Second pass:
  - Read the source file again, from the beginning.

  - Translate each instruction mnemonic and its operands into its corresponding
    32-bit machine code.

  - Use the symbol table generated in the first pass to resolve all label
    references (e.g., in branch and jump instructions).

  - Output the generated machine code to the specified file formats.

### Calling example

Your program (if written in python) will be called `assembler.py` and executed
in the following way:

```shell
python assembler.py program.asm program.hex program.bin
```

Where:

- `program.asm` is the source file with the program.
- `program.hex` is an **output file** containing the hexadecimal encoding of the
  program in `program.asm`
- `program.bin` is an **output file** containing the binary encoding of the
  program in `program.asm`

```shell
node assembler.js program.asm program.hex program.bin
```

### Instructions first, data after

The assembler must produce a single sequential `.bin` and `.hex` file where each line represents one memory byte in increasing address order. Emit bytes for all assembled instructions first (instructions are 32-bit words; write each word in little-endian order, LSB first), then emit all data bytes declared in `.data` (including any alignment padding bytes `0x00`).

### Supported Instruction Set

Your assembler must support all standard base integer instructions from the
RV32I instruction set. A detailed list is provided in the first section of
[this file](https://www.cs.sfu.ca/~ashriram/Courses/CS295/assets/notebooks/RISCV/RISCV_CARD.pdf)
under the title *RV32I Base Integer Instructions*.

### Pseudoinstruction Expansion

Your assembler must be able to recognize and expand all relevant RV32I
pseudoinstructions into one or more base instructions. This is a critical part
of the assignment. For example, a `nop` instruction should be assembled as if it
were `addi x0, x0, 0`. A complete list of required pseudoinstructions is in
Section 5.

### Assembler Directives

Your assembler should correctly handle the following basic directives:

- `.text`: Marks the beginning of the code segment. Instructions following this directive should be placed in memory starting from address 0x00000000.

- `.equ`: Defines a symbolic constant. It associates a name with a numeric expression or value that can be used later in the source as a constant (not a memory location / label that occupies storage).

- `.data`: Marks the beginning of the data segment.

### Detailed notes about .data

The `.data` directive signals that what follows are data declarations rather than instructions. Typical data directives include .byte, .half (or .hword), .word, .ascii/.asciz, and others.

- **Location of data in output:** For this assignment, your generated output files (.hex and .bin) must place all instruction encodings first and then append the data bytes declared in the .data section. This means that when the assembler writes the final binary/hex image, it should write the sequence of instruction words (in the order they appear in the .text segment) first, and only after the last instruction write the bytes allocated in .data. Doing so simplifies loading and testing: code starts at address 0x00000000 and data appears at higher addresses after the code area.

### Alignment by directive

Alignment ensures each data object begins at an address that is a multiple of the required boundary, this avoids unaligned accesses and follows ABI conventions. Below is a recommended, practical mapping of data directives to alignment and clear examples of how they are laid out in memory.

#### Rule by directive

- `.byte / .db / .ascii / .asciz / .string`

  - Alignment: 1 byte (no special alignment).
  - Size per element: 1 byte.

- `.half / .hword`

  - Alignment: 2 bytes.
  - Size per element: 2 bytes.

- `.word`

  - Alignment: 4 bytes.
  - Size per element: 4 bytes.

**Note:** Strings (.ascii, .asciz) write sequential bytes and do not realign automatically; apply .align explicitly if you need the next item aligned.

#### Example

`.byte` followed by `.word` (padding inserted)

```asm
.data
a:  .byte 0x11      # a -> 0x0000
b:  .word 0x12345678 # .word requires 4-byte alignment
                      # assembler inserts 3 bytes of padding (0x0001..0x0003)
                      # b -> 0x0004
```

#### Memory (little-endian) result:

- 0x0000: 0x11

- 0x0001..0x0003: 0x00 (padding)

- 0x0004..0x0007: 0x78 0x56 0x34 0x12

### Error Handling

A robust assembler must provide useful feedback. Your program should detect and
report clear error messages for issues such as:

  ```
  addi x1, x2, x3      # Error: addi expects an immediate value.
  addi x1, x2, 1234567 # Error: immediate out of range.
  addi x1, x2, 0xFF # No error! :-) 
  ```

- Syntax Errors: An instruction or directive is malformed.

- Invalid instruction: The instruction mnemonic is not a valid RV32I instruction
  or supported pseudoinstruction.

- Incorrect Operands: Wrong number or type of arguments for an instruction.

- Undefined Label: An instruction references a label that is not defined
  anywhere in the code.

- Immediate Out of Range: An immediate value is too large or too small to fit in
  the bits allocated by the instruction format.

## Pseudoinstructions

Here is the list of pseudoinstructions your assembler has to support.

| Pseudoinstruction     | Base instruction(s)         | Meaning                         | Needs explanation |
| --------------------- | --------------------------- | ------------------------------- | ----------------- |
| `la rd, symbol`       | `addi rd, rd, symbol[11:0]` | Load address                    | Yes               |
| `l{b,h,w} rd, symbol` |                             | Load global                     | Yes               |
| `s{b,h,w} rd, symbol` |                             | Store global                    | Yes               |
|                       |                             |                                 |                   |
| `nop`                 | `addi x0, x0, 0`            | No operation                    |                   |
| `li rd, immediate`    |                             | Lo0ad immediate (up to 32 bits) | Yes               |
| `mv rd, rs`           | `addi rd, rs, 0`            | Copy register                   |                   |
| `not rd, rs`          | `xori rd, rs, -1`           | One complement                  |                   |
| `neg rd, rs`          | `sub rd, x0, rs`            | One complement                  |                   |
| `seqz rd, rs`         | `sltiu rd, rs, 1`           | Set if equal to zero            |                   |
| `snez rd, rs`         | `sltu rd, x0, rs`           | Set if not equal to zero        |                   |
| `sltz rd, rs`         | `slt rd, rs, x0`            | Set if less than zero           |                   |
| `sgtz rd, rs`         | `slt rd, x0, rs`            | Set if greater than zero        |                   |
|                       |                             |                                 |                   |
| `beqz rs, offset`     | `beq rs, x0, offset`        | Branch if equal to zero         |                   |
| `bnez rs, offset`     | `bne rs, x0, offset`        | Branch if not equal to zero     |                   |
| `blez rs, offset`     | `bge x0, rs, offset`        | Branch if $\leq$ zero           |                   |
| `bgez rs, offset`     | `bge rs, x0, offset`        | Branch if $\geq$ zero           |                   |
| `bltz rs, offset`     | `blt rs, x0 offset`         | Branch if $<$ zero              |                   |
| `bgtz rs, offset`     | `blt x0, rs, offset`        | Branch if $>$ zero              |                   |
|                       |                             |                                 |                   |
| `bgt rs, rt, offset`  | `blt rt, rs, offset`        | Branch if $>$                   |                   |
| `ble rs, rt, offset`  | `bge rt, rs, offset`        | Branch if $\leq$                |                   |
| `bgtu rs, rt, offset` | `bltu rt, rs, offset`       | Branch if $>$                   |                   |
| `bleu rs, rt, offset` | `bgeu rt, rs, offset`       | Branch if $\leq$                |                   |
|                       |                             |                                 |                   |
| `j offset`            | `jal x0, offset`            | Jump                            |                   |
| `jal offset`          | `jal x1, offset`            | Jump and link                   |                   |
| `jr rs`               | `jalr x0, rs, 0`            | Jump register                   |                   |
| `jalr rs`             | `jalr x1, rs, 0`            | Jump and link register          |                   |
| `ret`                 | `jalr x0, x1, 0`            | Return from subrutine           |                   |
| `call offset`         | `jalr x1, x1, offset[11:0]` | Call far away                   | Yes               |
| `tail offset`         | `jalr x0, x6, offset[11:0]` | Tail call from far away         | Yes               |
|                       |                             |                                 |                   |

## Grading Rubric

| Category                       | Points | Description                                                                             |
| ------------------------------ | ------ | --------------------------------------------------------------------------------------- |
| Correctness: base instructions | 40     | All RV32I base instructions are encoded correctly                                       |
| Correctness: pseudo            | 30     | Defined RV32I pseudo instructions are encoded correctly                                 |
| Error handling                 | 15     | Detection and reporting ofwith meaningful errors                                        |
| Code quality                   | 15     | The code is well-structured, readable, and commented. The README is clear and complete. |
| Total                          | 100    |                                                                                         |

## Libraries

- [SLY](https://sly.readthedocs.io/en/latest/sly.html)
- [PEGGY](https://peggyjs.org/)
- [Regular expressions](https://docs.python.org/3/library/re.html)

## Good luck!