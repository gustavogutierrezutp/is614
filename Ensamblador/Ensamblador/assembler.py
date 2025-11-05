import sys
from rv32i_grammar import RV32ILexer, RV32IParser
from diccionarios import (pseudo, ins_type_R, ins_type_I, ins_type_S, ins_type_B, ins_type_U, ins_type_J,
    Registros
)

# Validación de inmediatos
def check_imm(imm_val, bits, instr, par=False):
    min_val = -(1 << (bits - 1))
    max_val = (1 << (bits - 1)) - 1

    if imm_val < min_val or imm_val > max_val:
        print(
            f"Error: Inmediato fuera de rango en {instr.upper()}. Rango válido"
            f"({min_val} a {max_val}). Se recibió {imm_val}"
        )
        exit(1)
    if par and (imm_val % 2 != 0):
        print(f"Error: Inmediato debe ser par en {instr.upper()}. Se recibió {imm_val}")
        exit(1)

    return format(imm_val & ((1 << bits) - 1), f'0{bits}b')



# Instrucciones individuales
def assemble_instruction(node):
    tipo, instr, campos = node
    instr = instr.lower()

    if tipo == "R-type":
        datos = ins_type_R[instr]
        rd = Registros(campos['rd'])
        rs1 = Registros(campos['rs1'])
        rs2 = Registros(campos['rs2'])
        return datos['funct7'] + rs2 + rs1 + datos['funct3'] + rd + datos['opcode']

    elif tipo == "I-type":
        datos = ins_type_I[instr]
        rd = Registros(campos['rd'])
        rs1 = Registros(campos['rs1'])
        imm = check_imm(campos['imm'], 12, instr)
        return imm + rs1 + datos['funct3'] + rd + datos['opcode']

    elif tipo == "I-type-load":
        datos = ins_type_I[instr]
        rd = Registros(campos['rd'])
        rs1 = Registros(campos['rs1'])
        imm = check_imm(campos['imm'], 12, instr)
        return imm + rs1 + datos['funct3'] + rd + datos['opcode']

    elif tipo == "I-type-jalr":
        datos = ins_type_I[instr]
        rd = Registros(campos['rd'])
        rs1 = Registros(campos['rs1'])
        imm = check_imm(campos['imm'], 12, instr)
        return imm + rs1 + datos['funct3'] + rd + datos['opcode']

    elif tipo == "S-type":
        datos = ins_type_S[instr]
        rs1 = Registros(campos['rs1'])
        rs2 = Registros(campos['rs2'])
        imm = check_imm(campos['imm'], 12, instr)
        imm_high = imm[:7]   # imm[11:5]
        imm_low  = imm[7:]   # imm[4:0]
        return imm_high + rs2 + rs1 + datos['funct3'] + imm_low + datos['opcode']

    elif tipo == "B-type":
        datos = ins_type_B[instr]
        rs1 = Registros(campos['rs1'])
        rs2 = Registros(campos['rs2'])
        imm = check_imm(campos['imm'], 13, instr, par=True)
        # Reordenar: imm[12|10:5|4:1|11]
        return imm[0] + imm[2:8] + rs2 + rs1 + datos['funct3'] + imm[8:12] + imm[1] + datos['opcode']

    elif tipo == "U-type":
        datos = ins_type_U[instr]
        rd = Registros(campos['rd'])
        imm_val = campos['imm']
        if imm_val < -(1 << 31) or imm_val > (1 << 31) - 1:
            print(f"Error: Inmediato fuera de rango 32 bits en {instr.upper()}. Se recibió {imm_val}")
            exit(1)
        imm = format(imm_val & 0xFFFFF, '020b')  # solo los bits [31:12]
        return imm + rd + datos['opcode']

    elif tipo == "J-type":
        datos = ins_type_J[instr]
        rd = Registros(campos['rd'])
        imm = check_imm(campos['imm'], 21, instr, par=True)
        # Reordenar: imm[20|10:1|11|19:12]
        return imm[0] + imm[10:20] + imm[9] + imm[1:9] + rd + datos['opcode']
    
    elif tipo == "I-type-e":
        datos = ins_type_I[instr]
        imm = check_imm(campos['imm'], 12, instr)
        return imm + '00000' + datos['funct3'] + '00000' + datos['opcode']

    else:
        return f"# Instrucción no soportada: {node}"


