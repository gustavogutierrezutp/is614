from sly import Lexer, Parser

# Dictionary to store label addresses
labels = {}

# Dictionary to store variable addresses
variables = {}

# Memory to store binary and hexadecimal instructions
memory_bin = []
memory_hex = []

# Class to define assembler directives
class directives:
    Directives = [
        ".text",  # Start of text section
        ".word",  # Define a word (32 bits)
        ".byte",  # Define a byte (8 bits)
        ".half",  # Define a halfword (16 bits)
        ".asciiz",  # Null-terminated string
        ".ascii",  # String without null termination
        ".string",  # Alias for .asciiz
        ".space"  # Reserve space in memory
    ]

# Class to define R-type instructions
class type_r:
    Functions = {
        # Format: opcode, funct3, funct7
        "add": ["0110011", "000", "0000000"],
        "sub": ["0110011", "000", "0100000"],
        "xor": ["0110011", "100", "0000000"],
        "or": ["0110011", "110", "0000000"],
        "and": ["0110011", "111", "0000000"],
        "sll": ["0110011", "001", "0000000"],
        "srl": ["0110011", "101", "0000000"],
        "sra": ["0110011", "101", "0100000"],
        "slt": ["0110011", "010", "0000000"],
        "sltu": ["0110011", "011", "0000000"]
    }

# Class to define I-type instructions
class type_i:
    Functions = {
        # Format: opcode, funct3
        "addi": ["0010011", "000"],
        "xori": ["0010011", "100"],
        "ori": ["0010011", "110"],
        "andi": ["0010011", "111"],
        "slti": ["0010011", "010"],
        "sltiu": ["0010011", "011"]
    }

# Class to define shift immediate instructions (special I-type)
class type_si:
    Functions = {
        # Format: opcode, funct3, imm[5:11]
        "slli": ["0010011", "001", "0000000"],
        "srli": ["0010011", "101", "0000000"],
        "srai": ["0010011", "101", "0100000"]
    }

# Class to define load instructions
class type_l:
    Functions = {
        # Format: opcode, funct3
        "lb": ["0000011", "000"],
        "lh": ["0000011", "001"],
        "lw": ["0000011", "010"],
        "lbu": ["0000011", "100"],
        "lhu": ["0000011", "101"]
    }

# Class to define store instructions
class type_s:
    Functions = {
        # Format: opcode, funct3
        "sb": ["0100011", "000"],
        "sh": ["0100011", "001"],
        "sw": ["0100011", "010"]
    }

# Class to define branch instructions
class type_b:
    Functions = {
        # Format: opcode, funct3
        "beq": ["1100011", "000"],
        "bne": ["1100011", "001"],
        "blt": ["1100011", "100"],
        "bge": ["1100011", "101"],
        "bltu": ["1100011", "110"],
        "bgeu": ["1100011", "111"]
    }

# Class to define jump instructions
class type_j:
    Functions = {
        # Format: opcode
        "jal": ["1101111"]
    }

# Class to define jump register instructions
class type_jr:
    Functions = {
        # Format: opcode, funct3
        "jalr": ["1100111", "000"]
    }

# Class to define upper immediate instructions
class type_u:
    Functions = {
        # Format: opcode
        "lui": ["0110111"],
        "auipc": ["0010111"]
    }

# Class to define environment call instructions
class type_ecall:
    Functions = {
        # Format: opcode, funct3, imm
        "ecall": ["1110011", "000", "0"],
        "ebreak": ["1110011", "000", "1"]
    }

# Class to define pseudoinstructions
class pseudoinstruction:
    Functions = [
        "nop", "mv", "not", "neg", "seqz", "snez", "sltz", "sgtz",
        "beqz", "bnez", "blez", "bgez", "bltz", "bgtz", "bgt", "ble",
        "bgtu", "bleu", "j", "jal", "jr", "jalr", "ret"
    ]

# Class to define register mappings
class register:
    register = {
        "zero": 0, "ra": 1, "sp": 2, "gp": 3, "tp": 4,
        "t0": 5, "t1": 6, "t2": 7, "s0": 8, "fp": 8,
        "s1": 9, "a0": 10, "a1": 11, "a2": 12, "a3": 13,
        "a4": 14, "a5": 15, "a6": 16, "a7": 17, "s2": 18,
        "s3": 19, "s4": 20, "s5": 21, "s6": 22, "s7": 23,
        "s8": 24, "s9": 25, "s10": 26, "s11": 27, "t3": 28,
        "t4": 29, "t5": 30, "t6": 31,
        "x0": 0, "x1": 1, "x2": 2, "x3": 3, "x4": 4,
        "x5": 5, "x6": 6, "x7": 7, "x8": 8, "x9": 9,
        "x10": 10, "x11": 11, "x12": 12, "x13": 13,
        "x14": 14, "x15": 15, "x16": 16, "x17": 17,
        "x18": 18, "x19": 19, "x20": 20, "x21": 21,
        "x22": 22, "x23": 23, "x24": 24, "x25": 25,
        "x26": 26, "x27": 27, "x28": 28, "x29": 29,
        "x30": 30, "x31": 31
    }

#Lexer for numbers
class number_lexer(Lexer):
    tokens = {NUMBER}
    literals = {',', ':', '\n'}
    ignore = ' \t'
    ignore_comment = r'\#.*'
    ignore_newline = r'\n+'
    ignore_whitespace = r'[ \t]+'

    # Define tokens
    NUMBER = r'0x[0-9a-fA-F]+|-?\d+'

# Lexer for R-type instructions
class lexer_rtype(Lexer):
    tokens = {REGISTER, INSTRUCTION}
    literals = {',', ':', '\n'}
    ignore = ' \t'
    ignore_comment = r'\#.*'
    ignore_newline = r'\n+'
    ignore_whitespace = r'[ \t]+'

    # Define tokens
    REGISTER = r'x1[0-9]|x2[0-9]|x3[0-1]|x[0-9]|zero|ra|sp|gp|tp|t[0-6]|s[0-9]|s1[0-1]|a[0-7]|fp'
    INSTRUCTION = r'add|sub|xor|or|and|sll|srl|sra|sltu|slt'

# Lexer for I-type instructions
class lexer_itype(Lexer):
    tokens = {REGISTER, NUMBER, INSTRUCTION}
    literals = {',', ':', '\n'}
    ignore = ' \t'
    ignore_comment = r'\#.*'
    ignore_newline = r'\n+'
    ignore_whitespace = r'[ \t]+'

    # Define tokens
    REGISTER = r'x1[0-9]|x2[0-9]|x3[0-1]|x[0-9]|zero|ra|sp|gp|tp|t[0-6]|s[0-9]|s1[0-1]|a[0-7]|fp'
    NUMBER = r'0x[0-9a-fA-F]+|-?\d+'
    INSTRUCTION = r'addi|xori|ori|andi|sltiu|slti'

# Lexer for shift immediate instructions
class lexer_shift_itype(Lexer):
    tokens = {REGISTER, NUMBER, INSTRUCTION}
    literals = {',', ':', '\n'}
    ignore = ' \t'
    ignore_comment = r'\#.*'
    ignore_newline = r'\n+'
    ignore_whitespace = r'[ \t]+'

    # Define tokens
    REGISTER = r'x1[0-9]|x2[0-9]|x3[0-1]|x[0-9]|zero|ra|sp|gp|tp|t[0-6]|s[0-9]|s1[0-1]|a[0-7]|fp'
    NUMBER = r'0x[0-9a-fA-F]+|-?\d+'
    INSTRUCTION = r'slli|srli|srai'

# Lexer for load instructions
class lexer_load(Lexer):
    tokens = {REGISTER, INSTRUCTION, NUMBER, LABEL}
    literals = {',', ':', '\n'}
    ignore = ' \t'
    ignore_comment = r'\#.*'
    ignore_newline = r'\n+'
    ignore_whitespace = r'[ \t]+'

    # Define tokens
    REGISTER = r'x1[0-9]|x2[0-9]|x3[0-1]|x[0-9]|zero|ra|sp|gp|tp|t[0-6]|s[0-9]|s1[0-1]|a[0-7]|fp'
    INSTRUCTION = r'lbu|lhu|lw|lb|lh'
    NUMBER = r'0x[0-9a-fA-F]+|-?\d+'
    LABEL = r'[a-zA-Z_]+[a-zA-Z0-9_]*'

# Lexer for store instructions
class lexer_store(Lexer):
    tokens = {REGISTER, INSTRUCTION, NUMBER}
    literals = {',', ':', '\n'}
    ignore = ' \t'
    ignore_comment = r'\#.*'
    ignore_newline = r'\n+'
    ignore_whitespace = r'[ \t]+'

    # Define tokens
    REGISTER = r'x1[0-9]|x2[0-9]|x3[0-1]|x[0-9]|zero|ra|sp|gp|tp|t[0-6]|s[0-9]|s1[0-1]|a[0-7]|fp'
    INSTRUCTION = r'sb|sh|sw'
    NUMBER = r'0x[0-9a-fA-F]+|-?\d+'

# Lexer for branch instructions
class lexer_branch(Lexer):
    tokens = {REGISTER, LABEL, INSTRUCTION}
    literals = {',', ':', '\n'}
    ignore = ' \t'
    ignore_comment = r'\#.*'
    ignore_newline = r'\n+'
    ignore_whitespace = r'[ \t]+'

    # Define tokens
    INSTRUCTION = r'beq|bne|bltu|bgeu|blt|bge'
    REGISTER = r'x1[0-9]|x2[0-9]|x3[0-1]|x[0-9]|zero|ra|sp|gp|tp|t[0-6]|s[0-9]|s1[0-1]|a[0-7]|fp'
    LABEL = r'[a-zA-Z_]+[a-zA-Z0-9_]*'

# Lexer for jump instructions
class lexer_jtype(Lexer):
    tokens = {REGISTER, LABEL, INSTRUCTION}
    literals = {',', ':', '\n'}
    ignore = ' \t'
    ignore_comment = r'\#.*'
    ignore_newline = r'\n+'
    ignore_whitespace = r'[ \t]+'

    # Define tokens
    INSTRUCTION = r'jal'
    REGISTER = r'x1[0-9]|x2[0-9]|x3[0-1]|x[0-9]|zero|ra|sp|gp|tp|t[0-6]|s[0-9]|s1[0-1]|a[0-7]|fp'
    LABEL = r'[a-zA-Z_]+[a-zA-Z0-9_]*'

# Lexer for jump register instructions
class lexer_jrtype(Lexer):
    tokens = {REGISTER, NUMBER, INSTRUCTION}
    literals = {',', ':', '\n'}
    ignore = ' \t'
    ignore_comment = r'\#.*'
    ignore_newline = r'\n+'
    ignore_whitespace = r'[ \t]+'

    # Define tokens
    REGISTER = r'x1[0-9]|x2[0-9]|x3[0-1]|x[0-9]|zero|ra|sp|gp|tp|t[0-6]|s[0-9]|s1[0-1]|a[0-7]|fp'
    NUMBER = r'0x[0-9a-fA-F]+|-?\d+'
    INSTRUCTION = r'jalr'

# Lexer for upper immediate instructions
class lexer_utype(Lexer):
    tokens = {REGISTER, NUMBER, INSTRUCTION}
    literals = {',', ':', '\n'}
    ignore = ' \t'
    ignore_comment = r'\#.*'
    ignore_newline = r'\n+'
    ignore_whitespace = r'[ \t]+'

    # Define tokens
    REGISTER = r'x1[0-9]|x2[0-9]|x3[0-1]|x[0-9]|zero|ra|sp|gp|tp|t[0-6]|s[0-9]|s1[0-1]|a[0-7]|fp'
    NUMBER = r'0x[0-9a-fA-F]+|-?\d+'
    INSTRUCTION = r'lui|auipc'

# Lexer for environment call instructions
class lexer_ecall(Lexer):
    tokens = {INSTRUCTION}
    literals = {',', ':', '\n'}
    ignore = ' \t'
    ignore_comment = r'\#.*'
    ignore_newline = r'\n+'
    ignore_whitespace = r'[ \t]+'

    # Define tokens
    INSTRUCTION = r'ecall|ebreak'

