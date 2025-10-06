def directive_size(directive, operands):
    if directive == '.word':
        return 4 * len(operands)
    elif directive == '.half':
        return 2 * len(operands)
    elif directive == '.byte':
        return 1 * len(operands)
    elif directive in ('.text', '.data'):
        return 0  # no incrementa LC, solo cambia sección
    elif directive == '.align':
        n = int(operands[0])
        # LC se ajustará a la siguiente múltiplo de 2^n
        return f'align_{n}'  
    elif directive == '.org':
        return f'org_{int(operands[0],0)}'
    else:
        raise ValueError(f"Directiva desconocida: {directive}")

def assemble_directive(dir_name, operands):
    words = []

    # Separar por comas en caso de múltiples valores
    split_ops = []
    for op in operands:
        split_ops.extend(op.split(','))

    for op in split_ops:
        op = op.strip()
        if dir_name == '.word':
            val = int(op,0)
            words.append(val & 0xFFFFFFFF)
        elif dir_name == '.half':
            val = int(op,0)
            words.append(val & 0xFFFF)
        elif dir_name == '.byte':
            val = int(op,0)
            words.append(val & 0xFF)
    return words
