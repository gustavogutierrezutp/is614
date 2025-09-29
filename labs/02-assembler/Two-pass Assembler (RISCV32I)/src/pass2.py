from src.utils import clean_line, parse_instruction, parse_immediate
from src.directives import assemble_directive
from src.encodings import encode_R, encode_I, encode_S, encode_B, encode_U, encode_J
from src.encodings import R_TYPE, I_TYPE, S_TYPE, B_TYPE, U_TYPE, J_TYPE

def second_pass(file_path, symtab):
    program = []
    LC_text = 0x00000000
    LC_data = 0x10000000
    current_section = '.text'

    with open(file_path,'r') as f:
        for lineno, line in enumerate(f,1):
            raw_line = line.rstrip()
            line = clean_line(line)
            if not line:
                continue

            # Etiquetas
            if ':' in line:
                _, rest = line.split(':',1)
                line = rest.strip()
                if not line:
                    continue

            # Directivas
            if line.startswith('.'):
                parts = line.split()
                dir_name = parts[0]
                operands = parts[1:]

                if dir_name == '.text':
                    current_section = '.text'
                    continue
                elif dir_name == '.data':
                    current_section = '.data'
                    continue

                split_ops = []
                for op in operands:
                    split_ops.extend(op.split(','))

                # .word, .half, .byte --> usar assemble_directive
                if dir_name in ('.word', '.half', '.byte'):
                    values = assemble_directive(dir_name, split_ops)
                    if current_section == '.data':
                        addr = LC_data
                        size_per_item = 4 if dir_name=='.word' else 2 if dir_name=='.half' else 1
                        for v in values:
                            program.append((addr, v, raw_line))
                            addr += size_per_item
                        LC_data = addr
                    else:
                        addr = LC_text
                        size_per_item = 4 if dir_name=='.word' else 2 if dir_name=='.half' else 1
                        for v in values:
                            program.append((addr, v, raw_line))
                            addr += size_per_item
                        LC_text = addr

                elif dir_name == '.align':
                    n = int(split_ops[0])
                    if current_section == '.data':
                        LC_data = ((LC_data + (2**n -1)) // (2**n)) * (2**n)
                    else:
                        LC_text = ((LC_text + (2**n -1)) // (2**n)) * (2**n)

                elif dir_name == '.org':
                    addr = int(split_ops[0],0)
                    if current_section == '.data':
                        LC_data = addr
                    else:
                        LC_text = addr

                continue

            # Instrucciones (solo en .text)
            if current_section != '.text':
                continue

            instr = parse_instruction(line)
            if instr is None:
                continue

            mnemonic = instr['mnemonic']
            ops = instr['operands']

            word = None
            # R-Type
            if mnemonic in R_TYPE:
                word = encode_R(mnemonic, ops[0], ops[1], ops[2])
            # I-Type
            elif mnemonic in I_TYPE:
                if mnemonic in ['ecall','ebreak']:
                    word = encode_I(mnemonic, 0, 0, 0)
                elif mnemonic in ['slli','srli','srai']:
                    imm = parse_immediate(ops[2], symtab, LC_text)
                    word = encode_I(mnemonic, ops[0], ops[1], imm)
                elif mnemonic in ['lb','lh','lw','lbu','lhu','jalr']:
                    if '(' in ops[1]:
                        imm_str, reg_str = ops[1].replace(')','').split('(')
                        rs1 = reg_str.strip()
                        imm = parse_immediate(imm_str.strip())
                    else:
                        rs1 = ops[1]
                        imm = parse_immediate(ops[2], symtab, LC_text)
                    word = encode_I(mnemonic, ops[0], rs1, imm)
                else:
                    imm = parse_immediate(ops[2], symtab, LC_text)
                    word = encode_I(mnemonic, ops[0], ops[1], imm)
            # S-Type
            elif mnemonic in S_TYPE:
                if '(' in ops[1]:
                    imm_str, rs1 = ops[1].replace(')','').split('(')
                    rs1 = rs1.strip()
                    imm = parse_immediate(imm_str.strip())
                else:
                    rs1 = ops[1]
                    imm = parse_immediate(ops[2], symtab, LC_text)
                word = encode_S(mnemonic, rs1, ops[0], imm)
            # B-Type
            elif mnemonic in B_TYPE:
                label = ops[2]
                target_addr = symtab.get(label)
                if target_addr is None:
                    raise ValueError(f"Etiqueta no definida {label} en línea {lineno}")
                imm = target_addr - LC_text
                word = encode_B(mnemonic, ops[0], ops[1], imm)
            # U-Type
            elif mnemonic in U_TYPE:
                imm = parse_immediate(ops[1], symtab, LC_text) << 12
                word = encode_U(mnemonic, ops[0], imm)
            # J-Type
            elif mnemonic in J_TYPE:
                label = ops[1]
                instr_addr = LC_text
                target_addr = symtab.get(label)
                if target_addr is None:
                    raise ValueError(f"Etiqueta no definida {label} en línea {lineno}")
                imm = target_addr - instr_addr
                word = encode_J(mnemonic, ops[0], imm)
            else:
                raise ValueError(f"Mnemonic desconocido {mnemonic} en línea {lineno}")

            program.append((LC_text, word, raw_line))
            LC_text += 4

    return sorted(program, key=lambda x: x[0])


def write_bin(filename, program):
    with open(filename, 'w') as f:
        for addr, word, _ in program:
            f.write(f"{word:032b}\n")

        # Bloque de posiciones de memoria
        f.write("\n# POSICIONES DE MEMORIA\n")
        for addr, word, _ in program:
            f.write(f"0x{addr:08X} : {word:032b}\n")

def write_hex(filename, program):
    with open(filename, 'w') as f:
        for addr, word, _ in program:
            f.write(f"{word:08x}\n")

        # Bloque de posiciones de memoria
        f.write("\n# POSICIONES DE MEMORIA\n")
        for addr, word, _ in program:
            f.write(f"0x{addr:08X} : {word:08x}\n")