# Lexer for labels
class label_lexer(Lexer):
    tokens = {LABEL}
    literals = {',', ':', '\n'}
    ignore = ' \t'
    ignore_comment = r'\#.*'
    ignore_newline = r'\n+'
    ignore_whitespace = r'[ \t]+'

    # Define tokens
    LABEL = r'[a-zA-Z_]+[a-zA-Z0-9_]*'

# Function to calculate two's complement for a given value and bit size
def two_complement(value, bits):
    if value < 0:
        value = (1 << bits) + value
    return value 

# First pass: Identify labels and their addresses
def first_pass():
    in_data_section = False
    lines = [line.strip() for line in open("program.asm", "r")]
    pc = 0
    for line in lines:
        parts1 = line.split(",")
        parts2 = parts1[0].split()
        parts = parts2 + parts1[1:]

        if line == '.data':
            in_data_section = True
        elif line == '.text':
            in_data_section = False

        if not in_data_section:
            if line.endswith(':'):
                lexer = label_lexer()
                for tok in lexer.tokenize(line):
                    if tok.type == 'LABEL':
                        label = tok.value.replace(':', '').replace(' ', '')  # Remove the colon and any spaces
                        labels[label] = pc 
            elif line == '' or line.startswith('#') or line == '\n' or line == '\r':
                continue
            elif parts[0] in pseudoinstruction.Functions or parts[0] in type_r.Functions or parts[0] in type_i.Functions or parts[0] in type_si.Functions or parts[0] in type_l.Functions or parts[0] in type_s.Functions or parts[0] in type_b.Functions or parts[0] in type_j.Functions or parts[0] in type_jr.Functions or parts[0] in type_u.Functions or parts[0] in type_ecall.Functions:
                pc += 4
        else:
            continue

# Second pass: Generate binary and hexadecimal instructions
def second_pass():
    with open("program.bin", "w") as binary_instruction_doc, open("program.hex", "w") as hex_instruction_doc:
        pc = 0
        in_data_section = False
        lines = [line.strip() for line in open("program.asm", "r")]
        for line in lines:
            line = line.split('#')[0].strip()
            parts1 = line.split(",")
            parts2 = parts1[0].split()
            parts = parts2 + parts1[1:]
            if line == '.data':
                in_data_section = True
            elif line == '.text':
                in_data_section = False
                pc = 0

            # This section handles the .data section of the assembly program
            # It processes various assembler directives such as .word, .byte, .half, .space, .ascii, .asciiz, and .string
            # It also calculates memory addresses for variables and stores binary and hexadecimal representations of data
            if in_data_section:
                if line == '' or line.startswith('#') or line == '\n' or line == '\r' or line == '.data':
                    continue
                elif parts[0].endswith(':') :
                    if parts[1] in ['.ascii', '.asciiz', '.string']:
                        parts3 = line.split('"')
                        parts = [parts[0], parts[1], '"' + parts3[1] + '"']
                    lexer= label_lexer()
                    for tok in lexer.tokenize(parts[0]):
                        if tok.type == 'LABEL':
                            variable = tok.value.replace(':', '').replace(' ', '')  # Remove the colon and any spaces
                            variables[variable] = pc

                    # Handle .word directive (32-bit data)
                    if parts[1] == '.word' and len(parts) >= 3:
                        for j in range(2, len(parts)):
                            for c in range(4):
                                if pc % 4 != 0:
                                    memory_bin.append('00000000')
                                    memory_hex.append('0x0')
                                    pc += 1
                            variables[variable] = pc
                            if len(parts) > 3:
                                variable = parts[0].replace(':', '').replace(' ', '') + '_' + str(j-2)
                                variables[variable] = pc
                            if parts[j].startswith('0x'):
                                if 0 <= int(parts[j], 16) <= 0xFFFFFFFF :
                                    byte_1 = format(int(parts[j], 16) & 0xFF, '08b')
                                    memory_bin.append(byte_1)
                                    byte_2 = format((int(parts[j], 16) >> 8) & 0xFF, '08b')
                                    memory_bin.append(byte_2)
                                    byte_3 = format((int(parts[j], 16) >> 16) & 0xFF, '08b')
                                    memory_bin.append(byte_3)
                                    byte_4 = format((int(parts[j], 16) >> 24) & 0xFF, '08b')
                                    memory_bin.append(byte_4)

                                    byte_1_hex = hex(int(byte_1, 2))
                                    memory_hex.append(byte_1_hex)
                                    byte_2_hex = hex(int(byte_2, 2))
                                    memory_hex.append(byte_2_hex)
                                    byte_3_hex = hex(int(byte_3, 2))
                                    memory_hex.append(byte_3_hex)
                                    byte_4_hex = hex(int(byte_4, 2))
                                    memory_hex.append(byte_4_hex)
                                    pc += 4
                                else:
                                    raise ValueError("Value out of range for 32 bits")
                            elif -2147483648 <= int(parts[j]) <= 2147483647 :
                                byte_1 = format(int(parts[j]) & 0xFF, '08b')
                                memory_bin.append(byte_1)
                                byte_2 = format((int(parts[j]) >> 8) & 0xFF, '08b')
                                memory_bin.append(byte_2)
                                byte_3 = format((int(parts[j]) >> 16) & 0xFF, '08b')
                                memory_bin.append(byte_3)
                                byte_4 = format((int(parts[j]) >> 24) & 0xFF, '08b')
                                memory_bin.append(byte_4)
                                byte_1_hex = hex(int(byte_1, 2))
                                memory_hex.append(byte_1_hex)
                                byte_2_hex = hex(int(byte_2, 2))
                                memory_hex.append(byte_2_hex)
                                byte_3_hex = hex(int(byte_3, 2))
                                memory_hex.append(byte_3_hex)
                                byte_4_hex = hex(int(byte_4, 2))
                                memory_hex.append(byte_4_hex)
                                pc += 4
                            else:
                                raise ValueError("Value out of range for 32 bits")
                            
                    # Handle .byte directive (8-bit data)
                    elif parts[1] == '.byte' and len(parts) >= 3:
                        for j in range(2, len(parts)):
                            if len(parts) > 3:
                                variable = parts[0].replace(':', '').replace(' ', '') + '_' + str(j-2)
                                variables[variable] = pc
                            if parts[j].startswith('0x'):
                                if 0 <= int(parts[j], 16) <= 0xFF :
                                    byte = format(int(parts[j], 16) & 0xFF, '08b')
                                    memory_bin.append(byte)
                                    byte_hex = hex(int(byte, 2))
                                    memory_hex.append(byte_hex)
                                    pc += 1
                                else:
                                    raise ValueError("Value out of range for 8 bits")
                            elif -128 <= int(parts[j]) <= 127 :
                                byte = format(int(parts[j]) & 0xFF, '08b')
                                memory_bin.append(byte)
                                byte_hex = hex(int(byte, 2))
                                memory_hex.append(byte_hex)
                                pc += 1
                            else:
                                raise ValueError("Value out of range for 8 bits")
                    # Handle .half directive (16-bit data)
                    elif parts[1] == '.half' and len(parts) >= 3:
                        for j in range(2, len(parts)):
                            for c in range(2):
                                if pc % 2 != 0:
                                    memory_bin.append('00000000')
                                    memory_hex.append('0x0')
                                    pc += 1
                            variables[variable] = pc
                            if len(parts) > 3:
                                variable = parts[0].replace(':', '').replace(' ', '') + '_' + str(j-2)
                                variables[variable] = pc
                            if parts[j].startswith('0x'):
                                if 0 <= int(parts[j], 16) <= 0xFFFF :
                                    byte_1 = format(int(parts[j], 16) & 0xFF, '08b')
                                    memory_bin.append(byte_1)
                                    byte_2 = format((int(parts[j], 16) >> 8) & 0xFF, '08b')
                                    memory_bin.append(byte_2)
                                    byte_1_hex = hex(int(byte_1, 2))
                                    memory_hex.append(byte_1_hex)
                                    byte_2_hex = hex(int(byte_2, 2))
                                    memory_hex.append(byte_2_hex)
                                    pc += 2
                                else:
                                    raise ValueError("Value out of range for 16 bits")
                            elif -32768 <= int(parts[j]) <= 32767 :
                                byte_1 = format(int(parts[j]) & 0xFF, '08b')
                                memory_bin.append(byte_1)
                                byte_2 = format((int(parts[j]) >> 8) & 0xFF, '08b')
                                memory_bin.append(byte_2)
                                byte_1_hex = hex(int(byte_1, 2))
                                memory_hex.append(byte_1_hex)
                                byte_2_hex = hex(int(byte_2, 2))
                                memory_hex.append(byte_2_hex)
                                pc += 2
                            else:
                                raise ValueError("Value out of range for 16 bits")
                    # Handle .space directive (reserve memory space)
                    elif parts[1] == '.space' and len(parts) == 3:
                        if parts[2].startswith('0x'):
                            if 0 <= int(parts[2], 16) <= 0xFFFFFFFF :
                                space_size = int(parts[2], 16)
                                for j in range(space_size):
                                    memory_bin.append('00000000')
                                    byte_hex = hex(0)
                                    memory_hex.append(byte_hex)
                                pc += space_size
                            else:
                                raise ValueError("Value out of range for .space directive")
                        elif 0 <= int(parts[2]) <= 4294967295 :
                             space_size = int(parts[2])
                             for j in range(space_size):
                                 memory_bin.append('00000000')
                                 byte_hex = hex(0)
                                 memory_hex.append(byte_hex)
                             pc += space_size
                        else:
                             raise ValueError("Value out of range for .space directive")
                     # Handle .ascii directive (non-null-terminated string)
                    elif parts[1] == '.ascii' and len(parts) == 3:
                        string = parts[2].strip('"')
                        string = string[::-1]  # Reverse the string for correct byte order
                        for char in string:
                            byte = format(ord(char) & 0xFF, '08b')
                            memory_bin.append(byte)
                            byte_hex = hex(int(byte, 2))
                            memory_hex.append(byte_hex)
                        pc += len(string)
                    # Handle .asciiz and .string directives (null-terminated string)
                    elif (parts[1] == '.asciiz' or parts[1] == '.string') and len(parts) == 3:
                        string = parts[2].strip('"')
 # Reverse the string for correct byte order
                        string += '\0'  # Add null terminator
                        for char in string:
                            byte = format(ord(char) & 0xFF, '08b')
                            memory_bin.append(byte)
                            byte_hex = hex(int(byte, 2))
                            memory_hex.append(byte_hex)
                        pc += len(string)
                        byte_hex = hex(0)
                        memory_hex.append(byte_hex)
                # Handle cases where the label and the : are separated by spaces
                elif parts[1].endswith(':'):
                    if parts[2] in ['.ascii', '.asciiz', '.string']:
                        parts3 = line.split('"')
                        parts = [parts[0], parts[1], parts[2] + '"' + parts3[1] + '"']
                    lexer= label_lexer()
                    for tok in lexer.tokenize(parts[0]):
                        if tok.type == 'LABEL':
                            variable = tok.value.replace(':', '').replace(' ', '')  # Remove the colon and any spaces
                            variables[variable] = pc

                    # Handle .word directive (32-bit data) with label
                    if parts[2] == '.word' and len(parts) == 3:
                        for c in range(4):
                            if pc % 4 != 0:
                                memory_bin.append('00000000')
                                memory_hex.append('0x0')
                                pc += 1
                        variables[variable] = pc
                        if parts[3].startswith('0x'):
                            if 0 <= int(parts[3], 16) <= 0xFFFFFFFF :
                                byte_1 = format((int(parts[3], 16) >> 24) & 0xFF, '08b')
                                memory_bin.append(byte_1)
                                byte_2 = format((int(parts[3], 16) >> 16) & 0xFF, '08b')
                                memory_bin.append(byte_2)
                                byte_3 = format((int(parts[3], 16) >> 8) & 0xFF, '08b')
                                memory_bin.append(byte_3)
                                byte_4 = format(int(parts[3], 16) & 0xFF, '08b')
                                memory_bin.append(byte_4)

                                byte_1_hex = hex(int(byte_1, 2))
                                memory_hex.append(byte_1_hex)
                                byte_2_hex = hex(int(byte_2, 2))
                                memory_hex.append(byte_2_hex)
                                byte_3_hex = hex(int(byte_3, 2))
                                memory_hex.append(byte_3_hex)
                                byte_4_hex = hex(int(byte_4, 2))
                                memory_hex.append(byte_4_hex)
                                pc += 4
                            else:
                                raise ValueError("Value out of range for 32 bits")
                        elif -2147483648 <= int(parts[3]) <= 2147483647 :
                            byte_1 = format((int(parts[3]) >> 24) & 0xFF, '08b')
                            memory_bin.append(byte_1)
                            byte_2 = format((int(parts[3]) >> 16) & 0xFF, '08b')
                            memory_bin.append(byte_2)
                            byte_3 = format((int(parts[3]) >> 8) & 0xFF, '08b')
                            memory_bin.append(byte_3)
                            byte_4 = format(int(parts[3]) & 0xFF, '08b')
                            memory_bin.append(byte_4)
                            byte_1_hex = hex(int(byte_1, 2))
                            memory_hex.append(byte_1_hex)
                            byte_2_hex = hex(int(byte_2, 2))
                            memory_hex.append(byte_2_hex)
                            byte_3_hex = hex(int(byte_3, 2))
                            memory_hex.append(byte_3_hex)
                            byte_4_hex = hex(int(byte_4, 2))
                            memory_hex.append(byte_4_hex)
                            pc += 4
                        else:
                            raise ValueError("Value out of range for 32 bits")
                    # Handle .byte directive (8-bit data) with label
                    elif parts[2] == '.byte' and len(parts) == 3:
                        if parts[3].startswith('0x'):
                            if 0 <= int(parts[3], 16) <= 0xFF :
                                byte = format(int(parts[3], 16) & 0xFF, '08b')
                                memory_bin.append(byte)
                                byte_hex = hex(int(byte, 2))
                                memory_hex.append(byte_hex)
                                pc += 1
                            else:
                                raise ValueError("Value out of range for 8 bits")
                        elif -128 <= int(parts[3]) <= 127 :
                            byte = format(int(parts[3]) & 0xFF, '08b')
                            memory_bin.append(byte)
                            byte_hex = hex(int(byte, 2))
                            memory_hex.append(byte_hex)
                            pc += 1
                        else:
                            raise ValueError("Value out of range for 8 bits")
                    # Handle .half directive (16-bit data) with label
                    elif parts[2] == '.half' and len(parts) == 3:
                        for c in range(2):
                            if pc % 2 != 0:
                                memory_bin.append('00000000')
                                memory_hex.append('0x0')
                                pc += 1
                        variables[variable] = pc
                        if parts[3].startswith('0x'):
                            if 0 <= int(parts[3], 16) <= 0xFFFF :
                                byte_1 = format((int(parts[3], 16) >> 8) & 0xFF, '08b')
                                memory_bin.append(byte_1)
                                byte_2 = format(int(parts[3], 16) & 0xFF, '08b')
                                memory_bin.append(byte_2)
                                byte_1_hex = hex(int(byte_1, 2))
                                memory_hex.append(byte_1_hex)
                                byte_2_hex = hex(int(byte_2, 2))
                                memory_hex.append(byte_2_hex)
                                pc += 2
                            else:
                                raise ValueError("Value out of range for 16 bits")
                        elif -32768 <= int(parts[3]) <= 32767 :
                            byte_1 = format((int(parts[3]) >> 8) & 0xFF, '08b')
                            memory_bin.append(byte_1)
                            byte_2 = format(int(parts[3]) & 0xFF, '08b')
                            memory_bin.append(byte_2)
                            byte_1_hex = hex(int(byte_1, 2))
                            memory_hex.append(byte_1_hex)
                            byte_2_hex = hex(int(byte_2, 2))
                            memory_hex.append(byte_2_hex)
                            pc += 2
                        else:
                            raise ValueError("Value out of range for 16 bits")
                    # Handle .space directive (reserve memory space) with label
                    elif parts[2] == '.space' and len(parts) == 3:
                        if parts[3].startswith('0x'):
                            if 0 <= int(parts[3], 16) <= 0xFFFFFFFF :
                                space_size = int(parts[3], 16)
                                for j in range(space_size):
                                    memory_bin.append('00000000')
                                    byte_hex = hex(0)
                                    memory_hex.append(byte_hex)
                                pc += space_size
                            else:
                                raise ValueError("Value out of range for .space directive")
                        elif 0 <= int(parts[3]) <= 4294967295 :
                            space_size = int(parts[3])
                            for j in range(space_size):
                                memory_bin.append('00000000')
                                byte_hex = hex(0)
                                memory_hex.append(byte_hex)
                            pc += space_size
                        else:
                            raise ValueError("Value out of range for .space directive")
                    # Handle .ascii directive (non-null-terminated string) with label
                    elif parts[2] == '.ascii' and len(parts) == 3:
                        string = parts[3].strip('"')
                        string = string[::-1] # Reverse the string for correct byte order
                        for char in string:
                            byte = format(ord(char) & 0xFF, '08b')
                            memory_bin.append(byte)
                            byte_hex = hex(int(byte, 2))
                            memory_hex.append(byte_hex)
                        pc += len(string)
                    # Handle .asciiz and .string directives (null-terminated string) with label
                    elif (parts[2] == '.asciiz' or parts[2] == '.string') and len(parts) == 3:
                        string = parts[3].strip('"')
                        string = string[::-1] # Reverse the string for correct byte order
                        string += '\0'

                        for char in string:
                            byte = format(ord(char) & 0xFF, '08b')
                            memory_bin.append(byte)
                            byte_hex = hex(int(byte, 2))
                            memory_hex.append(byte_hex)
                        pc += len(string)
                        memory_bin.append('00000000')
                        byte_hex = hex(0)
                        memory_hex.append(byte_hex)
                else:
                    raise ValueError("Invalid data directive or format")

