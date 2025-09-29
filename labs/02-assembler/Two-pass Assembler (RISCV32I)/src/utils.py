import re

# Mapa de registros ABI a número
REGISTERS = {
    "zero":0, "ra":1, "sp":2, "gp":3, "tp":4,
    "t0":5, "t1":6, "t2":7,
    "s0":8, "fp":8, "s1":9,
    "a0":10, "a1":11, "a2":12, "a3":13, "a4":14, "a5":15, "a6":16, "a7":17,
    "s2":18, "s3":19, "s4":20, "s5":21, "s6":22, "s7":23, "s8":24, "s9":25, "s10":26, "s11":27,
    "t3":28, "t4":29, "t5":30, "t6":31
}

# Eliminar comentarios y espacios innecesarios
def clean_line(line):
    line = line.split('#')[0]      # eliminar comentarios #
    line = line.split(';')[0]      # eliminar comentarios ;
    return line.strip()

# Identificar si es una directiva
def is_directive(line):
    return line.startswith('.')

# Parseo simple de instrucción
def parse_instruction(line):
    parts = line.replace(',', ' ').split()
    if not parts:
        return None
    mnemonic = parts[0]
    operands = parts[1:]
    return {"mnemonic": mnemonic, "operands": operands}

# Parseo de registro
def reg_name_to_num(name):
    name = name.strip()
    if name.startswith('x') and name[1:].isdigit():
        val = int(name[1:])
        if 0 <= val <= 31:
            return val
    elif name in REGISTERS:
        return REGISTERS[name]
    raise ValueError(f"Registro inválido: {name}")

# Parseo de inmediato
def parse_immediate(val, symtab=None, current_addr=0):
    val = val.strip()

    # %hi
    if val.startswith("%hi(") and val.endswith(")"):
        label = val[4:-1]  # extrae el nombre entre paréntesis
        if symtab is None:
            raise ValueError("Se requiere tabla de símbolos para %hi()")
        addr = symtab.get(label)
        if addr is None:
            raise ValueError(f"Etiqueta no definida: {label}")
        return (addr >> 12) & 0xFFFFF  # 20 bits altos

    # %lo
    if val.startswith("%lo(") and val.endswith(")"):
        label = val[4:-1]
        if symtab is None:
            raise ValueError("Se requiere tabla de símbolos para %lo()")
        addr = symtab.get(label)
        if addr is None:
            raise ValueError(f"Etiqueta no definida: {label}")
        return addr & 0xFFF  # 12 bits bajos

    # Constantes normales
    if val.startswith('0x'):
        return int(val,16)
    elif val.startswith('0b'):
        return int(val,2)
    else:
        return int(val)  # decimal
