import os

# --- Configuración ---
DATA_BASE = 0x00000000  # dirección base para la sección .data (puedes cambiarla)

# --- Mapeo de registros ABI ---
reg_map = {
    "zero":0, "ra":1, "sp":2, "gp":3, "tp":4, "t0":5, "t1":6, "t2":7,"s0":8, "fp":8,
    "s1":9, "a0":10, "a1":11, "a2":12, "a3":13, "a4":14,"a5":15, "a6":16, "a7":17,
    "s2":18, "s3":19, "s4":20, "s5":21,"s6":22, "s7":23, "s8":24, "s9":25, "s10":26,
    "s11":27, "t3":28, "t4":29, "t5":30, "t6":31, "x0":0, "x1":1, "x2":2, "x3":3,
    "x4":4, "x5":5,"x6":6, "x7":7, "x8":8, "x9":9, "x10":10, "x11":11, "x12":12,
    "x13":13, "x14":14, "x15":15, "x16":16, "x17":17, "x18":18, "x19":19, "x20":20,
    "x21":21, "x22":22, "x23":23, "x24":24, "x25":25, "x26":26, "x27":27, "x28":28,
    "x29":29, "x30":30, "x31":31
}

# --- Diccionario para etiquetas (Primera pasada) ---
labels = {}

# --- Utilidades ---
def to_bin(value: int, bits: int) -> str:
    """Convierte a binario de 'bits' bits con complemento a dos para negativos."""
    mask = (1 << bits) - 1
    return format(value & mask, f'0{bits}b')

def sign_extend(value: int, bits: int) -> int:
    """Extiende el signo de un valor de 'bits' bits."""
    sign_bit = 1 << (bits - 1)
    return (value & (sign_bit - 1)) - (value & sign_bit)

def get_reg(name: str) -> int:
    name = name.strip()
    if name not in reg_map:
        raise KeyError(f"Registro desconocido: '{name}'")
    return reg_map[name]

def parse_operands(operands_str: str):
    if not operands_str:
        return []
    # Separar por comas respetando espacios
    return [op.strip() for op in operands_str.split(',')]

def parse_offset_reg(operand: str):
    """Parsea 'imm(reg)' como '8(sp)' -> (imm, 'sp').
    imm puede ser etiqueta o literal (0x.., 0b.., decimal).
    """
    try:
        imm_str, reg_str = operand.replace(')', '').split('(')
        imm_str = imm_str.strip()
        reg_str = reg_str.strip()
        if imm_str in labels:
            imm = labels[imm_str]
        else:
            imm = int(imm_str, 0)
        return imm, reg_str
    except Exception:
        raise ValueError(f"Formato de offset inválido: '{operand}' (esperado imm(reg))")

def evaluate_imm(token: str, pc: int = 0):
    """
    Evalúa un token inmediato que puede ser:
      - literal (int(...,0))
      - etiqueta => devuelve la dirección absoluta labels[label]
      - %hi(label) => retorna el valor para LUI (ajustado)
      - %lo(label) => retorna el valor low 12-bit (signed si corresponde)
    """
    token = token.strip()
    if token.startswith('%hi(') and token.endswith(')'):
        label = token[4:-1].strip()
        if label not in labels:
            raise ValueError(f"Etiqueta no encontrada para %hi: {label}")
        addr = labels[label]
        hi = (addr + 0x800) >> 12
        return hi
    if token.startswith('%lo(') and token.endswith(')'):
        label = token[4:-1].strip()
        if label not in labels:
            raise ValueError(f"Etiqueta no encontrada para %lo: {label}")
        addr = labels[label]
        lo = addr & 0xFFF
        # devolver signed 12-bit si corresponde
        if lo & 0x800:
            return lo - (1 << 12)
        return lo
    if token in labels:
        return labels[token]
    try:
        return int(token, 0)
    except Exception:
        raise ValueError(f"No se pudo evaluar inmediato: '{token}'")