# Primera pasada--> recolectar etiquetas
def primera_pasada(ast):
    tabla_simbolos = {}
    pc = 0

    for node in ast[1]:
        if not node:
            continue
        if node[0] == "directive":
            pc = 0

        if node[0] == "labelData":
            nombre = node[1]
            if nombre in tabla_simbolos:
                print(f"Error: etiqueta '{nombre}' redefinida.")
                exit(1)
            tabla_simbolos[nombre] = pc
            pc += 4  # Asumimos que cada .word ocupa 4 bytes
        elif node[0] == "label":
            nombre = node[1]
            if nombre in tabla_simbolos:
                print(f"Error: etiqueta '{nombre}' redefinida.")
                exit(1)
            tabla_simbolos[nombre] = pc
        elif "type" in node[0]:
            pc += 4
    return tabla_simbolos


# Segunda pasada --> usar tabla de símbolos
def segunda_pasada(ast, tabla_simbolos):
    binarios = []
    pc = 0
    for node in ast[1]:
        if not node:
            continue
        if "type" in node[0]:
            tipo, instr, campos = node

            if tipo == "B-type":
                label = campos['label']
                if label not in tabla_simbolos:
                    print(f"Error: etiqueta '{label}' no definida.")
                    exit(1)
                target = tabla_simbolos[label]
                offset = target - pc
                campos['imm'] = offset

            elif tipo == "J-type":
                label = campos['label']
                if label not in tabla_simbolos:
                    print(f"Error: etiqueta '{label}' no definida.")
                    exit(1)
                target = tabla_simbolos[label]
                offset = target - pc
                campos['imm'] = offset

            elif tipo == "I-type-load" and 'label' in campos:
                label = campos['label']
                if label not in tabla_simbolos:
                    print(f"Error: etiqueta '{label}' no definida.")
                    exit(1)
                target = tabla_simbolos[label]
                campos['imm'] = target
                campos['rs1'] = campos['rd']  # Asumimos base en el registro destino

            binarios.append(assemble_instruction((tipo, instr, campos)))
            pc += 4
    return binarios


# Ensamblador principal
def assemble(code):
    lexer = RV32ILexer()
    parser = RV32IParser()

    expanded_lines = []
    for line in code.splitlines():
        expanded_lines.extend(pseudo(line))

    expanded_code = "\n".join(expanded_lines)

    ast = parser.parse(lexer.tokenize(expanded_code))
    
    tabla_simbolos = primera_pasada(ast)
    binarios = segunda_pasada(ast, tabla_simbolos)

    return binarios


# Ensamblar a archivos
def assemble_to_files(input_file, bin_file, hex_file):
    with open(input_file, "r", encoding="utf-8") as f:
        code = f.read()

    binarios = assemble(code)

    # Guardar binario
    with open(bin_file, "w", encoding="utf-8") as f:
        for b in binarios:
            f.write(b + "\n")

    # Guardar hexadecimal
    with open(hex_file, "w", encoding="utf-8") as f:
        for b in binarios:
            hexa = format(int(b, 2), "08x")  # 32 bits -> 8 hex chars
            f.write(hexa + "\n")


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Uso: python assembler.py <input.asm> <output.bin> <output.hex>")
        sys.exit(1)

    input_file = sys.argv[1]
    bin_file   = sys.argv[2]
    hex_file   = sys.argv[3]

    assemble_to_files(input_file, bin_file, hex_file)
    print(f"Ensamblado completado.\n- Binario: {bin_file}\n- Hexadecimal: {hex_file}")

    # python assembler.py program.asm program.bin program.hex

