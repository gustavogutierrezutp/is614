import re
ABI_REGISTERS = {
    "zero":0, "ra":1, "sp":2, "gp":3, "tp":4,
    "t0":5,"t1":6,"t2":7,
    "s0":8,"fp":8,"s1":9,
    "a0":10,"a1":11,"a2":12,"a3":13,"a4":14,"a5":15,"a6":16,"a7":17,
    "s2":18,"s3":19,"s4":20,"s5":21,"s6":22,"s7":23,"s8":24,"s9":25,"s10":26,"s11":27,
    "t3":28,"t4":29,"t5":30,"t6":31,
}

def clean_line(line: str) -> str:
    line = re.split(r"[#;]|//", line)[0]
    return line.strip()

def split_label_and_instr(line: str):
    label, instr = None, line
    if ":" in line:
        parts = line.split(":", 1)
        label = parts[0].strip()
        instr = parts[1].strip()
    return label, instr

def split_instruction(instr: str):
    if not instr:
        return None, []
    parts = instr.replace(",", " ").split()
    mnemonic = parts[0]
    operands = parts[1:]
    return mnemonic, operands

def reg_to_num(reg: str) -> int:
    reg = reg.lower()
    if reg.startswith("x") and reg[1:].isdigit():
        n = int(reg[1:])
        if 0 <= n <= 31:
            return n
    if reg in ABI_REGISTERS:
        return ABI_REGISTERS[reg]
    raise ValueError(f"Registro inválido: {reg}")

def parse_immediate(imm_str, symbol_table, pc):
    imm_str = imm_str.strip()
    if imm_str in symbol_table:
        return symbol_table[imm_str]
    if imm_str.startswith("0x"):
        return int(imm_str,16)
    elif imm_str.startswith("0b"):
        return int(imm_str,2)
    else:
        return int(imm_str)

def format_hex(word: int) -> str:
    return f"{word:08x}"

def format_bin(word: int) -> str:
    return f"{word:032b}"