# --- Codificadores por formato (según RISC-V) ---
def encode_r_type(opcode, rd, funct3, rs1, rs2, funct7):
    return funct7 + to_bin(rs2,5) + to_bin(rs1,5) + funct3 + to_bin(rd,5) + opcode

def encode_i_type(opcode, rd, funct3, rs1, imm, signed=True):
    """I-type: admite signed 12-bit por defecto o unsigned 12-bit con signed=False"""
    if signed:
        if imm < -2048 or imm > 2047:
            raise ValueError(f"Inmediato I-type fuera de rango (signed 12-bit): {imm}")
    else:
        if imm < 0 or imm > 0xFFF:
            raise ValueError(f"Inmediato I-type fuera de rango (unsigned 12-bit): {imm}")
    return to_bin(imm,12) + to_bin(rs1,5) + funct3 + to_bin(rd,5) + opcode

def encode_s_type(opcode, funct3, rs1, rs2, imm):
    if imm < -2048 or imm > 2047:
        raise ValueError(f"Inmediato S-type fuera de rango: {imm} (debe estar entre -2048 y 2047)")
    imm11_5 = (imm >> 5) & 0x7F
    imm4_0 = imm & 0x1F
    return to_bin(imm11_5,7) + to_bin(rs2,5) + to_bin(rs1,5) + funct3 + to_bin(imm4_0,5) + opcode

def encode_b_type(opcode, funct3, rs1, rs2, imm):
    if imm % 2 != 0:
        raise ValueError(f"Offset de branch debe ser par: {imm}")
    if imm < -4096 or imm > 4094:
        raise ValueError(f"Offset de branch fuera de rango: {imm} (debe estar entre -4096 y 4094)")
    imm12 = (imm >> 12) & 0x1
    imm10_5 = (imm >> 5) & 0x3F
    imm4_1 = (imm >> 1) & 0xF
    imm11 = (imm >> 11) & 0x1
    return to_bin(imm12,1) + to_bin(imm10_5,6) + to_bin(rs2,5) + to_bin(rs1,5) + funct3 + to_bin(imm4_1,4) + to_bin(imm11,1) + opcode

def encode_u_type(opcode, rd, imm):
    if imm < 0 or imm > 0xFFFFF:
        raise ValueError(f"Inmediato U-type fuera de rango: {imm} (debe estar entre 0 y 1048575)")
    return to_bin(imm, 20) + to_bin(rd,5) + opcode

def encode_j_type(opcode, rd, imm):
    if imm % 2 != 0:
        raise ValueError(f"Offset de jump debe ser par: {imm}")
    if imm < -1048576 or imm > 1048574:
        raise ValueError(f"Offset de jump fuera de rango: {imm} (debe estar entre -1048576 y 1048574)")
    imm20 = (imm >> 20) & 0x1
    imm10_1 = (imm >> 1) & 0x3FF
    imm11 = (imm >> 11) & 0x1
    imm19_12 = (imm >> 12) & 0xFF
    return to_bin(imm20,1) + to_bin(imm19_12,8) + to_bin(imm11,1) + to_bin(imm10_1,10) + to_bin(rd,5) + opcode

# --- Tablas de instrucciones ---
R_INSTR = {
    'add':  ('0110011','000','0000000'),
    'sub':  ('0110011','000','0100000'),
    'xor':  ('0110011','100','0000000'),
    'or':   ('0110011','110','0000000'),
    'and':  ('0110011','111','0000000'),
    'sll':  ('0110011','001','0000000'),
    'srl':  ('0110011','101','0000000'),
    'sra':  ('0110011','101','0100000'),
    'slt':  ('0110011','010','0000000'),
    'sltu': ('0110011','011','0000000')
}