# .text section
            elif not in_data_section:
    # Type R (Register)
                if line == '' or line.startswith('#') or line == '\n' or line == '\r' or line == '.text':
                    continue
                elif parts[0] in type_r.Functions and len(parts) == 4:
                    # Tokenize the line using the lexer for R-type instructions
                    lexer = lexer_rtype()
                    i = 0
                    for tok in lexer.tokenize(line):
                        # Extract function codes and opcode for the instruction
                        if tok.type == 'INSTRUCTION' and tok.value in type_r.Functions and tok.value == parts[0]:
                            func7 = type_r.Functions[tok.value][2]
                            func3 = type_r.Functions[tok.value][1]
                            opcode = type_r.Functions[tok.value][0]
                        # Extract register values for rd, rs1, and rs2
                        elif tok.type == 'REGISTER' and tok.value in register.register and (tok.value in parts[1] or tok.value in parts[2] or tok.value in parts[3]):
                            if i == 0:
                                rd = register.register[tok.value]
                            elif i == 1:
                                rs1 = register.register[tok.value]
                            elif i == 2:
                                rs2 = register.register[tok.value]
                            i += 1
                        elif tok.type == ',':
                            continue
                        else:
                            raise ValueError("Invalid token or token not in expected position")
                    # Generate binary and hexadecimal instructions
                    binary_instruction = func7 + format(rs2, '05b') + format(rs1, '05b') + func3 + format(rd, '05b') + opcode
                    binary_instruction_doc.write(binary_instruction + '\n')
                    hex_instruction = hex(int(binary_instruction, 2))
                    hex_instruction_doc.write(hex_instruction + '\n')
                    pc += 4
        # Type I (Immediate)
                elif parts[0] in type_i.Functions and len(parts) == 4:
                    # Tokenize the line using the lexer for I-type instructions
                    lexer = lexer_itype()
                    i = 0
                    for tok in lexer.tokenize(line):
                        # Extract function codes and opcode for the instruction
                        if tok.type == 'INSTRUCTION' and tok.value in type_i.Functions and tok.value == parts[0]:
                            func3 = type_i.Functions[tok.value][1]
                            opcode = type_i.Functions[tok.value][0]
                        # Extract register values for rd and rs1
                        elif tok.type == 'REGISTER' and tok.value in register.register and (tok.value in parts[1] or tok.value in parts[2]):
                            if i == 0:
                                rd = register.register[tok.value]
                            elif i == 1:
                                rs1 = register.register[tok.value]
                            i += 1
                        # Extract immediate value and handle range validation
                        elif tok.type == 'NUMBER' and tok.value in parts[3]:
                            if parts[0] == 'sltiu':
                                if tok.value.startswith('0x'):
                                    if 0 <= int(tok.value, 16) <= 0xFFF :
                                        imm = int(tok.value, 16)
                                    else:
                                        raise ValueError("Immediate value out of range for 12 bits")
                                elif 0 <= int(tok.value) <= 4095 :
                                    imm = int(tok.value)
                                else:
                                    raise ValueError("Immediate value out of range for 12 bits")
                            else:
                                if tok.value.startswith('0x'):
                                    if 0 <= int(tok.value, 16) <= 0xFFF :
                                        if int(tok.value, 16) > 0x7FF:
                                            imm = two_complement(int(tok.value, 16), 12)
                                        else:
                                            imm = int(tok.value, 16)
                                    else:
                                        raise ValueError("Immediate value out of range for 12 bits")
                                elif -2048 <= int(tok.value) <= 2047 :
                                    if int(tok.value) < 0:
                                        imm = two_complement(int(tok.value), 12)
                                    else:
                                        imm = int(tok.value)
                                else:
                                    raise ValueError("Immediate value out of range for 12 bits")
                        elif tok.type in ",":
                                continue
                        else:
                            raise ValueError("Invalid token or token not in expected position")
                    # Generate binary and hexadecimal instructions
                    binary_instruction = format(imm, '012b') + format(rs1, '05b') + func3 + format(rd, '05b') + opcode
                    binary_instruction_doc.write(binary_instruction + '\n')
                    hex_instruction = hex(int(binary_instruction, 2))
                    hex_instruction_doc.write(hex_instruction + '\n')
                    pc += 4
        # Type SI (Shift Immediate)
                elif parts[0] in type_si.Functions and len(parts) == 4:
                    # Tokenize the line using the lexer for shift immediate instructions
                    lexer = lexer_shift_itype()
                    i = 0
                    for tok in lexer.tokenize(line):
                        # Extract function codes and opcode for the instruction
                        if tok.type == 'INSTRUCTION' and tok.value in type_si.Functions and tok.value == parts[0]:
                            func7 = type_si.Functions[tok.value][2]
                            func3 = type_si.Functions[tok.value][1]
                            opcode = type_si.Functions[tok.value][0]
                        # Extract register values for rd and rs1
                        elif tok.type == 'REGISTER' and tok.value in register.register and (tok.value in parts[1] or tok.value in parts[2]):
                            if i == 0:
                                rd = register.register[tok.value]
                            elif i == 1:
                                rs1 = register.register[tok.value]
                            i += 1
                        # Extract immediate value and handle range validation
                        elif tok.type == 'NUMBER' and tok.value in parts[3]:
                            if tok.value.startswith('0x'):
                                if 0 <= int(tok.value, 16) <= 0x1F :
                                    imm = int(tok.value, 16)
                                else:
                                    raise ValueError("Immediate value out of range for shift amount (0-31)")
                            elif 0 <= int(tok.value) <= 31 :
                                imm = int(tok.value)
                            else:
                                raise ValueError("Immediate value out of range for shift amount (0-31)")
                        elif tok.type in ",":
                                continue
                        else:
                            raise ValueError("Invalid token or token not in expected position")
                    # Generate binary and hexadecimal instructions
                    binary_instruction = func7 + format(imm, '05b') + format(rs1, '05b') + func3 + format(rd, '05b') + opcode
                    binary_instruction_doc.write(binary_instruction + '\n')
                    hex_instruction = hex(int(binary_instruction, 2))
                    hex_instruction_doc.write(hex_instruction + '\n')
                    pc += 4
        # Type L (Load)        
                elif parts[0] in type_l.Functions and len(parts) == 3:
                    # Parse the load instruction format
                    lexer = number_lexer()
                    parts[2] = parts[2].strip()
                    # Check if parts[2] contains a variable and replace it with its address
                    if parts[2] in lexer.tokenize(parts[2]):
                        parts[2] = str(parts[2])+'('+'x0'+')'
                        
                    parts3=parts[2].replace(')', ' ').replace('(', ' ').split()
                    if len(parts3)==2:
                        line=parts[0]+' '+parts[1]+' '+parts3[0]+' '+parts3[1]+' '
                    else:
                        raise ValueError("Invalid load instruction format")
                    # Tokenize the line using the lexer for load instructions
                    lexer = lexer_load()
                    i = 0
                    for tok in lexer.tokenize(line):
                        # Extract function codes and opcode for the instruction
                        if tok.type == 'INSTRUCTION' and tok.value in type_l.Functions and tok.value == parts[0]:
                            func3 = type_l.Functions[tok.value][1]
                            opcode = type_l.Functions[tok.value][0]
                        # Extract register values for rd and rs1
                        elif tok.type == 'REGISTER' and tok.value in register.register and (tok.value in parts[1] or tok.value in parts3[1]):
                            if i == 0:
                                rd = register.register[tok.value]
                            elif i == 1:
                                rs1 = register.register[tok.value]
                            i += 1
                        # Extract immediate value and handle range validation
                        elif tok.type == 'NUMBER' and tok.value in parts3[0]:
                            # Handle unsigned load instructions separately
                            if parts[0] == 'lhu' or parts[0] == 'lbu':
                                if tok.value.startswith('0x'):
                                    if 0 <= int(tok.value, 16) <= 0xFFF :
                                        imm = int(tok.value, 16)
                                    else:
                                        raise ValueError("Immediate value out of range for 12 bits")
                                elif 0 <= int(tok.value) <= 4095 :
                                    imm = int(tok.value)
                                else:
                                    raise ValueError("Immediate value out of range for 12 bits")
                            # Handle signed load instructions
                            else:
                                if tok.value.startswith('0x'):
                                    if 0 <= int(tok.value, 16) <= 0xFFF :
                                        if int(tok.value, 16) > 0x7FF:
                                            imm = two_complement(int(tok.value, 16), 12)
                                        else:
                                            imm = int(tok.value, 16)
                                    else:
                                        raise ValueError("Immediate value out of range for 12 bits")
                                elif -2048 <= int(tok.value) <= 2047 :
                                    if int(tok.value) < 0:
                                        imm = two_complement(int(tok.value), 12)
                                    else:
                                        imm = int(tok.value)
                                else:
                                    raise ValueError("Immediate value out of range for 12 bits")
                        elif tok.type in ",":
                            continue
                        else:
                            raise ValueError("Invalid token or token not in expected position")
                    # Generate binary and hexadecimal instructions
                    binary_instruction = format(imm, '012b') + format(rs1, '05b') + func3 + format(rd, '05b') + opcode
                    binary_instruction_doc.write(binary_instruction + '\n')
                    hex_instruction = hex(int(binary_instruction, 2))
                    hex_instruction_doc.write(hex_instruction + '\n')
                    pc += 4
        # Type S (Store)
                elif parts[0] in type_s.Functions and len(parts) == 3:
                    # Parse the store instruction format
                    parts3=parts[2].replace(')', ' ').replace('(', ' ').split()
                    if len(parts3)==2:
                        line=parts[0]+' '+parts[1]+' '+parts3[0]+' '+parts3[1]+' '
                    else:
                        raise ValueError("Invalid load instruction format")
                    # Tokenize the line using the lexer for store instructions
                    lexer = lexer_store()
                    i = 0
                    for tok in lexer.tokenize(line):
                        # Extract function codes and opcode for the instruction
                        if tok.type == 'INSTRUCTION' and tok.value in type_s.Functions and tok.value == parts[0]:
                            func3 = type_s.Functions[tok.value][1]
                            opcode = type_s.Functions[tok.value][0]
                        elif tok.type == 'REGISTER' and tok.value in register.register and (tok.value in parts[1] or tok.value in parts3[1]):
                            if i == 0:
                                rs2 = register.register[tok.value]
                            elif i == 1:
                                rs1 = register.register[tok.value]
                            i += 1
                        # Extract immediate value and handle range validation
                        elif tok.type == 'NUMBER' and tok.value in parts3[0]:
                            if tok.value.startswith('0x'):
                                if 0 <= int(tok.value, 16) <= 0xFFF :
                                    if int(tok.value, 16) > 0x7FF:
                                        imm = two_complement(int(tok.value, 16), 12)
                                    else:
                                        imm = int(tok.value, 16)
                                else:
                                    raise ValueError("Immediate value out of range for 12 bits")
                            elif -2048 <= int(tok.value) <= 2047 :
                                if int(tok.value) < 0:
                                    imm = two_complement(int(tok.value), 12)
                                else:
                                    imm = int(tok.value)
                            else:
                                raise ValueError("Immediate value out of range for 12 bits")
                        elif tok.type in ",":
                            continue
                        else:
                            raise ValueError("Invalid token or token not in expected position")
                        
                    # Split immediate value into two parts for S-type instruction format
                    imm_11_5 = (imm >> 5) & 0x7F
                    imm_4_0 = imm & 0x1F
                    binary_instruction = format(imm_11_5, '07b') + format(rs2, '05b') + format(rs1, '05b') + func3 + format(imm_4_0, '05b') + opcode
                    binary_instruction_doc.write(binary_instruction + '\n')
                    hex_instruction = hex(int(binary_instruction, 2))
                    hex_instruction_doc.write(hex_instruction + '\n')
                    pc += 4
        # Type B (Branch)
                elif parts[0] in type_b.Functions and len(parts) == 4:
                    # Tokenize the line using the lexer for branch instructions
                    lexer = lexer_branch()
                    i = 0
                    for tok in lexer.tokenize(line):
                        # Extract function codes and opcode for the instruction
                        if tok.type == 'INSTRUCTION' and tok.value in type_b.Functions and tok.value == parts[0]:
                            func3 = type_b.Functions[tok.value][1]
                            opcode = type_b.Functions[tok.value][0]
                        # Extract register values for rs1 and rs2
                        elif tok.type == 'REGISTER' and tok.value in register.register and (tok.value in parts[1] or tok.value in parts[2]):
                            if i == 0:
                                rs1 = register.register[tok.value]
                            elif i == 1:
                                rs2 = register.register[tok.value]
                            i += 1
                        # Extract label and calculate branch target address
                        elif tok.type == 'LABEL' and tok.value in parts[3]:
                            if tok.value in labels:
                                imm = labels[tok.value] - pc
                                # Handle unsigned branch instructions separately
                                if parts[0] == 'bltu' or parts[0] == 'bgeu':
                                    if imm < 0:
                                        raise ValueError("Branch target address must be non-negative for unsigned branches")
                                    else:
                                        if imm % 2 != 0 or not (0 <= imm <= 8192):
                                            raise ValueError("Branch target address must be even and within range for 13 bits")
                                        else:
                                            imm = imm
                                # Handle signed branch instructions
                                else:
                                    if imm % 2 != 0 or not (-4096 <= imm <= 4094):
                                        raise ValueError("Branch target address must be even and within range for 13 bits")
                                    else:
                                        if imm < 0:
                                            imm = two_complement(imm, 13)
                                        else:
                                            imm = imm
                            else:
                                raise ValueError(f"Undefined label: {tok.value}")
                        elif tok.type in ",":
                            continue
                        else:
                            raise ValueError("Invalid token or token not in expected position")
                    # Split immediate value into parts for B-type instruction format
                    imm_12 = (imm >> 12) & 0x1
                    imm_10_5 = (imm >> 5) & 0x3F
                    imm_4_1 = (imm >> 1) & 0xF
                    imm_11 = (imm >> 11) & 0x1
                    binary_instruction = format(imm_12, '01b') + format(imm_10_5, '06b') + format(rs2, '05b') + format(rs1, '05b') + func3 + format(imm_4_1, '04b') + format(imm_11, '01b') + opcode
                    binary_instruction_doc.write(binary_instruction + '\n')
                    hex_instruction = hex(int(binary_instruction, 2))
                    hex_instruction_doc.write(hex_instruction + '\n')
                    pc += 4
        # Type J (Jump)
                elif parts[0] in type_j.Functions and len(parts) == 3:
                    # Tokenize the line using the lexer for jump instructions
                    lexer = lexer_jtype()
                    i = 0
                    for tok in lexer.tokenize(line):
                        # Extract opcode for the instruction
                        if tok.type == 'INSTRUCTION' and tok.value in type_j.Functions and tok.value == parts[0]:
                            opcode = type_j.Functions[tok.value][0]
                        # Extract register value for rd
                        elif tok.type == 'REGISTER' and tok.value in register.register and tok.value in parts[1]:
                            if i == 0:
                                rd = register.register[tok.value]
                            i += 1
                        # Extract label and calculate jump target address
                        elif tok.type == 'LABEL' and tok.value in parts[2]:
                            if tok.value in labels:
                                imm = labels[tok.value] - pc
                                if imm % 2 != 0 or not (-1048576 <= imm <= 1048574):
                                    raise ValueError("Jump target address must be even and within range for 21 bits")
                                else:
                                    if imm < 0:
                                        imm = two_complement(imm, 21)
                                    else:
                                        imm = imm
                            else:
                                raise ValueError(f"Undefined label: {tok.value}")
                        elif tok.type in ",":
                            continue
                        else:
                            raise ValueError("Invalid token or token not in expected position")
                    # Split immediate value into parts for J-type instruction format
                    imm_20 = (imm >> 20) & 0x1
                    imm_10_1 = (imm >> 1) & 0x3FF
                    imm_11 = (imm >> 11) & 0x1
                    imm_19_12 = (imm >> 12) & 0xFF
                    binary_instruction = format(imm_20, '01b') + format(imm_10_1, '010b') + format(imm_11, '01b') + format(imm_19_12, '08b') + format(rd, '05b') + opcode
                    binary_instruction_doc.write(binary_instruction + '\n')
                    hex_instruction = hex(int(binary_instruction, 2))
                    hex_instruction_doc.write(hex_instruction + '\n')
                    pc += 4
        # Type JR (Jump Register)
                elif parts[0] in type_jr.Functions and (len(parts) == 4 or len(parts) == 3):
                    # Parse the jump register instruction format
                    lexer = lexer_jrtype()
                    i = 0
                    # Handle both formats of JR instructions
                    if len(parts) == 3:
                        parts3=parts[2].replace(')', ' ').replace('(', ' ').split()
                        if len(parts3)==2:
                            line=parts[0]+' '+parts[1]+' '+parts3[0]+' '+parts3[1]+' '
                        else:
                            raise ValueError("Invalid load instruction format")
                        for tok in lexer.tokenize(line):
                            # Extract function codes and opcode for the instruction
                            if tok.type == 'INSTRUCTION' and tok.value in type_jr.Functions and tok.value == parts[0]:
                                func3 = type_jr.Functions[tok.value][1]
                                opcode = type_jr.Functions[tok.value][0]
                            # Extract register values for rd and rs1
                            elif tok.type == 'REGISTER' and tok.value in register.register and (tok.value in parts[1] or tok.value in parts3[1]):
                                if i == 0:
                                    rd = register.register[tok.value]
                                elif i == 1:
                                    rs1 = register.register[tok.value]
                                i += 1
                            # Extract immediate value and handle range validation
                            elif tok.type == 'NUMBER' and tok.value in parts3[0]:
                                if tok.value.startswith('0x'):
                                    if 0 <= int(tok.value, 16) <= 0xFFF :
                                        if int(tok.value, 16) > 0x7FF:
                                            imm = two_complement(int(tok.value, 16), 12)
                                        else:
                                            imm = int(tok.value, 16)
                                    else:
                                        raise ValueError("Immediate value out of range for 12 bits")
                                elif -2048 <= int(tok.value) <= 2047 :
                                    if int(tok.value) < 0:
                                        imm = two_complement(int(tok.value), 12)
                                    else:
                                        imm = int(tok.value)
                                else:
                                    raise ValueError("Immediate value out of range for 12 bits")
                            elif tok.type in ",":
                                continue
                            else:
                                raise ValueError("Invalid token or token not in expected position")
                        # Combine all parts into the final binary instruction
                        binary_instruction = format(imm, '012b') + format(rs1, '05b') + func3 + format(rd, '05b') + opcode
                    elif len(parts) == 4:
                        for tok in lexer.tokenize(line):
                            # Extract function codes and opcode for the instruction
                            if tok.type == 'INSTRUCTION' and tok.value in type_jr.Functions and tok.value == parts[0]:
                                func3 = type_jr.Functions[tok.value][1]
                                opcode = type_jr.Functions[tok.value][0]
                            # Extract register values for rd and rs1
                            elif tok.type == 'REGISTER' and tok.value in register.register and (tok.value in parts[1] or tok.value in parts[2]):
                                if i == 0:
                                    rd = register.register[tok.value]
                                elif i == 1:
                                    rs1 = register.register[tok.value]
                                i += 1
                            # Extract immediate value and handle range validation
                            elif tok.type == 'NUMBER' and tok.value in parts[3]:
                                if tok.value.startswith('0x'):
                                    if 0 <= int(tok.value, 16) <= 0xFFF :
                                        if int(tok.value, 16) > 0x7FF:
                                            imm = two_complement(int(tok.value, 16), 12)
                                        else:
                                            imm = int(tok.value, 16)
                                    else:
                                        raise ValueError("Immediate value out of range for 12 bits")
                                elif -2048 <= int(tok.value) <= 2047 :
                                    if int(tok.value) < 0:
                                        imm = two_complement(int(tok.value), 12)
                                    else:
                                        imm = int(tok.value)
                                else:
                                    raise ValueError("Immediate value out of range for 12 bits")
                            elif tok.type in ",":
                                continue
                            else:
                                raise ValueError("Invalid token or token not in expected position")
                        # Generate binary and hexadecimal instructions
                        binary_instruction = format(imm, '012b') + format(rs1, '05b') + func3 + format(rd, '05b') + opcode
                    # Write the binary and hexadecimal instructions
                    binary_instruction_doc.write(binary_instruction + '\n')
                    hex_instruction = hex(int(binary_instruction, 2))
                    hex_instruction_doc.write(hex_instruction + '\n')
                    pc += 4
        # Type U (Upper Immediate)
                elif parts[0] in type_u.Functions and len(parts) == 3:
                    # Tokenize the line using the lexer for U-type instructions
                    lexer = lexer_utype()
                    i = 0
                    for tok in lexer.tokenize(line):
                        # Extract opcode for the instruction
                        if tok.type == 'INSTRUCTION' and tok.value in type_u.Functions and tok.value == parts[0]:
                            opcode = type_u.Functions[tok.value][0]
                        # Extract register value for rd
                        elif tok.type == 'REGISTER' and tok.value in register.register and tok.value in parts[1]:
                            if i == 0:
                                rd = register.register[tok.value]
                            i += 1
                        # Extract immediate value and handle range validation
                        elif tok.type == 'NUMBER' and tok.value in parts[2]:
                            if tok.value.startswith('0x'):
                                if 0 <= int(tok.value, 16) <= 0xFFFFF :
                                    imm = int(tok.value, 16)
                                else:
                                    raise ValueError("Immediate value out of range for 20 bits")
                            elif -524288 <= int(tok.value) <= 524287 :
                                if int(tok.value) < 0:
                                    imm = two_complement(int(tok.value), 20)
                                else:
                                    imm = int(tok.value)
                            else:
                                raise ValueError("Immediate value out of range for 20 bits")
                        elif tok.type in ",":
                            continue
                        else:
                            raise ValueError("Invalid token or token not in expected position")
                    # Generate binary and hexadecimal instructions
                    binary_instruction = format(imm, '020b') + format(rd, '05b') + opcode
                    binary_instruction_doc.write(binary_instruction + '\n')
                    hex_instruction = hex(int(binary_instruction, 2))
                    hex_instruction_doc.write(hex_instruction + '\n')
                    pc += 4
        # Type Ecall (Environment Call)
                elif parts[0] in type_ecall.Functions and len(parts) == 1:
                    lexer = lexer_ecall()
                    for tok in lexer.tokenize(line):
                        # Extract instruction details for ecall
                        if tok.type == 'INSTRUCTION' and tok.value in type_ecall.Functions and tok.value == parts[0]:
                            imm = int(type_ecall.Functions[tok.value][2])
                            func3 = type_ecall.Functions[tok.value][1]
                            opcode = type_ecall.Functions[tok.value][0]
                    # Generate binary and hexadecimal instructions    
                    binary_instruction = format(imm, '012b') + '00000' + func3 + '00000' + opcode
                    binary_instruction_doc.write(binary_instruction + '\n')
                    hex_instruction = hex(int(binary_instruction, 2))
                    hex_instruction_doc.write(hex_instruction + '\n')
                    pc += 4
        # Pseudoinstructions
                elif parts[0] in pseudoinstruction.Functions:
                    # nop pseudoinstruction
                    if parts[0] == 'nop' and len(parts) == 1:
                        # nop is translated to addi x0, x0, 0
                        real_line = 'addi x0, x0, 0'
                        lexer = lexer_itype()
                        i = 0
                        # Tokenize the translated nop instruction
                        for tok in lexer.tokenize(real_line):
                            # Extract function codes and opcode for the instruction
                            if tok.type == 'INSTRUCTION' and tok.value in type_i.Functions :
                                func3 = type_i.Functions[tok.value][1]
                                opcode = type_i.Functions[tok.value][0]
                            # Extract register values for rd and rs1
                            elif tok.type == 'REGISTER' and tok.value in register.register:
                                if i == 0:
                                    rd = register.register[tok.value]
                                elif i == 1:
                                    rs1 = register.register[tok.value]
                                i += 1
                            # Immediate value is always 0 for nop
                            elif tok.type == 'NUMBER' and tok.value == '0':
                                imm = 0
                            elif tok.type in ",":
                                continue
                            else:
                                raise ValueError("Invalid token or token not in expected position")
                        # Generate binary and hexadecimal instructions
                        binary_instruction = format(imm, '012b') + format(rs1, '05b') + func3 + format(rd, '05b') + opcode
                        binary_instruction_doc.write(binary_instruction + '\n')
                        hex_instruction = hex(int(binary_instruction, 2))
                        hex_instruction_doc.write(hex_instruction + '\n')
                        pc += 4
                    # mv pseudoinstruction
                    elif parts[0] == 'mv' and len(parts) == 3:
                        # mv rd, rs is translated to addi rd, rs, 0
                        real_line = f'addi {parts[1]}, {parts[2]}, 0'
                        lexer = lexer_itype()
                        i = 0
                        # Tokenize the translated mv instruction
                        for tok in lexer.tokenize(real_line):
                            # Extract function codes and opcode for the instruction
                            if tok.type == 'INSTRUCTION' and tok.value in type_i.Functions :
                                func3 = type_i.Functions[tok.value][1]
                                opcode = type_i.Functions[tok.value][0]
                            # Extract register values for rd and rs1
                            elif tok.type == 'REGISTER' and tok.value in register.register and (tok.value in parts[1] or tok.value in parts[2]):
                                if i == 0:
                                    rd = register.register[tok.value]
                                elif i == 1:
                                    rs1 = register.register[tok.value]
                                i += 1
                            # Immediate value is always 0 for mv
                            elif tok.type == 'NUMBER':
                                imm = 0
                            elif tok.type in ",":
                                continue
                            else:
                                raise ValueError("Invalid token or token not in expected position")
                        # Generate binary and hexadecimal instructions
                        binary_instruction = format(imm, '012b') + format(rs1, '05b') + func3 + format(rd, '05b') + opcode
                        binary_instruction_doc.write(binary_instruction + '\n')
                        hex_instruction = hex(int(binary_instruction, 2))
                        hex_instruction_doc.write(hex_instruction + '\n')
                        pc += 4
                    # not pseudoinstruction
                    elif parts[0] == 'not' and len(parts) == 3:
                        # not rd, rs is translated to xori rd, rs, -1
                        real_line = f'xori {parts[1]}, {parts[2]}, -1'
                        lexer = lexer_itype()
                        i = 0
                        # Tokenize the translated not instruction
                        for tok in lexer.tokenize(real_line):
                            # Extract function codes and opcode for the instruction
                            if tok.type == 'INSTRUCTION' and tok.value in type_i.Functions :
                                func3 = type_i.Functions[tok.value][1]
                                opcode = type_i.Functions[tok.value][0]
                            # Extract register values for rd and rs1
                            elif tok.type == 'REGISTER' and tok.value in register.register and (tok.value in parts[1] or tok.value in parts[2]):
                                if i == 0:
                                    rd = register.register[tok.value]
                                elif i == 1:
                                    rs1 = register.register[tok.value]
                                i += 1
                            # Immediate value is always -1 for not
                            elif tok.type == 'NUMBER' :
                                imm = two_complement(-1, 12)
                            elif tok.type in ",":
                                continue
                            else:
                                raise ValueError("Invalid token or token not in expected position")
                        # Generate binary and hexadecimal instructions
                        binary_instruction = format(imm, '012b') + format(rs1, '05b') + func3 + format(rd, '05b') + opcode
                        binary_instruction_doc.write(binary_instruction + '\n')
                        hex_instruction = hex(int(binary_instruction, 2))
                        hex_instruction_doc.write(hex_instruction + '\n')
                        pc += 4
                    # neg pseudoinstruction
                    elif parts[0] == 'neg' and len(parts) == 3:
                        # neg rd, rs is translated to sub rd, x0, rs
                        real_line = f'sub {parts[1]}, x0, {parts[2]}'
                        lexer = lexer_rtype()
                        i = 0
                        # Tokenize the translated neg instruction
                        for tok in lexer.tokenize(real_line):
                            # Extract function codes and opcode for the instruction
                            if tok.type == 'INSTRUCTION' and tok.value in type_r.Functions :
                                func7 = type_r.Functions[tok.value][2]
                                func3 = type_r.Functions[tok.value][1]
                                opcode = type_r.Functions[tok.value][0]
                            # Extract register values for rd, rs1 and rs2
                            elif tok.type == 'REGISTER' and tok.value in register.register :
                                if i == 0:
                                    rd = register.register[tok.value]
                                elif i == 1:
                                    rs1 = register.register[tok.value]
                                elif i == 2:
                                    rs2 = register.register[tok.value]
                                i += 1
                            elif tok.type in ",":
                                continue
                            else:
                                raise ValueError("Invalid token or token not in expected position")
                        # Generate binary and hexadecimal instructions
                        binary_instruction = func7 + format(rs2, '05b') + format(rs1, '05b') + func3 + format(rd, '05b') + opcode
                        binary_instruction_doc.write(binary_instruction + '\n')
                        hex_instruction = hex(int(binary_instruction, 2))
                        hex_instruction_doc.write(hex_instruction + '\n')
                        pc += 4
                    # seqz pseudoinstruction
                    elif parts[0] == 'seqz' and len(parts) == 3:
                        # seqz rd, rs is translated to sltiu rd, rs, 1
                        real_line = f'sltiu {parts[1]}, {parts[2]}, 1'
                        lexer = lexer_itype()
                        i = 0
                        # Tokenize the translated seqz instruction
                        for tok in lexer.tokenize(real_line):
                            # Extract function codes and opcode for the instruction
                            if tok.type == 'INSTRUCTION' and tok.value in type_i.Functions :
                                func3 = type_i.Functions[tok.value][1]
                                opcode = type_i.Functions[tok.value][0]
                            # Extract register values for rd and rs1
                            elif tok.type == 'REGISTER' and tok.value in register.register :
                                if i == 0:
                                    rd = register.register[tok.value]
                                elif i == 1:
                                    rs1 = register.register[tok.value]
                                i += 1
                            # Immediate value is always 1 for seqz
                            elif tok.type == 'NUMBER' :
                                imm = 1
                            elif tok.type in ",":
                                continue
                            else:
                                raise ValueError("Invalid token or token not in expected position")
                        # Generate binary and hexadecimal instructions
                        binary_instruction = format(imm, '012b') + format(rs1, '05b') + func3 + format(rd, '05b') + opcode
                        binary_instruction_doc.write(binary_instruction + '\n')
                        hex_instruction = hex(int(binary_instruction, 2))
                        hex_instruction_doc.write(hex_instruction + '\n')
                        pc += 4
                    # snez pseudoinstruction
                    elif parts[0] == 'snez' and len(parts) == 3:
                        # snez rd, rs is translated to sltu rd, x0, rs
                        real_line = f'sltu {parts[1]}, x0, {parts[2]}'
                        lexer = lexer_rtype()
                        i = 0
                        for tok in lexer.tokenize(real_line):
                            # Extract function codes and opcode for the instruction
                            if tok.type == 'INSTRUCTION' and tok.value in type_r.Functions :
                                func7 = type_r.Functions[tok.value][2]
                                func3 = type_r.Functions[tok.value][1]
                                opcode = type_r.Functions[tok.value][0]
                            # Extract register values for rd, rs1 and rs2
                            elif tok.type == 'REGISTER' and tok.value in register.register :
                                if i == 0:
                                    rd = register.register[tok.value]
                                elif i == 1:
                                    rs1 = register.register[tok.value]
                                elif i == 2:
                                    rs2 = register.register[tok.value]
                                i += 1
                            elif tok.type in ",":
                                continue
                            else:
                                raise ValueError("Invalid token or token not in expected position")
                        # Generate binary and hexadecimal instructions
                        binary_instruction = func7 + format(rs2, '05b') + format(rs1, '05b') + func3 + format(rd, '05b') + opcode
                        binary_instruction_doc.write(binary_instruction + '\n')
                        hex_instruction = hex(int(binary_instruction, 2))
                        hex_instruction_doc.write(hex_instruction + '\n')
                        pc += 4
                    # sltz pseudoinstruction
                    elif parts[0] == 'sltz' and len(parts) == 3:
                        # sltz rd, rs is translated to slt rd, rs, x0
                        real_line = f'slt {parts[1]}, {parts[2]}, x0'
                        lexer = lexer_rtype()
                        i = 0
                        # Tokenize the translated sltz instruction
                        for tok in lexer.tokenize(real_line):
                            # Extract function codes and opcode for the instruction
                            if tok.type == 'INSTRUCTION' and tok.value in type_r.Functions :
                                func7 = type_r.Functions[tok.value][2]
                                func3 = type_r.Functions[tok.value][1]
                                opcode = type_r.Functions[tok.value][0]
                            # Extract register values for rd, rs1 and rs2
                            elif tok.type == 'REGISTER' and tok.value in register.register :
                                if i == 0:
                                    rd = register.register[tok.value]
                                elif i == 1:
                                    rs1 = register.register[tok.value]
                                elif i == 2:
                                    rs2 = register.register[tok.value]
                                i += 1
                            elif tok.type in ",":
                                continue
                            else:
                                raise ValueError("Invalid token or token not in expected position")
                        # Generate binary and hexadecimal instructions
                        binary_instruction = func7 + format(rs2, '05b') + format(rs1, '05b') + func3 + format(rd, '05b') + opcode
                        binary_instruction_doc.write(binary_instruction + '\n')
                        hex_instruction = hex(int(binary_instruction, 2))
                        hex_instruction_doc.write(hex_instruction + '\n')
                        pc += 4
                    # sgtz pseudoinstruction
                    elif parts[0] == 'sgtz' and len(parts) == 3:
                        # sgtz rd, rs is translated to slt rd, x0, rs
                        real_line = f'slt {parts[1]}, x0, {parts[2]}'
                        lexer = lexer_rtype()
                        i = 0
                        # Tokenize the translated sgtz instruction
                        for tok in lexer.tokenize(real_line):
                            # Extract function codes and opcode for the instruction
                            if tok.type == 'INSTRUCTION' and tok.value in type_r.Functions :
                                func7 = type_r.Functions[tok.value][2]
                                func3 = type_r.Functions[tok.value][1]
                                opcode = type_r.Functions[tok.value][0]
                            # Extract register values for rd, rs1 and rs2
                            elif tok.type == 'REGISTER' and tok.value in register.register :
                                if i == 0:
                                    rd = register.register[tok.value]
                                elif i == 1:
                                    rs1 = register.register[tok.value]
                                elif i == 2:
                                    rs2 = register.register[tok.value]
                                i += 1
                            elif tok.type in ",":
                                continue
                            else:
                                raise ValueError("Invalid token or token not in expected position")
                        # Generate binary and hexadecimal instructions
                        binary_instruction = func7 + format(rs2, '05b') + format(rs1, '05b') + func3 + format(rd, '05b') + opcode
                        binary_instruction_doc.write(binary_instruction + '\n')
                        hex_instruction = hex(int(binary_instruction, 2))
                        hex_instruction_doc.write(hex_instruction + '\n')
                        pc += 4
                    # beqz pseudoinstruction
                    elif parts[0] == 'beqz' and len(parts) == 3:
                        # beqz rs, label is translated to beq rs, x0, label
                        real_line = f'beq {parts[1]}, x0, {parts[2]}'
                        lexer = lexer_branch()
                        i = 0
                        # Tokenize the translated beqz instruction
                        for tok in lexer.tokenize(real_line):
                            # Extract function codes and opcode for the instruction
                            if tok.type == 'INSTRUCTION' and tok.value in type_b.Functions :
                                func3 = type_b.Functions[tok.value][1]
                                opcode = type_b.Functions[tok.value][0]
                            # Extract register values for rs1 and rs2
                            elif tok.type == 'REGISTER' and tok.value in register.register :
                                if i == 0:
                                    rs1 = register.register[tok.value]
                                elif i == 1:
                                    rs2 = register.register[tok.value]
                                i += 1
                            # Extract label and calculate branch target address
                            elif tok.type == 'LABEL' :
                                if tok.value in labels:
                                    imm = labels[tok.value] - pc
                                    if imm % 2 != 0 or not (-4096 <= imm <= 4094):
                                        raise ValueError("Branch target address must be even and within range for 13 bits")
                                    else:
                                        if imm < 0:
                                            imm = two_complement(imm, 13)
                                        else:
                                            imm = imm
                                else:
                                    raise ValueError(f"Undefined label: {tok.value}")
                            elif tok.type in ",":
                                continue
                            else:
                                raise ValueError("Invalid token or token not in expected position")
                        # Split immediate value into parts for B-type instruction format
                        imm_12 = (imm >> 12) & 0x1
                        imm_10_5 = (imm >> 5) & 0x3F
                        imm_4_1 = (imm >> 1) & 0xF
                        imm_11 = (imm >> 11) & 0x1
                        binary_instruction = format(imm_12, '01b') + format(imm_10_5, '06b') + format(rs2, '05b') + format(rs1, '05b') + func3 + format(imm_4_1, '04b') + format(imm_11, '01b') + opcode
                        binary_instruction_doc.write(binary_instruction + '\n')
                        hex_instruction = hex(int(binary_instruction, 2))
                        hex_instruction_doc.write(hex_instruction + '\n')
                        pc += 4
                    # bnez pseudoinstruction
                    elif parts[0] == 'bnez' and len(parts) == 3:
                        real_line = f'bne {parts[1]}, x0, {parts[2]}'
                        lexer = lexer_branch()
                        i = 0
                        # Tokenize the translated bnez instruction
                        for tok in lexer.tokenize(real_line):
                            # Extract function codes and opcode for the instruction
                            if tok.type == 'INSTRUCTION' and tok.value in type_b.Functions :
                                func3 = type_b.Functions[tok.value][1]
                                opcode = type_b.Functions[tok.value][0]
                            # Extract register values for rs1 and rs2
                            elif tok.type == 'REGISTER' and tok.value in register.register :
                                if i == 0:
                                    rs1 = register.register[tok.value]
                                elif i == 1:
                                    rs2 = register.register[tok.value]
                                i += 1
                            # Extract label and calculate branch target address
                            elif tok.type == 'LABEL' :
                                if tok.value in labels:
                                    imm = labels[tok.value] - pc
                                    if imm % 2 != 0 or not (-4096 <= imm <= 4094):
                                        raise ValueError("Branch target address must be even and within range for 13 bits")
                                    else:
                                        if imm < 0:
                                            imm = two_complement(imm, 13)
                                        else:
                                            imm = imm
                                else:
                                    raise ValueError(f"Undefined label: {tok.value}")
                            elif tok.type in ",":
                                continue
                            else:
                                raise ValueError("Invalid token or token not in expected position")
                        # Split immediate value into parts for B-type instruction format
                        imm_12 = (imm >> 12) & 0x1
                        imm_10_5 = (imm >> 5) & 0x3F
                        imm_4_1 = (imm >> 1) & 0xF
                        imm_11 = (imm >> 11) & 0x1
                        binary_instruction = format(imm_12, '01b') + format(imm_10_5, '06b') + format(rs2, '05b') + format(rs1, '05b') + func3 + format(imm_4_1, '04b') + format(imm_11, '01b') + opcode
                        binary_instruction_doc.write(binary_instruction + '\n')
                        hex_instruction = hex(int(binary_instruction, 2))
                        hex_instruction_doc.write(hex_instruction + '\n')
                        pc += 4
                    # blez pseudoinstruction
                    elif parts[0] == 'blez' and len(parts) == 3:
                        # blez rs, label is translated to bge x0, rs, label
                        real_line = f'bge x0, {parts[1]}, {parts[2]}'
                        lexer = lexer_branch()
                        i = 0
                        # Tokenize the translated blez instruction
                        for tok in lexer.tokenize(real_line):
                            # Extract function codes and opcode for the instruction
                            if tok.type == 'INSTRUCTION' and tok.value in type_b.Functions :
                                func3 = type_b.Functions[tok.value][1]
                                opcode = type_b.Functions[tok.value][0]
                            # Extract register values for rs1 and rs2
                            elif tok.type == 'REGISTER' and tok.value in register.register :
                                if i == 0:
                                    rs1 = register.register[tok.value]
                                elif i == 1:
                                    rs2 = register.register[tok.value]
                                i += 1
                            # Extract label and calculate branch target address
                            elif tok.type == 'LABEL' :
                                if tok.value in labels:
                                    imm = labels[tok.value] - pc
                                    if imm % 2 != 0 or not (-4096 <= imm <= 4094):
                                        raise ValueError("Branch target address must be even and within range for 13 bits")
                                    else:
                                        if imm < 0:
                                            imm = two_complement(imm, 13)
                                        else:
                                            imm = imm
                                else:
                                    raise ValueError(f"Undefined label: {tok.value}")
                            elif tok.type in ",":
                                continue
                            else:
                                raise ValueError("Invalid token or token not in expected position")
                        # Split immediate value into parts for B-type instruction format
                        imm_12 = (imm >> 12) & 0x1
                        imm_10_5 = (imm >> 5) & 0x3F
                        imm_4_1 = (imm >> 1) & 0xF
                        imm_11 = (imm >> 11) & 0x1
                        binary_instruction = format(imm_12, '01b') + format(imm_10_5, '06b') + format(rs2, '05b') + format(rs1, '05b') + func3 + format(imm_4_1, '04b') + format(imm_11, '01b') + opcode
                        binary_instruction_doc.write(binary_instruction + '\n')
                        hex_instruction = hex(int(binary_instruction, 2))
                        hex_instruction_doc.write(hex_instruction + '\n')
                        pc += 4
                    # bgez pseudoinstruction
                    elif parts[0] == 'bgez' and len(parts) == 3:
                        # bgez rs, label is translated to bge rs, x0, label
                        real_line = f'bge {parts[1]}, x0, {parts[2]}'
                        lexer = lexer_branch()
                        i = 0
                        # Tokenize the translated bgez instruction
                        for tok in lexer.tokenize(real_line):
                            # Extract function codes and opcode for the instruction
                            if tok.type == 'INSTRUCTION' and tok.value in type_b.Functions :
                                func3 = type_b.Functions[tok.value][1]
                                opcode = type_b.Functions[tok.value][0]
                            # Extract register values for rs1 and rs2
                            elif tok.type == 'REGISTER' and tok.value in register.register :
                                if i == 0:
                                    rs1 = register.register[tok.value]
                                elif i == 1:
                                    rs2 = register.register[tok.value]
                                i += 1
                            # Extract label and calculate branch target address
                            elif tok.type == 'LABEL' :
                                if tok.value in labels:
                                    imm = labels[tok.value] - pc
                                    if imm % 2 != 0 or not (-4096 <= imm <= 4094):
                                        raise ValueError("Branch target address must be even and within range for 13 bits")
                                    else:
                                        if imm < 0:
                                            imm = two_complement(imm, 13)
                                        else:
                                            imm = imm
                                else:
                                    raise ValueError(f"Undefined label: {tok.value}")
                            elif tok.type in ",":
                                continue
                            else:
                                raise ValueError("Invalid token or token not in expected position")
                        # Split immediate value into parts for B-type instruction format
                        imm_12 = (imm >> 12) & 0x1
                        imm_10_5 = (imm >> 5) & 0x3F
                        imm_4_1 = (imm >> 1) & 0xF
                        imm_11 = (imm >> 11) & 0x1
                        binary_instruction = format(imm_12, '01b') + format(imm_10_5, '06b') + format(rs2, '05b') + format(rs1, '05b') + func3 + format(imm_4_1, '04b') + format(imm_11, '01b') + opcode
                        binary_instruction_doc.write(binary_instruction + '\n')
                        hex_instruction = hex(int(binary_instruction, 2))
                        hex_instruction_doc.write(hex_instruction + '\n')
                        pc += 4
                    # bltz pseudoinstruction
                    elif parts[0] == 'bltz' and len(parts) == 3:
                        # bltz rs, label is translated to blt rs, x0, label
                        real_line = f'blt {parts[1]}, x0, {parts[2]}'
                        lexer = lexer_branch()
                        i = 0
                        # Tokenize the translated bltz instruction
                        for tok in lexer.tokenize(real_line):
                            # Extract function codes and opcode for the instruction
                            if tok.type == 'INSTRUCTION' and tok.value in type_b.Functions :
                                func3 = type_b.Functions[tok.value][1]
                                opcode = type_b.Functions[tok.value][0]
                            # Extract register values for rs1 and rs2
                            elif tok.type == 'REGISTER' and tok.value in register.register :
                                if i == 0:
                                    rs1 = register.register[tok.value]
                                elif i == 1:
                                    rs2 = register.register[tok.value]
                                i += 1
                            # Extract label and calculate branch target address
                            elif tok.type == 'LABEL' :
                                if tok.value in labels:
                                    imm = labels[tok.value] - pc
                                    if imm % 2 != 0 or not (-4096 <= imm <= 4094):
                                        raise ValueError("Branch target address must be even and within range for 13 bits")
                                    else:
                                        if imm < 0:
                                            imm = two_complement(imm, 13)
                                        else:
                                            imm = imm
                                else:
                                    raise ValueError(f"Undefined label: {tok.value}")
                            elif tok.type in ",":
                                continue
                            else:
                                raise ValueError("Invalid token or token not in expected position")
                        # Split immediate value into parts for B-type instruction format
                        imm_12 = (imm >> 12) & 0x1
                        imm_10_5 = (imm >> 5) & 0x3F
                        imm_4_1 = (imm >> 1) & 0xF
                        imm_11 = (imm >> 11) & 0x1
                        binary_instruction = format(imm_12, '01b') + format(imm_10_5, '06b') + format(rs2, '05b') + format(rs1, '05b') + func3 + format(imm_4_1, '04b') + format(imm_11, '01b') + opcode
                        binary_instruction_doc.write(binary_instruction + '\n')
                        hex_instruction = hex(int(binary_instruction, 2))
                        hex_instruction_doc.write(hex_instruction + '\n')
                        pc += 4
                    # bgtz pseudoinstruction
                    elif parts[0] == 'bgtz' and len(parts) == 3:
                        # bgtz rs, label is translated to blt x0, rs, label
                        real_line = f'blt x0, {parts[1]}, {parts[2]}'
                        lexer = lexer_branch()
                        i = 0
                        # Tokenize the translated bgtz instruction
                        for tok in lexer.tokenize(real_line):
                            # Extract function codes and opcode for the instruction
                            if tok.type == 'INSTRUCTION' and tok.value in type_b.Functions :
                                func3 = type_b.Functions[tok.value][1]
                                opcode = type_b.Functions[tok.value][0]
                            # Extract register values for rs1 and rs2
                            elif tok.type == 'REGISTER' and tok.value in register.register :
                                if i == 0:
                                    rs1 = register.register[tok.value]
                                elif i == 1:
                                    rs2 = register.register[tok.value]
                                i += 1
                            # Extract label and calculate branch target address
                            elif tok.type == 'LABEL' :
                                if tok.value in labels:
                                    imm = labels[tok.value] - pc
                                    if imm % 2 != 0 or not (-4096 <= imm <= 4094):
                                        raise ValueError("Branch target address must be even and within range for 13 bits")
                                    else:
                                        if imm < 0:
                                            imm = two_complement(imm, 13)
                                        else:
                                            imm = imm
                                else:
                                    raise ValueError(f"Undefined label: {tok.value}")
                            elif tok.type in ",":
                                continue
                            else:
                                raise ValueError("Invalid token or token not in expected position")
                        # Split immediate value into parts for B-type instruction format
                        imm_12 = (imm >> 12) & 0x1
                        imm_10_5 = (imm >> 5) & 0x3F
                        imm_4_1 = (imm >> 1) & 0xF
                        imm_11 = (imm >> 11) & 0x1
                        binary_instruction = format(imm_12, '01b') + format(imm_10_5, '06b') + format(rs2, '05b') + format(rs1, '05b') + func3 + format(imm_4_1, '04b') + format(imm_11, '01b') + opcode
                        binary_instruction_doc.write(binary_instruction + '\n')
                        hex_instruction = hex(int(binary_instruction, 2))
                        hex_instruction_doc.write(hex_instruction + '\n')
                        pc += 4
                    # bgt pseudoinstruction
                    elif parts[0] == 'bgt' and len(parts) == 4:
                        # bgt rs1, rs2, label is translated to blt rs2, rs1, label
                        real_line = f'blt {parts[2]}, {parts[1]}, {parts[3]}'
                        lexer = lexer_branch()
                        i = 0
                        # Tokenize the translated bgt instruction
                        for tok in lexer.tokenize(real_line):
                            # Extract function codes and opcode for the instruction
                            if tok.type == 'INSTRUCTION' and tok.value in type_b.Functions :
                                func3 = type_b.Functions[tok.value][1]
                                opcode = type_b.Functions[tok.value][0]
                            # Extract register values for rs1 and rs2
                            elif tok.type == 'REGISTER' and tok.value in register.register :
                                if i == 0:
                                    rs1 = register.register[tok.value]
                                elif i == 1:
                                    rs2 = register.register[tok.value]
                                i += 1
                            # Extract label and calculate branch target address
                            elif tok.type == 'LABEL':
                                if tok.value in labels:
                                    imm = labels[tok.value] - pc
                                    if imm % 2 != 0 or not (-4096 <= imm <= 4094):
                                        raise ValueError("Branch target address must be even and within range for 13 bits")
                                    else:
                                        if imm < 0:
                                            imm = two_complement(imm, 13)
                                        else:
                                            imm = imm
                                else:
                                    raise ValueError(f"Undefined label: {tok.value}")
                            elif tok.type in ",":
                                continue
                            else:
                                raise ValueError("Invalid token or token not in expected position")
                        # Split immediate value into parts for B-type instruction format
                        imm_12 = (imm >> 12) & 0x1
                        imm_10_5 = (imm >> 5) & 0x3F
                        imm_4_1 = (imm >> 1) & 0xF
                        imm_11 = (imm >> 11) & 0x1
                        binary_instruction = format(imm_12, '01b') + format(imm_10_5, '06b') + format(rs2, '05b') + format(rs1, '05b') + func3 + format(imm_4_1, '04b') + format(imm_11, '01b') + opcode
                        binary_instruction_doc.write(binary_instruction + '\n')
                        hex_instruction = hex(int(binary_instruction, 2))
                        hex_instruction_doc.write(hex_instruction + '\n')
                        pc += 4
                    # ble pseudoinstruction
                    elif parts[0] == 'ble' and len(parts) == 4:
                        # ble rs1, rs2, label is translated to bge rs2, rs1, label
                        real_line = f'bge {parts[2]}, {parts[1]}, {parts[3]}'
                        lexer = lexer_branch()
                        i = 0
                        # Tokenize the translated ble instruction
                        for tok in lexer.tokenize(real_line):
                            # Extract function codes and opcode for the instruction
                            if tok.type == 'INSTRUCTION' and tok.value in type_b.Functions :
                                func3 = type_b.Functions[tok.value][1]
                                opcode = type_b.Functions[tok.value][0]
                            # Extract register values for rs1 and rs2
                            elif tok.type == 'REGISTER' and tok.value in register.register :
                                if i == 0:
                                    rs1 = register.register[tok.value]
                                elif i == 1:
                                    rs2 = register.register[tok.value]
                                i += 1
                            # Extract label and calculate branch target address
                            elif tok.type == 'LABEL' :
                                if tok.value in labels:
                                    imm = labels[tok.value] - pc
                                    if imm % 2 != 0 or not (-4096 <= imm <= 4094):
                                        raise ValueError("Branch target address must be even and within range for 13 bits")
                                    else:
                                        if imm < 0:
                                            imm = two_complement(imm, 13)
                                        else:
                                            imm = imm
                                else:
                                    raise ValueError(f"Undefined label: {tok.value}")
                            elif tok.type in ",":
                                continue
                            else:
                                raise ValueError("Invalid token or token not in expected position")
                        # Split immediate value into parts for B-type instruction format
                        imm_12 = (imm >> 12) & 0x1
                        imm_10_5 = (imm >> 5) & 0x3F
                        imm_4_1 = (imm >> 1) & 0xF
                        imm_11 = (imm >> 11) & 0x1
                        binary_instruction = format(imm_12, '01b') + format(imm_10_5, '06b') + format(rs2, '05b') + format(rs1, '05b') + func3 + format(imm_4_1, '04b') + format(imm_11, '01b') + opcode
                        binary_instruction_doc.write(binary_instruction + '\n')
                        hex_instruction = hex(int(binary_instruction, 2))
                        hex_instruction_doc.write(hex_instruction + '\n')
                        pc += 4
                    # bgtu pseudoinstruction
                    elif parts[0] == 'bgtu' and len(parts) == 4:
                        # bgtu rs1, rs2, label is translated to bltu rs2, rs1, label
                        real_line = f'bltu {parts[2]}, {parts[1]}, {parts[3]}'
                        lexer = lexer_branch()
                        i = 0
                        # Tokenize the translated bgtu instruction
                        for tok in lexer.tokenize(real_line):
                            # Extract function codes and opcode for the instruction
                            if tok.type == 'INSTRUCTION' and tok.value in type_b.Functions :
                                func3 = type_b.Functions[tok.value][1]
                                opcode = type_b.Functions[tok.value][0]
                            # Extract register values for rs1 and rs2
                            elif tok.type == 'REGISTER' and tok.value in register.register :
                                if i == 0:
                                    rs1 = register.register[tok.value]
                                elif i == 1:
                                    rs2 = register.register[tok.value]
                                i += 1
                            # Extract label and calculate branch target address
                            elif tok.type == 'LABEL' :
                                if tok.value in labels:
                                    imm = labels[tok.value] - pc
                                    if imm % 2 != 0 or not (0 <= imm <= 8192):
                                        raise ValueError("Branch target address must be even and within range for 13 bits")
                                    else:
                                        imm = imm
                                else:
                                    raise ValueError(f"Undefined label: {tok.value}")
                            elif tok.type in ",":
                                continue
                            else:
                                raise ValueError("Invalid token or token not in expected position")
                        # Split immediate value into parts for B-type instruction format
                        imm_12 = (imm >> 12) & 0x1
                        imm_10_5 = (imm >> 5) & 0x3F
                        imm_4_1 = (imm >> 1) & 0xF
                        imm_11 = (imm >> 11) & 0x1
                        binary_instruction = format(imm_12, '01b') + format(imm_10_5, '06b') + format(rs2, '05b') + format(rs1, '05b') + func3 + format(imm_4_1, '04b') + format(imm_11, '01b') + opcode
                        binary_instruction_doc.write(binary_instruction + '\n')
                        hex_instruction = hex(int(binary_instruction, 2))
                        hex_instruction_doc.write(hex_instruction + '\n')
                        pc += 4
                    # bleu pseudoinstruction
                    elif parts[0] == 'bleu' and len(parts) == 4:
                        # bleu rs1, rs2, label is translated to bgeu rs2, rs1, label
                        real_line = f'bgeu {parts[2]}, {parts[1]}, {parts[3]}'
                        lexer = lexer_branch()
                        i = 0
                        # Tokenize the translated bleu instruction
                        for tok in lexer.tokenize(real_line):
                            # Extract function codes and opcode for the instruction
                            if tok.type == 'INSTRUCTION' and tok.value in type_b.Functions :
                                func3 = type_b.Functions[tok.value][1]
                                opcode = type_b.Functions[tok.value][0]
                            # Extract register values for rs1 and rs2
                            elif tok.type == 'REGISTER' and tok.value in register.register :
                                if i == 0:
                                    rs1 = register.register[tok.value]
                                elif i == 1:
                                    rs2 = register.register[tok.value]
                                i += 1
                            # Extract label and calculate branch target address
                            elif tok.type == 'LABEL' :
                                if tok.value in labels:
                                    imm = labels[tok.value] - pc
                                    if imm % 2 != 0 or not (0 <= imm <= 8192):
                                        raise ValueError("Branch target address must be even and within range for 13 bits")
                                    else:
                                        imm = imm
                                else:
                                    raise ValueError(f"Undefined label: {tok.value}")
                            elif tok.type in ",":
                                continue
                            else:
                                raise ValueError("Invalid token or token not in expected position")
                        # Split immediate value into parts for B-type instruction format
                        imm_12 = (imm >> 12) & 0x1
                        imm_10_5 = (imm >> 5) & 0x3F
                        imm_4_1 = (imm >> 1) & 0xF
                        imm_11 = (imm >> 11) & 0x1
                        binary_instruction = format(imm_12, '01b') + format(imm_10_5, '06b') + format(rs2, '05b') + format(rs1, '05b') + func3 + format(imm_4_1, '04b') + format(imm_11, '01b') + opcode
                        binary_instruction_doc.write(binary_instruction + '\n')
                        hex_instruction = hex(int(binary_instruction, 2))
                        hex_instruction_doc.write(hex_instruction + '\n')
                        pc += 4
                    # j pseudoinstruction
                    elif parts[0] == 'j' and len(parts) == 2:
                        # j label is translated to jal x0, label
                        real_line = f'jal x0, {parts[1]}'
                        lexer = lexer_jtype()
                        i = 0
                        # Tokenize the translated j instruction
                        for tok in lexer.tokenize(real_line):
                            # Extract opcode and rd register
                            if tok.type == 'INSTRUCTION' and tok.value in type_j.Functions :
                                opcode = type_j.Functions[tok.value][0]
                            # Extract register value for rd
                            elif tok.type == 'REGISTER' and tok.value in register.register :
                                if i == 0:
                                    rd = register.register[tok.value]
                                i += 1
                            # Extract label and calculate jump target address
                            elif tok.type == 'LABEL' :
                                if tok.value in labels:
                                    imm = labels[tok.value] - pc
                                    if imm % 2 != 0 or not (-1048576 <= imm <= 1048574):
                                        raise ValueError("Jump target address must be even and within range for 21 bits")
                                    else:
                                        if imm < 0:
                                            imm = two_complement(imm, 21)
                                        else:
                                            imm = imm
                                else:
                                    raise ValueError(f"Undefined label: {tok.value}")
                            elif tok.type in ",":
                                continue
                            else:
                                raise ValueError("Invalid token or token not in expected position")
                        # Split immediate value into parts for J-type instruction format
                        imm_20 = (imm >> 20) & 0x1  
                        imm_10_1 = (imm >> 1) & 0x3FF
                        imm_11 = (imm >> 11) & 0x1
                        imm_19_12 = (imm >> 12) & 0xFF
                        binary_instruction = format(imm_20, '01b') + format(imm_10_1, '010b') + format(imm_11, '01b') + format(imm_19_12, '08b') + format(rd, '05b') + opcode
                        binary_instruction_doc.write(binary_instruction + '\n')
                        hex_instruction = hex(int(binary_instruction, 2))
                        hex_instruction_doc.write(hex_instruction + '\n')
                        pc += 4
                    # jal pseudoinstruction
                    elif parts[0] == 'jal' and len(parts) == 2:
                        # jal label is translated to jal x1, label
                        real_line = f'jal x1, {parts[1]}'
                        lexer = lexer_jtype()
                        i = 0
                        # Tokenize the translated jal instruction
                        for tok in lexer.tokenize(real_line):
                            # Extract opcode and rd register
                            if tok.type == 'INSTRUCTION' and tok.value in type_j.Functions :
                                opcode = type_j.Functions[tok.value][0]
                            # Extract register value for rd
                            elif tok.type == 'REGISTER' and tok.value in register.register :
                                if i == 0:
                                    rd = register.register[tok.value]
                                i += 1
                            # Extract label and calculate jump target address
                            elif tok.type == 'LABEL' :
                                if tok.value in labels:
                                    imm = labels[tok.value] - pc
                                    if imm % 2 != 0 or not (-1048576 <= imm <= 1048574):
                                        raise ValueError("Jump target address must be even and within range for 21 bits")
                                    else:
                                        if imm < 0:
                                            imm = two_complement(imm, 21)
                                        else:
                                            imm = imm
                                else:
                                    raise ValueError(f"Undefined label: {tok.value}")
                            elif tok.type in ",":
                                continue
                            else:
                                raise ValueError("Invalid token or token not in expected position")
                        # Split immediate value into parts for J-type instruction format
                        imm_20 = (imm >> 20) & 0x1  
                        imm_10_1 = (imm >> 1) & 0x3FF
                        imm_11 = (imm >> 11) & 0x1
                        imm_19_12 = (imm >> 12) & 0xFF
                        binary_instruction = format(imm_20, '01b') + format(imm_10_1, '010b') + format(imm_11, '01b') + format(imm_19_12, '08b') + format(rd, '05b') + opcode
                        binary_instruction_doc.write(binary_instruction + '\n')
                        hex_instruction = hex(int(binary_instruction, 2))
                        hex_instruction_doc.write(hex_instruction + '\n')
                        pc += 4
                    # jr pseudoinstruction
                    elif parts[0] == 'jr' and len(parts) == 2:
                        # jr rs is translated to jalr x0, rs, 0
                        real_line = f'jalr x0, {parts[1]}, 0'
                        lexer = lexer_jrtype()
                        i = 0
                        # Tokenize the translated jr instruction
                        for tok in lexer.tokenize(real_line):
                            # Extract function codes and opcode for the instruction
                            if tok.type == 'INSTRUCTION' and tok.value in type_jr.Functions :
                                func3 = type_jr.Functions[tok.value][1]
                                opcode = type_jr.Functions[tok.value][0]
                            # Extract register values for rd and rs1
                            elif tok.type == 'REGISTER' and tok.value in register.register :
                                if i == 0:
                                    rd = register.register[tok.value]
                                elif i == 1:
                                    rs1 = register.register[tok.value]
                                i += 1
                            # Immediate is always 0 for jr
                            elif tok.type == 'NUMBER' :
                                imm = 0
                            elif tok.type in ",":
                                continue
                            else:
                                raise ValueError("Invalid token or token not in expected position")
                        # Split immediate value into parts for J-type instruction format
                        binary_instruction = format(imm, '012b') + format(rs1, '05b') + func3 + format(rd, '05b') + opcode
                        binary_instruction_doc.write(binary_instruction + '\n')
                        hex_instruction = hex(int(binary_instruction, 2))
                        hex_instruction_doc.write(hex_instruction + '\n')
                        pc += 4
                    # jalr pseudoinstruction
                    elif parts[0] == 'jalr' and len(parts) == 2:
                        # jalr rs is translated to jalr x1, rs, 0
                        real_line = f'jalr x1, {parts[1]}, 0'
                        lexer = lexer_jrtype()
                        i = 0
                        # Tokenize the translated jalr instruction
                        for tok in lexer.tokenize(real_line):
                            # Extract function codes and opcode for the instruction
                            if tok.type == 'INSTRUCTION' and tok.value in type_jr.Functions :
                                func3 = type_jr.Functions[tok.value][1]
                                opcode = type_jr.Functions[tok.value][0]
                            # Extract register values for rd and rs1
                            elif tok.type == 'REGISTER' and tok.value in register.register :
                                if i == 0:
                                    rd = register.register[tok.value]
                                elif i == 1:
                                    rs1 = register.register[tok.value]
                                i += 1
                            # Immediate is always 0 for jalr
                            elif tok.type == 'NUMBER' :
                                imm = 0
                            elif tok.type in ",":
                                continue
                            else:
                                raise ValueError("Invalid token or token not in expected position")
                        # Split immediate value into parts for J-type instruction format
                        binary_instruction = format(imm, '012b') + format(rs1, '05b') + func3 + format(rd, '05b') + opcode
                        binary_instruction_doc.write(binary_instruction + '\n')
                        hex_instruction = hex(int(binary_instruction, 2))
                        hex_instruction_doc.write(hex_instruction + '\n')
                        pc += 4
                    # ret pseudoinstruction
                    elif parts[0] == 'ret' and len(parts) == 1:
                        real_line = f'jalr x0, x1, 0'
                        lexer = lexer_jrtype()
                        i = 0
                        # Tokenize the translated ret instruction
                        for tok in lexer.tokenize(real_line):
                            # Extract function codes and opcode for the instruction
                            if tok.type == 'INSTRUCTION' and tok.value in type_jr.Functions :
                                func3 = type_jr.Functions[tok.value][1]
                                opcode = type_jr.Functions[tok.value][0]
                            # Extract register values for rd and rs1
                            elif tok.type == 'REGISTER' and tok.value in register.register:
                                if i == 0:
                                    rd = register.register[tok.value]
                                elif i == 1:
                                    rs1 = register.register[tok.value]
                                i += 1
                            # Immediate is always 0 for ret
                            elif tok.type == 'NUMBER' :
                                imm = 0
                            elif tok.type in ",":
                                continue
                            else:
                                raise ValueError("Invalid token or token not in expected position")
                        # Split immediate value into parts for J-type instruction format
                        binary_instruction = format(imm, '012b') + format(rs1, '05b') + func3 + format(rd, '05b') + opcode
                        binary_instruction_doc.write(binary_instruction + '\n')
                        hex_instruction = hex(int(binary_instruction, 2))
                        hex_instruction_doc.write(hex_instruction + '\n')
                        pc += 4
                    else:
                        raise ValueError(f"Unknown instruction or wrong number of operands: {line}")
        # Ignore labels
                elif (parts[0].endswith(':') and parts[0][:-1] in labels) :
                    continue
                elif parts[1] == ':' and parts[0] in labels:
                    continue
                else:
                    raise ValueError(f"Invalid instruction: '{parts[0]}' is not a valid RV32I instruction or pseudoinstruction.")
        for data in memory_bin:
            binary_instruction_doc.write(data + '\n')
            hex_data = hex(int(data, 2))
            hex_instruction_doc.write(hex_data + '\n')
        print(labels)
        print(variables)


# Run the assembler
if __name__ == "__main__":
    first_pass()
    second_pass()

    