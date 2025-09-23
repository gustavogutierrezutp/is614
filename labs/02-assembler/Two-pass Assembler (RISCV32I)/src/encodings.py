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

I_TYPE = {
    "addi": {"opcode": 0b0010011, "funct3": 0b000},
    "slti": {"opcode": 0b0010011, "funct3": 0b010},
    "sltiu": {"opcode": 0b0010011, "funct3": 0b011},
    "xori": {"opcode": 0b0010011, "funct3": 0b100},
    "ori":  {"opcode": 0b0010011, "funct3": 0b110},
    "andi": {"opcode": 0b0010011, "funct3": 0b111},
    "slli": {"opcode": 0b0010011, "funct3": 0b001, "funct7": 0b0000000},
    "srli": {"opcode": 0b0010011, "funct3": 0b101, "funct7": 0b0000000},
    "srai": {"opcode": 0b0010011, "funct3": 0b101, "funct7": 0b0100000},
    # Loads
    "lb":   {"opcode": 0b0000011, "funct3": 0b000},
    "lh":   {"opcode": 0b0000011, "funct3": 0b001},
    "lw":   {"opcode": 0b0000011, "funct3": 0b010},
    "lbu":  {"opcode": 0b0000011, "funct3": 0b100},
    "lhu":  {"opcode": 0b0000011, "funct3": 0b101},
    # System
    "ecall":  {"opcode": 0b1110011, "funct3": 0b000, "imm": 0},
    "ebreak": {"opcode": 0b1110011, "funct3": 0b000, "imm": 1},
}

S_TYPE = {
    "sb": {"opcode": 0b0100011, "funct3": 0b000},
    "sh": {"opcode": 0b0100011, "funct3": 0b001},
    "sw": {"opcode": 0b0100011, "funct3": 0b010},
}

B_TYPE = {
    "beq":  {"opcode": 0b1100011, "funct3": 0b000},
    "bne":  {"opcode": 0b1100011, "funct3": 0b001},
    "blt":  {"opcode": 0b1100011, "funct3": 0b100},
    "bge":  {"opcode": 0b1100011, "funct3": 0b101},
    "bltu": {"opcode": 0b1100011, "funct3": 0b110},
    "bgeu": {"opcode": 0b1100011, "funct3": 0b111},
}

U_TYPE = {
    "lui":   {"opcode": 0b0110111},
    "auipc": {"opcode": 0b0010111},
}

J_TYPE = {
    "jal": {"opcode": 0b1101111},
}

def encode_R(rd, rs1, rs2, opcode, funct3, funct7):
    return ((funct7 & 0x7F) << 25) | ((rs2 & 0x1F) << 20) | ((rs1 & 0x1F) << 15) | \
           ((funct3 & 0x7) << 12) | ((rd & 0x1F) << 7) | (opcode & 0x7F)

def encode_I(rd, rs1, imm, opcode, funct3, funct7=None):
    if funct7 is not None:
        return ((funct7 & 0x7F) << 25) | ((imm & 0x1F) << 20) | ((rs1 & 0x1F) << 15) | \
               ((funct3 & 0x7) << 12) | ((rd & 0x1F) << 7) | (opcode & 0x7F)
    else:
        return ((imm & 0xFFF) << 20) | ((rs1 & 0x1F) << 15) | \
               ((funct3 & 0x7) << 12) | ((rd & 0x1F) << 7) | (opcode & 0x7F)

def encode_S(rs1, rs2, imm, opcode, funct3):
    imm11_5 = (imm >> 5) & 0x7F
    imm4_0  = imm & 0x1F
    return (imm11_5 << 25) | ((rs2 & 0x1F) << 20) | ((rs1 & 0x1F) << 15) | \
           ((funct3 & 0x7) << 12) | ((imm4_0 & 0x1F) << 7) | (opcode & 0x7F)

def encode_B(rs1, rs2, imm, opcode, funct3):
    imm = imm >> 1
    imm12   = (imm >> 11) & 0x1
    imm10_5 = (imm >> 5) & 0x3F
    imm4_1  = imm & 0xF
    imm11   = (imm >> 10) & 0x1
    return (imm12 << 31) | (imm10_5 << 25) | ((rs2 & 0x1F) << 20) | \
           ((rs1 & 0x1F) << 15) | ((funct3 & 0x7) << 12) | \
           (imm4_1 << 8) | (imm11 << 7) | (opcode & 0x7F)

def encode_U(rd, imm, opcode):
    return (imm << 12) | ((rd & 0x1F) << 7) | (opcode & 0x7F)

def encode_J(rd, imm, opcode):
    if imm % 2 != 0:
        raise ValueError(f"Offset JAL no alineado: {imm}")

    imm20    = (imm >> 20) & 0x1
    imm10_1  = (imm >> 1)  & 0x3FF
    imm11    = (imm >> 11) & 0x1
    imm19_12 = (imm >> 12) & 0xFF

    return (imm20 << 31) | (imm19_12 << 12) | (imm11 << 20) | \
           (imm10_1 << 21) | ((rd & 0x1F) << 7) | (opcode & 0x7F)