I_INSTR = {
    'addi': ('0010011','000'),
    'xori': ('0010011','100'),
    'ori':  ('0010011','110'),
    'andi': ('0010011','111'),
    'slti': ('0010011','010'),
    'sltiu':('0010011','011'),
    'slli': ('0010011','001'),
    'srli': ('0010011','101'),
    'srai': ('0010011','101'),
    'lb':   ('0000011','000'),
    'lh':   ('0000011','001'),
    'lw':   ('0000011','010'),
    'lbu':  ('0000011','100'),
    'lhu':  ('0000011','101'),
    'jalr': ('1100111','000')
}

S_INSTR = {
    'sb': ('0100011','000'),
    'sh': ('0100011','001'),
    'sw': ('0100011','010')
}

B_INSTR = {
    'beq':  ('1100011','000'),
    'bne':  ('1100011','001'),
    'blt':  ('1100011','100'),
    'bge':  ('1100011','101'),
    'bltu': ('1100011','110'),
    'bgeu': ('1100011','111')
}

U_INSTR = {
    'lui':   '0110111',
    'auipc': '0010111'
}

SPECIAL = {
    'ecall': '00000000000000000000000001110011',
    'ebreak':'00000000000100000000000001110011'
}

# --- Pseudoinstrucciones (tu implementación original) ---
def expand_pseudoinstruction(instr, ops, pc):
    expanded = []
    if instr == 'nop':
        expanded.append('addi x0, x0, 0')
    elif instr == 'mv':
        rd, rs = ops[0], ops[1]
        expanded.append(f'addi {rd}, {rs}, 0')
    elif instr == 'not':
        rd, rs = ops[0], ops[1]
        expanded.append(f'xori {rd}, {rs}, -1')
    elif instr == 'neg':
        rd, rs = ops[0], ops[1]
        expanded.append(f'sub {rd}, x0, {rs}')
    elif instr == 'seqz':
        rd, rs = ops[0], ops[1]
        expanded.append(f'sltiu {rd}, {rs}, 1')
    elif instr == 'snez':
        rd, rs = ops[0], ops[1]
        expanded.append(f'sltu {rd}, x0, {rs}')
    elif instr == 'sltz':
        rd, rs = ops[0], ops[1]
        expanded.append(f'slt {rd}, {rs}, x0')
    elif instr == 'sgtz':
        rd, rs = ops[0], ops[1]
        expanded.append(f'slt {rd}, x0, {rs}')
    elif instr == 'li':
        rd, imm_str = ops[0], ops[1]
        imm = int(imm_str, 0)
        if -2048 <= imm <= 2047:
            expanded.append(f'addi {rd}, x0, {imm}')
        else:
            upper = (imm + 2048) >> 12
            lower = imm - (upper << 12)
            expanded.append(f'lui {rd}, {upper}')
            if lower != 0:
                expanded.append(f'addi {rd}, {rd}, {lower}')
    elif instr == 'la':
        rd, symbol = ops[0], ops[1]
        if symbol in labels:
            addr = labels[symbol]
            expanded.append(f'addi {rd}, x0, {addr}')
        else:
            expanded.append(f'addi {rd}, x0, {symbol}')
    elif instr == 'beqz':
        rs, offset = ops[0], ops[1]
        expanded.append(f'beq {rs}, x0, {offset}')
    elif instr == 'bnez':
        rs, offset = ops[0], ops[1]
        expanded.append(f'bne {rs}, x0, {offset}')
    elif instr == 'blez':
        rs, offset = ops[0], ops[1]
        expanded.append(f'bge x0, {rs}, {offset}')
    elif instr == 'bgez':
        rs, offset = ops[0], ops[1]
        expanded.append(f'bge {rs}, x0, {offset}')
    elif instr == 'bltz':
        rs, offset = ops[0], ops[1]
        expanded.append(f'blt {rs}, x0, {offset}')
    elif instr == 'bgtz':
        rs, offset = ops[0], ops[1]
        expanded.append(f'blt x0, {rs}, {offset}')
    elif instr == 'bgt':
        rs, rt, offset = ops[0], ops[1], ops[2]
        expanded.append(f'blt {rt}, {rs}, {offset}')
    elif instr == 'ble':
        rs, rt, offset = ops[0], ops[1], ops[2]
        expanded.append(f'bge {rt}, {rs}, {offset}')
    elif instr == 'bgtu':
        rs, rt, offset = ops[0], ops[1], ops[2]
        expanded.append(f'bltu {rt}, {rs}, {offset}')
    elif instr == 'bleu':
        rs, rt, offset = ops[0], ops[1], ops[2]
        expanded.append(f'bgeu {rt}, {rs}, {offset}')
    elif instr == 'j':
        offset = ops[0]
        expanded.append(f'jal x0, {offset}')
    elif instr == 'jal' and len(ops) == 1:
        offset = ops[0]
        expanded.append(f'jal x1, {offset}')
    elif instr == 'jr':
        rs = ops[0]
        expanded.append(f'jalr x0, {rs}, 0')
    elif instr == 'jalr' and len(ops) == 1:
        rs = ops[0]
        expanded.append(f'jalr x1, {rs}, 0')
    elif instr == 'ret':
        expanded.append('jalr x0, x1, 0')
    elif instr == 'call':
        offset = ops[0]
        expanded.append(f'jal x1, {offset}')
    elif instr == 'tail':
        offset = ops[0]
        expanded.append(f'jal x0, {offset}')
    else:
        operands_str = ', '.join(ops) if ops else ''
        expanded.append(f'{instr} {operands_str}'.strip())
    return expanded

