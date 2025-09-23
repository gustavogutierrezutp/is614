from .utils import clean_line, split_label_and_instr, split_instruction

def build_symbol_table(filename):
    symbol_table = {}
    instructions = []
    lc = 0

    with open(filename, "r", encoding="utf-8") as f:
        for line_no, raw in enumerate(f, start=1):
            line = clean_line(raw)
            if not line:
                continue

            label, instr_part = split_label_and_instr(line)

            if label:
                if label in symbol_table:
                    raise ValueError(f"Error en línea {line_no}: Etiqueta '{label}' redefinida")
                symbol_table[label] = lc

            if instr_part:
                mnemonic, operands = split_instruction(instr_part)
                if mnemonic:
                    instructions.append({
                        "line_no": line_no,
                        "address": lc,
                        "label": label,
                        "instr": mnemonic,
                        "operands": operands
                    })
                    lc += 4

    return symbol_table, instructions
