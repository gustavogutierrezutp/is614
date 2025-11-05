from sly import Lexer, Parser

class RV32ILexer(Lexer):
    # Definicion de tokens
    tokens = {
        # Instrucciones
        'ADD', 'SUB', 'XOR', 'OR', 'AND', 'SLL', 'SRL', 'SRA', 'SLT', 'SLTU',
        'ADDI', 'XORI', 'ORI', 'ANDI', 'SLLI', 'SRLI', 'SRAI', 'SLTI', 'SLTIU',
        'LB', 'LH', 'LW', 'LBU', 'LHU',
        'SB', 'SH', 'SW',
        'BEQ', 'BNE', 'BLT', 'BGE', 'BLTU', 'BGEU',
        'JAL', 'JALR',
        'LUI', 'AUIPC',
        'ECALL', 'EBREAK',

        # Registros
        'REGISTER',

        # etiquetas y numeros
        'ID', 'NUMBER',
        
        
        # signos de puntuacion
        'COMMA', 'LPAREN', 'RPAREN', 'COLON',

        # assembler directives
        'DIRECTIVE'
    }

    # Ignorar espacios y comentarios
    ignore = ' \t'
    ignore_comment = r'\#.*'

    # reglas de tokens de puntuacion
    COMMA   = r','
    LPAREN  = r'\('
    RPAREN  = r'\)'
    COLON   = r':'
    
    # regla para las directivas
    DIRECTIVE = r'\.[a-zA-Z_][a-zA-Z0-9_]*'

    # regla para diferenciar instrucciones, registros y etiquetas
    @_(r'[a-zA-Z_][a-zA-Z0-9_]*')
    def ID(self, t):
        # mira si es una instruccion
        instr_upper = t.value.upper()
        if instr_upper in self.tokens:
            t.type = instr_upper
        # mira si es un registro, si no es ninguna es una etiqueta
        elif t.value.lower() in self.get_register_map():
            t.type = 'REGISTER'
        return t

    # regla de los numeros
    @_(r'0[xX][0-9a-fA-F]+|-?\d+')
    def NUMBER(self, t):
        if t.value.startswith(('0x', '0X')):
            t.value = int(t.value, 16)
        else:
            t.value = int(t.value)
        return t

    # regla para las nuevas lineas
    @_(r'\n+')
    def ignore_newline(self, t):
        self.lineno += len(t.value)

    def error(self, t):
        print(f"Error: Caracter no permitido '{t.value[0]}' en la línea {self.lineno}")
        exit(1)
        
    @staticmethod
    def get_register_map():

        # asigna nombres de registros a sus numeros
        regs = {f'x{i}': i for i in range(32)}
        abi = {
            'zero': 'x0', 'ra': 'x1', 'sp': 'x2', 'gp': 'x3',
            'tp': 'x4', 't0': 'x5', 't1': 'x6', 't2': 'x7',
            's0': 'x8', 'fp': 'x8', 's1': 'x9', 'a0': 'x10',
            'a1': 'x11', 'a2': 'x12', 'a3': 'x13', 'a4': 'x14',
            'a5': 'x15', 'a6': 'x16', 'a7': 'x17', 's2': 'x18',
            's3': 'x19', 's4': 'x20', 's5': 'x21', 's6': 'x22',
            's7': 'x23', 's8': 'x24', 's9': 'x25', 's10': 'x26',
            's11': 'x27', 't3': 'x28', 't4': 'x29', 't5': 'x30',
            't6': 'x31'
        }
        regs.update(abi)
        return regs