# --- Procesamiento de directivas .data ---
def process_data_directive(directive, operands, data_pc):
    """Procesa directivas .word, .half, .byte y genera los datos binarios/hexadecimales."""
    data_entries = []
    
    for operand in operands:
        try:
            # Evaluar el operando (puede ser literal o etiqueta)
            if operand in labels:
                value = labels[operand]
            else:
                value = int(operand, 0)
                
            # Generar representación binaria y hexadecimal SIEMPRE A 32 BITS
            if directive == '.word':
                binary = to_bin(value, 32)
                hexa = f"0x{value & 0xFFFFFFFF:08x}"
            elif directive == '.half':
                # Extender a 32 bits con padding de ceros a la izquierda
                binary_16 = to_bin(value, 16)
                binary = binary_16.zfill(32)  # Pad con ceros hasta 32 bits
                hexa = f"0x{value & 0xFFFF:08x}"  # Formato de 8 dígitos hex
            else:  # .byte
                # Extender a 32 bits con padding de ceros a la izquierda
                binary_8 = to_bin(value, 8)
                binary = binary_8.zfill(32)  # Pad con ceros hasta 32 bits
                hexa = f"0x{value & 0xFF:08x}"  # Formato de 8 dígitos hex
                
            data_entries.append({
                'pc': data_pc,  # Cambiar 'address' por 'pc'
                'value': value,
                'binary': binary,
                'hex': hexa,
                'directive': directive,
                'operand': operand
            })
            data_pc += 4  # Siempre avanzar de 4 en 4 como las instrucciones
        except Exception as e:
            data_entries.append({
                'pc': data_pc,  # Cambiar 'address' por 'pc'
                'error': f"Error procesando {operand}: {e}",
                'directive': directive,
                'operand': operand
            })
            data_pc += 4  # Siempre avanzar de 4 en 4 como las instrucciones
    
    return data_entries, data_pc

