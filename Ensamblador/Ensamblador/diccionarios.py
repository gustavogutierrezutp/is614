#diccionariooooo
ins_type_R = {
    'add': {'funct7': '0000000','funct3': '000','opcode': '0110011'},
    'sub': {'funct7': '0100000','funct3': '000','opcode': '0110011'},
    'xor': {'funct7': '0000000','funct3': '100','opcode': '0110011'},
    'or': {'funct7': '0000000','funct3': '110','opcode': '0110011'},
    'and': {'funct7': '0000000','funct3': '111','opcode': '0110011'},
    'sll': {'funct7': '0000000','funct3': '001','opcode': '0110011'},
    'srl': {'funct7': '0000000','funct3': '101','opcode': '0110011'},
    'sra': {'funct7': '0100000','funct3': '101','opcode': '0110011'},
    'slt': {'funct7': '0000000','funct3': '010','opcode': '0110011'},
    'sltu': {'funct7': '0000000','funct3': '011','opcode': '0110011'},
    'mul': {'funct7': '0000001','funct3': '000','opcode': '0110011'},
    'div': {'funct7': '0000001','funct3': '100','opcode': '0110011'}
}

ins_type_I = {
    'addi': {'funct3': '000','opcode': '0010011'},
    'xori': {'funct3': '100','opcode': '0010011'},
    'ori': {'funct3': '110','opcode': '0010011'},
    'andi': {'funct3': '111','opcode': '0010011'},
    'slli': {'funct3': '001','opcode': '0010011'},
    'srli': {'funct3': '101','opcode': '0010011'},
    'srai': {'funct3': '101','opcode': '0010011'},
    'slti': {'funct3': '010','opcode': '0010011'},
    'sltiu': {'funct3': '011','opcode': '0010011'},
    'lb': {'funct3': '000','opcode': '0000011'},
    'lh': {'funct3': '001','opcode': '0000011'},
    'lw': {'funct3': '010','opcode': '0000011'},
    'lhu': {'funct3': '101','opcode': '0000011'},
    'lbu': {'funct3': '100','opcode': '0000011'},
    'jalr': {'funct3': '000','opcode': '1100111'},
    'ecall': {'funct3': '000','opcode': '1110011'},
    'ebreak': {'funct3': '000','opcode': '1110011'},
}

ins_type_S = {
    'sb': {'funct3': '000','opcode': '0100011'},
    'sh': {'funct3': '001','opcode': '0100011'},
    'sw': {'funct3': '010','opcode': '0100011'},
}

ins_type_B = {
    'beq': {'funct3': '000','opcode': '1100011'},
    'bne': {'funct3': '001','opcode': '1100011'},
    'blt': {'funct3': '100','opcode': '1100011'},
    'bge': {'funct3': '101','opcode': '1100011'},
    'bltu': {'funct3': '110','opcode': '1100011'},
    'bgeu': {'funct3': '111','opcode': '1100011'},
}

ins_type_U = {
    'lui': {'opcode': '0110111'},
    'auipc': {'opcode': '0010111'},
}

ins_type_J = {
    'jal': {'opcode': '1101111'},
}

def Registros(register_name):
    register_mapping = {
        'zero': 0,'ra': 1,'sp': 2,'gp': 3,'tp': 4,'t0': 5,'t1': 6,'t2': 7,'s0': 8,
        's1': 9,'a0': 10,'a1': 11,'a2': 12,'a3': 13,'a4': 14,'a5': 15,'a6': 16,
        'a7': 17,'s2': 18,'s3': 19,'s4': 20,'s5': 21,'s6': 22,'s7': 23,'s8': 24,
        's9': 25,'s10': 26,'s11': 27,'t3': 28,'t4': 29,'t5': 30,'t6': 31,
        'x0': 0,'x1': 1,'x2': 2,'x3': 3,'x4': 4,'x5': 5,'x6': 6,'x7': 7,'x8': 8,
        'x9': 9,'x10': 10,'x11': 11,'x12': 12,'x13': 13,'x14': 14,'x15': 15,'x16': 16,
        'x17': 17,'x18': 18,'x19': 19,'x20': 20,'x21': 21,'x22': 22,'x23': 23,'x24': 24,
        'x25': 25,'x26': 26,'x27': 27,'x28': 28,'x29': 29,'x30': 30,'x31': 31
    }
    # Convierte el número de registro a binario de 5 bits y devuelve como cadena
    register_number = register_mapping[register_name]
    return format(register_number, '05b')
    

#pseudoinstrucciones
def pseudo(line):
    tokens = line.strip().replace(',', ' ').split()
    if not tokens:
        return [line]  #línea vacía o comentario
    
    instr = tokens[0].lower()

    #Diccionario de pseudoinstrucciones
    pseudo_map = {
        'bgez':  lambda t: [f"bge {t[1]}, x0, {t[2]}"],  # bgez rs, label
        'bltz':  lambda t: [f"blt {t[1]}, x0, {t[2]}"],  # bltz rs, label
        'bgtz':  lambda t: [f"blt x0, {t[1]}, {t[2]}"],  # bgtz rs, label
        'blez':  lambda t: [f"bge x0, {t[1]}, {t[2]}"],  # blez rs, label
        'beqz':  lambda t: [f"beq {t[1]}, x0, {t[2]}"],  # beqz rs, label
        'bnez':  lambda t: [f"bne {t[1]}, x0, {t[2]}"],  # bnez rs, label

        'bgt':   lambda t: [f"blt {t[2]}, {t[1]}, {t[3]}"],   # bgt rs, rt, label
        'ble':   lambda t: [f"bge {t[2]}, {t[1]}, {t[3]}"],   # ble rs, rt, label
        'bgtu':  lambda t: [f"bltu {t[2]}, {t[1]}, {t[3]}"],  # bgtu rs, rt, label
        'bleu':  lambda t: [f"bgeu {t[2]}, {t[1]}, {t[3]}"],  # bleu rs, rt, label

        'j':     lambda t: [f"jal x0, {t[1]}"],       # j label
        'jr':    lambda t: [f"jalr x0, {t[1]}, 0"],   # jr rs
        'ret':   lambda t: ["jalr x0, x1, 0"],        # ret

        'nop':   lambda t: ["addi x0, x0, 0"],             # nop
        'mv':    lambda t: [f"addi {t[1]}, {t[2]}, 0"],    # mv rd, rs
        'not':   lambda t: [f"xori {t[1]}, {t[2]}, -1"],   # not rd, rs
        'neg':   lambda t: [f"sub {t[1]}, x0, {t[2]}"],    # neg rd, rs

        'seqz':  lambda t: [f"sltiu {t[1]}, {t[2]}, 1"],   # seqz rd, rs
        'snez':  lambda t: [f"sltu {t[1]}, x0, {t[2]}"],   # snez rd, rs
        'sltz':  lambda t: [f"slt {t[1]}, {t[2]}, x0"],    # sltz rd, rs
        'sgtz':  lambda t: [f"slt {t[1]}, x0, {t[2]}"],    # sgtz rd, rs
    }

    if instr in pseudo_map:
        return pseudo_map[instr](tokens)
    else:
        return [line]  #no es pseudo
