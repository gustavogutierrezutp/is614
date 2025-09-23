from . import encodings
from .utils import reg_to_num, parse_immediate

def assemble(instructions, symbol_table):
    machine_words = []

    for inst in instructions:
        mnemonic = inst["instr"].lower()
        operands = inst["operands"]
        pc = inst["address"]

        word = None

        if mnemonic in encodings.R_TYPE:
            rd = reg_to_num(operands[0])
            rs1 = reg_to_num(operands[1])
            rs2 = reg_to_num(operands[2])
            spec = encodings.R_TYPE[mnemonic]
            word = encodings.encode_R(rd, rs1, rs2, spec["opcode"], spec["funct3"], spec["funct7"])

        elif mnemonic in encodings.I_TYPE:
            spec = encodings.I_TYPE[mnemonic]
            if mnemonic in ["ecall", "ebreak"]:
                imm = spec["imm"]
                rd = rs1 = 0
            elif mnemonic in ["lb","lh","lw","lbu","lhu"]:
                rd = reg_to_num(operands[0])
                imm, base = operands[1].split("(")
                rs1 = reg_to_num(base[:-1])
                imm = parse_immediate(imm, symbol_table, pc)
            elif mnemonic in ["slli","srli","srai"]:
                rd = reg_to_num(operands[0])
                rs1 = reg_to_num(operands[1])
                imm = int(operands[2])
                word = encodings.encode_I(rd, rs1, imm, spec["opcode"], spec["funct3"], spec["funct7"])
            else:
                rd = reg_to_num(operands[0])
                rs1 = reg_to_num(operands[1])
                imm = parse_immediate(operands[2], symbol_table, pc)
            if word is None:
                word = encodings.encode_I(rd, rs1, imm, spec["opcode"], spec["funct3"], spec.get("funct7"))

        elif mnemonic in encodings.S_TYPE:
            rs2 = reg_to_num(operands[0])
            imm, base = operands[1].split("(")
            rs1 = reg_to_num(base[:-1])
            imm = parse_immediate(imm, symbol_table, pc)
            spec = encodings.S_TYPE[mnemonic]
            word = encodings.encode_S(rs1, rs2, imm, spec["opcode"], spec["funct3"])

        elif mnemonic in encodings.B_TYPE:
            rs1 = reg_to_num(operands[0])
            rs2 = reg_to_num(operands[1])
            target = operands[2]
            target_addr = parse_immediate(target, symbol_table, pc)
            offset = target_addr - pc
            spec = encodings.B_TYPE[mnemonic]
            word = encodings.encode_B(rs1, rs2, offset, spec["opcode"], spec["funct3"])

        elif mnemonic in encodings.U_TYPE:
            rd = reg_to_num(operands[0])
            imm = parse_immediate(operands[1], symbol_table, pc)
            spec = encodings.U_TYPE[mnemonic]
            word = encodings.encode_U(rd, imm, spec["opcode"])

        elif mnemonic in encodings.J_TYPE:
            rd = reg_to_num(operands[0])
            target = operands[1]
            target_addr = parse_immediate(target, symbol_table, pc)
            offset = target_addr - pc
            spec = encodings.J_TYPE[mnemonic]
            word = encodings.encode_J(rd, offset, spec["opcode"])

        else:
            raise ValueError(f"Línea {inst['line_no']}: instrucción desconocida '{mnemonic}'")

        machine_words.append(word)

    return machine_words