# --- Primera pasada: recolectar etiquetas (ahora con .word/.half/.byte) ---
def first_pass(lines):
    """Primera pasada para recolectar etiquetas y calcular direcciones en .data y .text.
    Soporta directivas en .data: .word (4), .half (2), .byte (1).
    """
    global labels
    labels = {}
    section = 'text'
    text_pc = 0
    data_pc = DATA_BASE

    for raw in lines:
        line = raw.split('#', 1)[0].strip()
        if not line:
            continue

        # directivas de sección
        if line.startswith('.'):
            parts = line.split()
            directive = parts[0]
            if directive == '.data':
                section = 'data'
                continue
            elif directive == '.text':
                section = 'text'
                continue
            elif section == 'data' and directive in ('.word', '.half', '.byte'):
                size_per = 4  # Siempre avanzar 4 bytes como las instrucciones
                operands = parse_operands(' '.join(parts[1:]))
                data_pc += size_per * len(operands)
                continue
            else:
                continue

        # etiqueta con posible resto
        if ':' in line:
            label_part, rest = line.split(':', 1)
            label = label_part.strip()
            rest = rest.strip()
            if section == 'text':
                labels[label] = text_pc
            else:
                labels[label] = data_pc

            if not rest:
                continue

            if section == 'data' and (rest.startswith('.word') or rest.startswith('.half') or rest.startswith('.byte')):
                parts = rest.split(None, 1)
                directive = parts[0]
                size_per = 4  # Siempre avanzar 4 bytes como las instrucciones
                operands = parse_operands(parts[1] if len(parts) > 1 else '')
                data_pc += size_per * len(operands)
                continue
            if section == 'text':
                parts = rest.split(None, 1)
                instr = parts[0]
                ops = parse_operands(parts[1] if len(parts) > 1 else '')
                expanded = expand_pseudoinstruction(instr, ops, text_pc)
                text_pc += len(expanded) * 4
            else:
                continue
        else:
            if section == 'data' and (line.startswith('.word') or line.startswith('.half') or line.startswith('.byte')):
                parts = line.split(None, 1)
                directive = parts[0]
                size_per = 4  # Siempre avanzar 4 bytes como las instrucciones
                operands = parse_operands(parts[1] if len(parts) > 1 else '')
                data_pc += size_per * len(operands)
            else:
                if section == 'text':
                    parts = line.split(None, 1)
                    instr = parts[0]
                    ops = parse_operands(parts[1] if len(parts) > 1 else '')
                    expanded = expand_pseudoinstruction(instr, ops, text_pc)
                    text_pc += len(expanded) * 4
                else:
                    continue

    print("🏷️  Etiquetas encontradas:", labels)

# --- Resolver referencias a etiquetas (usa evaluate_imm) ---
def resolve_label(operand, pc):
    """Resuelve referencias a etiquetas o %hi/%lo devolviendo un string con el valor."""
    try:
        val = evaluate_imm(operand, pc)
        return str(val)
    except ValueError:
        return operand

# --- Ensamblador de línea (Segunda pasada) ---
def assemble_line(line: str, pc):
    line = line.split('#', 1)[0].strip()
    if not line:
        return None

    # Manejar etiquetas en la línea
    if ':' in line:
        parts = line.split(':', 1)
        remaining = parts[1].strip()
        if not remaining:
            return None
        line = remaining

    parts = line.split(None, 1)
    instr = parts[0]
    ops = parse_operands(parts[1] if len(parts) > 1 else '')

    # Si es una directiva en segunda pasada, no intentar ensamblarla
    if instr in ('.data', '.text', '.word', '.half', '.byte'):
        return None

    expanded_instructions = expand_pseudoinstruction(instr, ops, pc)

    results = []
    current_pc = pc
    for expanded_instr in expanded_instructions:
        result = assemble_base_instruction(expanded_instr, current_pc)
        if result:
            results.append((expanded_instr, result))
        current_pc += 4
    return results

