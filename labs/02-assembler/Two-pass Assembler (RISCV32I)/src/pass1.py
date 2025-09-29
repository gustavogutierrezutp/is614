from src.utils import clean_line, parse_instruction

class SymbolTable:
    def __init__(self):
        self.table = {}

    def add(self, label, addr):
        if label in self.table:
            # Ignorar si ya existe la misma dirección
            if self.table[label] != addr:
                raise ValueError(f"Etiqueta duplicada con diferente dirección: {label}")
            return
        self.table[label] = addr

    def get(self, label):
        return self.table.get(label, None)

    def dump(self):
        return self.table

def first_pass(file_path):
    # contadores por sección
    LC_text = 0x00000000
    LC_data = 0x10000000

    symtab = SymbolTable()
    current_section = '.text'

    with open(file_path,'r') as f:
        for lineno, line in enumerate(f,1):
            line = clean_line(line)
            if not line:
                continue

            if ':' in line:
                label_name, rest = line.split(':',1)
                label_name = label_name.strip()
                if symtab.get(label_name) is None:
                    if current_section == '.text':
                        symtab.add(label_name, LC_text)
                    elif current_section == '.data':
                        symtab.add(label_name, LC_data)
                line = rest.strip()
                if not line:
                    continue

            # Directivas
            if line.startswith('.'):
                parts = line.split()
                dir_name = parts[0]
                operands = parts[1:]

                # Actualizar sección
                if dir_name == '.text':
                    current_section = '.text'
                elif dir_name == '.data':
                    current_section = '.data'

                # Separar por comas
                split_ops = []
                for op in operands:
                    split_ops.extend(op.split(','))

                # Incrementar LC según tamaño de los datos
                size_per_item = 4 if dir_name=='.word' else 2 if dir_name=='.half' else 1
                if current_section == '.data':
                    LC_data += size_per_item * len(split_ops)
                elif current_section == '.text':
                    LC_text += size_per_item * len(split_ops)  # casi nunca pasa en .text

                # Manejo de align y org
                if dir_name == '.align':
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

            # Instrucciones
            instr = parse_instruction(line)
            if instr:
                if current_section == '.text':
                    LC_text += 4
                else:
                    raise ValueError(f"Instrucción encontrada en sección no-text en línea {lineno}")
                continue

    return symtab
