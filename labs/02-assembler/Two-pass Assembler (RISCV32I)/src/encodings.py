from src.utils import reg_name_to_num

# R-Type
R_TYPE = {
    "add":  {"opcode": 0b0110011, "funct3": 0b000, "funct7": 0b0000000},
    "sub":  {"opcode": 0b0110011, "funct3": 0b000, "funct7": 0b0100000},
    "sll":  {"opcode": 0b0110011, "funct3": 0b001, "funct7": 0b0000000},
    "slt":  {"opcode": 0b0110011, "funct3": 0b010, "funct7": 0b0000000},
    "sltu": {"opcode": 0b0110011, "funct3": 0b011, "funct7": 0b0000000},
    "xor":  {"opcode": 0b0110011, "funct3": 0b100, "funct7": 0b0000000},
    "srl":  {"opcode": 0b0110011, "funct3": 0b101, "funct7": 0b0000000},
    "sra":  {"opcode": 0b0110011, "funct3": 0b101, "funct7": 0b0100000},
    "or":   {"opcode": 0b0110011, "funct3": 0b110, "funct7": 0b0000000},
    "and":  {"opcode": 0b0110011, "funct3": 0b111, "funct7": 0b0000000},
}

# I-Type
I_TYPE = {
    "addi": {"opcode":0b0010011, "funct3":0b000},
    "xori": {"opcode":0b0010011, "funct3":0b100},
    "ori":  {"opcode":0b0010011, "funct3":0b110},
    "andi": {"opcode":0b0010011, "funct3":0b111},
    "slli": {"opcode":0b0010011, "funct3":0b001, "funct7":0b0000000},
    "srli": {"opcode":0b0010011, "funct3":0b101, "funct7":0b0000000},
    "srai": {"opcode":0b0010011, "funct3":0b101, "funct7":0b0100000},
    "slti": {"opcode":0b0010011, "funct3":0b010},
    "sltiu":{"opcode":0b0010011, "funct3":0b011},
    "lb":   {"opcode":0b0000011, "funct3":0b000},
    "lh":   {"opcode":0b0000011, "funct3":0b001},
    "lw":   {"opcode":0b0000011, "funct3":0b010},
    "lbu":  {"opcode":0b0000011, "funct3":0b100},
    "lhu":  {"opcode":0b0000011, "funct3":0b101},
    "jalr": {"opcode":0b1100111, "funct3":0b000},
    "ecall":{"opcode":0b1110011},
    "ebreak":{"opcode":0b1110011},
}

# S-Type
S_TYPE = {
    "sb": {"opcode":0b0100011, "funct3":0b000},
    "sh": {"opcode":0b0100011, "funct3":0b001},
    "sw": {"opcode":0b0100011, "funct3":0b010},
}

# B-Type
B_TYPE = {
    "beq":  {"opcode":0b1100011, "funct3":0b000},
    "bne":  {"opcode":0b1100011, "funct3":0b001},
    "blt":  {"opcode":0b1100011, "funct3":0b100},
    "bge":  {"opcode":0b1100011, "funct3":0b101},
    "bltu": {"opcode":0b1100011, "funct3":0b110},
    "bgeu": {"opcode":0b1100011, "funct3":0b111},
}

# U-Type
U_TYPE = {
    "lui":   {"opcode":0b0110111},
    "auipc": {"opcode":0b0010111},
}

# J-Type
J_TYPE = {
    "jal": {"opcode":0b1101111},
}


def encode_R(mnemonic, rd, rs1, rs2):
    inst = R_TYPE[mnemonic]
    opcode = inst['opcode']
    funct3 = inst['funct3']
    funct7 = inst['funct7']
    rd = reg_name_to_num(rd)
    rs1 = reg_name_to_num(rs1)
    rs2 = reg_name_to_num(rs2)
    return (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd <<7) | opcode

def encode_I(mnemonic, rd, rs1, imm):
    inst = I_TYPE[mnemonic]
    opcode = inst['opcode']
    funct3 = inst.get('funct3',0)
    funct7 = inst.get('funct7',0)
    rd = reg_name_to_num(rd)
    rs1 = reg_name_to_num(rs1)
    imm &= 0xFFF  # 12 bits
    return (imm << 20) | (rs1 << 15) | (funct3 <<12) | (rd <<7) | opcode

def encode_S(mnemonic, rs1, rs2, imm):
    inst = S_TYPE[mnemonic]
    opcode = inst['opcode']
    funct3 = inst['funct3']
    rs1 = reg_name_to_num(rs1)
    rs2 = reg_name_to_num(rs2)
    imm &= 0xFFF
    imm_11_5 = (imm >>5) & 0x7F
    imm_4_0  = imm & 0x1F
    return (imm_11_5 <<25) | (rs2 <<20) | (rs1 <<15) | (funct3<<12) | (imm_4_0<<7) | opcode

def encode_B(mnemonic, rs1, rs2, imm):
    inst = B_TYPE[mnemonic]
    opcode = inst['opcode']
    funct3 = inst['funct3']
    rs1 = reg_name_to_num(rs1)
    rs2 = reg_name_to_num(rs2)
    imm &= 0x1FFF  # 13 bits
    imm_12 = (imm >>12) & 0x1
    imm_10_5 = (imm >>5) & 0x3F
    imm_4_1  = (imm >>1) & 0xF
    imm_11   = (imm >>11) & 0x1
    return (imm_12 <<31) | (imm_10_5 <<25) | (rs2<<20) | (rs1<<15) | (funct3<<12) | (imm_4_1<<8) | (imm_11<<7) | opcode

def encode_U(mnemonic, rd, imm):
    rd_num = reg_name_to_num(rd)
    opcode = U_TYPE[mnemonic]['opcode']
    imm20 = imm & 0xFFFFF000
    return imm20 | (rd_num << 7) | opcode

def encode_J(mnemonic, rd, imm):
    inst = J_TYPE[mnemonic]
    opcode = inst['opcode']
    rd = reg_name_to_num(rd)
    imm &= 0x1FFFFF  # 21 bits
    imm_20 = (imm >>20) &0x1
    imm_10_1 = (imm >>1)&0x3FF
    imm_11 = (imm >>11)&0x1
    imm_19_12 = (imm >>12)&0xFF
    return (imm_20<<31)|(imm_19_12<<12)|(imm_11<<20)|(imm_10_1<<21)|(rd<<7)|opcode