def assemble_base_instruction(line: str, pc):
    """Ensambla una instrucción base (no pseudoinstrucción)."""
    raw_line = line.strip().split('#',1)[0]
    parts = raw_line.split(None, 1)
    instr = parts[0]
    ops = parse_operands(parts[1] if len(parts) > 1 else '')
    raw_ops = parse_operands(parts[1] if len(parts) > 1 else '') 

    try:
        resolved_ops = []
        for op in ops:
            if op in labels or op.startswith('%hi(') or op.startswith('%lo('):
                resolved_ops.append(resolve_label(op, pc))
            else:
                resolved_ops.append(op)
        ops = resolved_ops

        # R-type
        if instr in R_INSTR:
            opcode, funct3, funct7 = R_INSTR[instr]
            if len(ops) != 3:
                raise ValueError(f"'{instr}' espera 3 operandos, recibió {len(ops)}")
            rd = get_reg(ops[0]); rs1 = get_reg(ops[1]); rs2 = get_reg(ops[2])
            binary = encode_r_type(opcode, rd, funct3, rs1, rs2, funct7)

        # I-type
        elif instr in I_INSTR:
            opcode, funct3 = I_INSTR[instr]
            # shifts
            if instr in ('slli','srli','srai'):
                if len(ops) != 3:
                    raise ValueError(f"'{instr}' espera 3 operandos")
                rd = get_reg(ops[0]); rs1 = get_reg(ops[1])
                shamt = int(ops[2], 0)
                if shamt < 0 or shamt > 31:
                    raise ValueError(f"Shift amount debe estar entre 0 y 31: {shamt}")
                if instr == 'srai':
                    imm = (0b0100000 << 5) | (shamt & 0x1F)
                    binary = encode_i_type(opcode, rd, funct3, rs1, imm, signed=False)
                else:
                    imm = shamt & 0x1F
                    binary = encode_i_type(opcode, rd, funct3, rs1, imm, signed=False)

            # loads with imm(reg)
            elif instr in ('lb','lh','lw','lbu','lhu'):
                if len(ops) != 2:
                    raise ValueError(f"'{instr}' espera 2 operandos")
                rd = get_reg(ops[0])
                imm, rs1_str = parse_offset_reg(ops[1])
                rs1 = get_reg(rs1_str)
                binary = encode_i_type(opcode, rd, funct3, rs1, imm)

            elif instr == 'jalr':
                if len(ops) == 3:
                    rd = get_reg(ops[0]); rs1 = get_reg(ops[1]); imm = int(ops[2], 0)
                elif len(ops) == 2:
                    rd = get_reg(ops[0])
                    imm, rs1_str = parse_offset_reg(ops[1])
                    rs1 = get_reg(rs1_str)
                else:
                    raise ValueError(f"'{instr}' espera 2 o 3 operandos")
                binary = encode_i_type(opcode, rd, funct3, rs1, imm)

            else:
                if len(ops) != 3:
                    raise ValueError(f"'{instr}' espera 3 operandos")
                rd = get_reg(ops[0]); rs1 = get_reg(ops[1])
                imm_token = parts[1].split(',')[-1].strip() if len(parts) > 1 else ops[2]
                imm = evaluate_imm(imm_token, pc) if (imm_token in labels or imm_token.startswith('%') or not imm_token.replace('-','').isdigit()) else int(imm_token,0)
                binary = encode_i_type(opcode, rd, funct3, rs1, imm)

        # S-type
        elif instr in S_INSTR:
            opcode, funct3 = S_INSTR[instr]
            if len(ops) != 2:
                raise ValueError(f"'{instr}' espera 2 operandos")
            rs2 = get_reg(ops[0])
            imm, rs1_str = parse_offset_reg(ops[1])
            rs1 = get_reg(rs1_str)
            binary = encode_s_type(opcode, funct3, rs1, rs2, imm)

        # B-type
        elif instr in B_INSTR:
            opcode, funct3 = B_INSTR[instr]
            if len(ops) != 3:
                raise ValueError(f"'{instr}' espera 3 operandos")
            rs1 = get_reg(ops[0]); rs2 = get_reg(ops[1])
            target_token = raw_ops[2] if len(raw_ops) > 2 else ops[2]
            if target_token in labels or target_token.startswith('%') or (not target_token.lstrip('-').isdigit()):
                target_addr = evaluate_imm(target_token, pc)
                imm = target_addr - pc
            else:
                imm = int(target_token, 0)
            binary = encode_b_type(opcode, funct3, rs1, rs2, imm)

        # J-type (jal)
        elif instr == 'jal':
            opcode = '1101111'
            if len(ops) != 2:
                raise ValueError(f"'{instr}' espera 2 operandos")
            rd = get_reg(ops[0])
            target_token = raw_ops[1]
            if target_token in labels or target_token.startswith('%') or (not target_token.lstrip('-').isdigit()):
                target_addr = evaluate_imm(target_token, pc)
                imm = target_addr - pc
            else:
                imm = int(target_token, 0)
            binary = encode_j_type(opcode, rd, imm)

        # U-type
        elif instr in U_INSTR:
            opcode = U_INSTR[instr]
            if len(ops) != 2:
                raise ValueError(f"'{instr}' espera 2 operandos")
            rd = get_reg(ops[0])
            imm = evaluate_imm(ops[1], pc)
            binary = encode_u_type(opcode, rd, imm)

        # Especiales
        elif instr in SPECIAL:
            binary = SPECIAL[instr]

        else:
            return f"❌ ERROR: Instrucción '{instr}' no existe o no está soportada"

        # Validación final
        if len(binary) != 32 or any(c not in '01' for c in binary):
            return f'❌ ERROR: binario inválido para \"{line}\" -> {binary} (longitud: {len(binary)})'

        hexa = f"0x{int(binary,2):08x}"
        return binary, hexa

    except KeyError as e:
        return f"❌ ERROR: {e}"
    except ValueError as e:
        return f"❌ ERROR: {e}"
    except Exception as e:
        return f'❌ ERROR en línea \"{line}\": {e}'