class RV32IParser(Parser):
    tokens = RV32ILexer.tokens

    # identifica si tiene una linea o una "lista de lineas" o no
    @_('line_list')
    def program(self, p):
        return ('program', p.line_list)

    @_('line')
    def line_list(self, p):
        return [p.line] if p.line else []

    @_('line_list line')
    def line_list(self, p):
        if p.line:
            p.line_list.append(p.line)
        return p.line_list

    #una linea puede ser una instruccion, una etiqueta o una directiva
    @_('instruction')
    def line(self, p):
        return p.instruction

    @_('label')
    def line(self, p):
        return p.label

    @_('directive')
    def line(self, p):
        return p.directive
    
    @_('ID COLON')
    def label(self, p):
        return ('label', p.ID)

    @_('ID COLON DIRECTIVE NUMBER')
    def label(self, p):
        return ('labelData', p.ID, p.DIRECTIVE, p.NUMBER)


    # definicion de instrucciones por tipo
    # R-Type
    @_('ADD REGISTER COMMA REGISTER COMMA REGISTER')
    @_('SUB REGISTER COMMA REGISTER COMMA REGISTER')
    @_('SLL REGISTER COMMA REGISTER COMMA REGISTER')
    @_('SLT REGISTER COMMA REGISTER COMMA REGISTER')
    @_('SLTU REGISTER COMMA REGISTER COMMA REGISTER')
    @_('XOR REGISTER COMMA REGISTER COMMA REGISTER')
    @_('SRL REGISTER COMMA REGISTER COMMA REGISTER')
    @_('SRA REGISTER COMMA REGISTER COMMA REGISTER')
    @_('OR REGISTER COMMA REGISTER COMMA REGISTER')
    @_('AND REGISTER COMMA REGISTER COMMA REGISTER')
    def instruction(self, p):
        return ('R-type', p[0].lower(), {'rd': p[1], 'rs1': p[3], 'rs2': p[5]})

    # I-Type (inmediato)
    @_('ADDI REGISTER COMMA REGISTER COMMA immediate')
    @_('SLTI REGISTER COMMA REGISTER COMMA immediate')
    @_('SLTIU REGISTER COMMA REGISTER COMMA immediate')
    @_('XORI REGISTER COMMA REGISTER COMMA immediate')
    @_('ORI REGISTER COMMA REGISTER COMMA immediate')
    @_('ANDI REGISTER COMMA REGISTER COMMA immediate')
    @_('SLLI REGISTER COMMA REGISTER COMMA immediate')
    @_('SRLI REGISTER COMMA REGISTER COMMA immediate')
    @_('SRAI REGISTER COMMA REGISTER COMMA immediate')
    def instruction(self, p):
        return ('I-type', p[0].lower(), {'rd': p[1], 'rs1': p[3], 'imm': p[5]})

    # I-Type (load con inmediato + base)  ej: lw x3, 0(x2)
    @_('LB REGISTER COMMA immediate LPAREN REGISTER RPAREN')
    @_('LH REGISTER COMMA immediate LPAREN REGISTER RPAREN')
    @_('LW REGISTER COMMA immediate LPAREN REGISTER RPAREN')
    @_('LBU REGISTER COMMA immediate LPAREN REGISTER RPAREN')
    @_('LHU REGISTER COMMA immediate LPAREN REGISTER RPAREN')
    def instruction(self, p):
        return ('I-type-load', p[0].lower(), {'rd': p[1], 'imm': p[3], 'rs1': p[5]})

    # I-Type (load con etiqueta) ej: lw x2, nums
    @_('LB REGISTER COMMA ID')
    @_('LH REGISTER COMMA ID')
    @_('LW REGISTER COMMA ID')
    @_('LBU REGISTER COMMA ID')
    @_('LHU REGISTER COMMA ID')
    def instruction(self, p):
        return ('I-type-load', p[0].lower(), {'rd': p[1], 'imm': 0,'label': p[3]})


    # I-Type JALR
    @_('JALR REGISTER COMMA REGISTER COMMA immediate')
    def instruction(self, p):
        return ('I-type-jalr', p[0].lower(), {'rd': p[1], 'rs1': p[3], 'imm': p[5]})
    
    @_('JALR REGISTER')
    def instruction(self, p):
        return ('I-type-jalr', p[0].lower(), {'rd': 'x1', 'rs1': p[1], 'imm': 0})

    # S-Type
    @_('SB REGISTER COMMA immediate LPAREN REGISTER RPAREN')
    @_('SH REGISTER COMMA immediate LPAREN REGISTER RPAREN')
    @_('SW REGISTER COMMA immediate LPAREN REGISTER RPAREN')
    def instruction(self, p):
        return ('S-type', p[0].lower(), {'rs2': p[1], 'imm': p[3], 'rs1': p[5]})

    # B-Type
    @_('BEQ REGISTER COMMA REGISTER COMMA ID')
    @_('BNE REGISTER COMMA REGISTER COMMA ID')
    @_('BLT REGISTER COMMA REGISTER COMMA ID')
    @_('BGE REGISTER COMMA REGISTER COMMA ID')
    @_('BLTU REGISTER COMMA REGISTER COMMA ID')
    @_('BGEU REGISTER COMMA REGISTER COMMA ID')
    def instruction(self, p):
        return ('B-type', p[0].lower(), {'rs1': p[1], 'rs2': p[3], 'label': p[5]})

    # U-Type
    @_('LUI REGISTER COMMA immediate')
    @_('AUIPC REGISTER COMMA immediate')
    def instruction(self, p):
        return ('U-type', p[0].lower(), {'rd': p[1], 'imm': p[3]})

    # J-Type
    @_('JAL REGISTER COMMA ID')
    def instruction(self, p):
        return ('J-type', p[0].lower(), {'rd': p[1], 'label': p[3]})
    
    @_('JAL ID')
    def instruction(self, p):
        return ('J-type', p[0].lower(), {'rd': 'x1', 'label': p[1]})
    
    # I-Type E
    @_('ECALL')
    def instruction(self, p):
        return ('I-type-e', p[0].lower(), {'imm': 0})
    
    @_('EBREAK')
    def instruction(self, p):
        return ('I-type-e', p[0].lower(), {'imm': 1})

    # definicion de operandos (lo que no es una instruccion)
    @_('NUMBER')
    def immediate(self, p):
        return p.NUMBER

    # Secciones
    @_('DIRECTIVE')
    def directive(self, p):
        return ('directive', p.DIRECTIVE)

    
    #errores de sintaxis
    def error(self, p):
        if p:
            print(f"Error: Sintaxis no válida en el token {p.type} ('{p.value}') en la línea {p.lineno}")
        else:
            print("Error: Sintaxis no válida al final del archivo EOF")
        exit(1)