# --- Main ---
def main():
    input_file = "instrucciones.txt"
    output_file = "salida_ensamblador.txt"
    binary_file = "salida_binario.txt"
    hex_file = "salida_hexadecimal.txt"

    if not os.path.exists(input_file):
        with open(input_file, "w", encoding="utf-8") as f:
            f.write("""# Escribe aquí tus instrucciones RISC-V""")

    print(f"✏️ Abre el archivo '{input_file}', escribe tus instrucciones y guárdalo.")
    try:
        os.system(f"notepad {input_file}")
    except Exception:
        pass

    with open(input_file, "r", encoding="utf-8") as f:
        lines = f.readlines()

    print("\n🔄 Ejecutando primera pasada...")
    first_pass(lines)

    print("\n🔄 Ejecutando segunda pasada...")
    
    # Listas para almacenar resultados
    text_instructions = []
    data_entries = []
    
    # Archivos de salida
    with open(output_file, "w", encoding="utf-8") as f_main, \
         open(binary_file, "w", encoding="utf-8") as f_bin, \
         open(hex_file, "w", encoding="utf-8") as f_hex:
        
        # Escribir encabezados
        f_main.write("=== ENSAMBLADOR RISC-V CON PSEUDOINSTRUCCIONES Y DIRECTIVAS .data/.text ===\n")
        f_main.write(f"Etiquetas encontradas: {labels}\n")
        f_main.write("=" * 80 + "\n\n")
        
        f_bin.write("=== SALIDA SOLO BINARIO ===\n")
        f_bin.write("# .TEXT SECTION\n")
        
        f_hex.write("=== SALIDA SOLO HEXADECIMAL ===\n")
        f_hex.write("# .TEXT SECTION\n")

        # Variables para el procesamiento
        section = 'text'
        pc = 0
        data_pc = DATA_BASE
        
        # Procesar todas las líneas
        for line in lines:
            if not line.strip() or line.strip().startswith("#"):
                continue

            original_line = line.strip()
            line_no_comment = original_line.split('#', 1)[0].strip()
            
            # Detectar cambios de sección
            if line_no_comment.startswith('.data'):
                section = 'data'
                f_main.write(f"\n=== SECCIÓN .DATA ===\n")
                continue
            elif line_no_comment.startswith('.text'):
                section = 'text'
                f_main.write(f"\n=== SECCIÓN .TEXT ===\n")
                continue
            
            if section == 'data':
                # Procesar líneas de la sección .data
                if ':' in line_no_comment:
                    label_part, rest = line_no_comment.split(':', 1)
                    label = label_part.strip()
                    rest = rest.strip()
                    f_main.write(f"Etiqueta: {label} (PC: 0x{labels[label]:08x})\n")
                    
                    if rest and (rest.startswith('.word') or rest.startswith('.half') or rest.startswith('.byte')):
                        parts = rest.split(None, 1)
                        directive = parts[0]
                        operands = parse_operands(parts[1] if len(parts) > 1 else '')
                        entries, data_pc = process_data_directive(directive, operands, data_pc)
                        data_entries.extend(entries)
                        
                        for entry in entries:
                            if 'error' not in entry:
                                f_main.write(f"  PC:{entry['pc']:08x} {directive} {entry['operand']} -> Bin: {entry['binary']} Hex: {entry['hex']}\n")
                            else:
                                f_main.write(f"  {entry['error']}\n")
                
                elif line_no_comment.startswith(('.word', '.half', '.byte')):
                    parts = line_no_comment.split(None, 1)
                    directive = parts[0]
                    operands = parse_operands(parts[1] if len(parts) > 1 else '')
                    entries, data_pc = process_data_directive(directive, operands, data_pc)
                    data_entries.extend(entries)
                    
                    f_main.write(f"Línea: {original_line}\n")
                    for entry in entries:
                        if 'error' not in entry:
                            f_main.write(f"  PC:{entry['pc']:08x} {directive} {entry['operand']} -> Bin: {entry['binary']} Hex: {entry['hex']}\n")
                        else:
                            f_main.write(f"  {entry['error']}\n")
                
            elif section == 'text':
                # Procesar instrucciones de la sección .text
                results = assemble_line(original_line, pc)

                if results:
                    f_main.write(f"Línea original: {original_line}\n")
                    for expanded_instr, result in results:
                        if isinstance(result, tuple):
                            binario, hexa = result
                            f_main.write(f"  PC:{pc:08x} {expanded_instr:40} -> Bin: {binario} Hex: {hexa}\n")
                            text_instructions.append({
                                'pc': pc,
                                'instruction': expanded_instr,
                                'binary': binario,
                                'hex': hexa
                            })
                        else:
                            f_main.write(f"  PC:{pc:08x} {expanded_instr:40} -> {result}\n")
                        pc += 4
                    f_main.write("\n")
                else:
                    # Manejar etiquetas solas
                    stripped = original_line.split('#',1)[0].strip()
                    if ':' in stripped:
                        f_main.write(f"{stripped}\n\n")

        # Escribir salidas separadas
        # Escribir instrucciones .text en archivos binario y hexadecimal
        for instr in text_instructions:
            f_bin.write(f"PC:{instr['pc']:08x} {instr['binary']}\n")
            f_hex.write(f"PC:{instr['pc']:08x} {instr['hex']}\n")
        
        # Escribir sección .data
        if data_entries:
            f_bin.write("\n# .DATA SECTION\n")
            f_hex.write("\n# .DATA SECTION\n")
            
            for entry in data_entries:
                if 'error' not in entry:
                    f_bin.write(f"PC:{entry['pc']:08x} {entry['binary']}\n")
                    f_hex.write(f"PC:{entry['pc']:08x} {entry['hex']}\n")

    print(f"\n✅ Resultados guardados en:")
    print(f"   📄 Salida completa: '{output_file}'")
    print(f"   🔢 Solo binario: '{binary_file}'")
    print(f"   🔣 Solo hexadecimal: '{hex_file}'")
    
    try:
        os.system(f"notepad {output_file}")
    except Exception:
        pass

if __name__ == "__main__":
    main()