#!/usr/bin/env python3
"""
assembler.py - Ensamblador RV32I (Two-pass) - VERSION FINAL

Uso:
    python assembler.py program.asm program.hex program.bin

Caracteri­sticas:
 - Two-pass: primera pasada construye tabla de si­mbolos; segunda pasada genera cÃ³digo.
 - Soporta directivas: .text, .data, .word (varios valores separados por coma).
 - Soporta RV32I base (R, I, S, B, U, J) para el subconjunto ti­pico.
 - Expande pseudoinstrucciones (lista amplia, incluidas bgt/ble/bgtu/bleu, jal offset, jalr rs).
 - call/tail: expandidas como auipc + jalr (far call / tail call).
 - Salidas: archivo binario (little-endian) y archivo hex con direcciones.
"""

import re
import sys
from typing import Dict, List, Tuple, Optional

# Excepción personalizada para capturar cualquier error del ensamblador
class AssemblerError(Exception):
    pass

class RISCVAssembler:
    def __init__(self):
        # -----------------------------
        # TABLA DE REGISTROS
        # -----------------------------
        # Se crean todos los registros x0..x31 con su número
        self.registers: Dict[str,int] = {f'x{i}': i for i in range(32)}
        # Se agregan los nombres ABI (alias de los xN) para mayor comodidad
        # Ejemplo: a0 es x10, sp es x2, etc.    
        self.registers.update({
            'zero':0,'ra':1,'sp':2,'gp':3,'tp':4,'t0':5,'t1':6,'t2':7,
            's0':8,'fp':8,'s1':9,'a0':10,'a1':11,'a2':12,'a3':13,'a4':14,'a5':15,
            'a6':16,'a7':17,'s2':18,'s3':19,'s4':20,'s5':21,'s6':22,'s7':23,'s8':24,'s9':25,'s10':26,'s11':27,
            't3':28,'t4':29,'t5':30,'t6':31
        })

        # -----------------------------
        # TABLA DE INSTRUCCIONES
        # -----------------------------
        # Cada instrucción se define con su tipo (R/I/S/B/U/J) y campos de codificación
        self.instructions: Dict[str, Dict] = {
            # Formato R (operaciones aritméticas y lógicas)
            'add': {'type':'R','opcode':0b0110011,'funct3':0b000,'funct7':0b0000000},
            'sub': {'type':'R','opcode':0b0110011,'funct3':0b000,'funct7':0b0100000},
            'sll': {'type':'R','opcode':0b0110011,'funct3':0b001,'funct7':0b0000000},
            'slt': {'type':'R','opcode':0b0110011,'funct3':0b010,'funct7':0b0000000},
            'sltu':{'type':'R','opcode':0b0110011,'funct3':0b011,'funct7':0b0000000},
            'xor': {'type':'R','opcode':0b0110011,'funct3':0b100,'funct7':0b0000000},
            'srl': {'type':'R','opcode':0b0110011,'funct3':0b101,'funct7':0b0000000},
            'sra': {'type':'R','opcode':0b0110011,'funct3':0b101,'funct7':0b0100000},
            'or':  {'type':'R','opcode':0b0110011,'funct3':0b110,'funct7':0b0000000},
            'and': {'type':'R','opcode':0b0110011,'funct3':0b111,'funct7':0b0000000},

            # Formato I (inmediatos, cargas, jalr)
            'addi': {'type':'I','opcode':0b0010011,'funct3':0b000},
            'slti': {'type':'I','opcode':0b0010011,'funct3':0b010},
            'sltiu':{'type':'I','opcode':0b0010011,'funct3':0b011},
            'xori': {'type':'I','opcode':0b0010011,'funct3':0b100},
            'ori':  {'type':'I','opcode':0b0010011,'funct3':0b110},
            'andi': {'type':'I','opcode':0b0010011,'funct3':0b111},
            'slli': {'type':'I','opcode':0b0010011,'funct3':0b001,'funct7':0b0000000},
            'srli': {'type':'I','opcode':0b0010011,'funct3':0b101,'funct7':0b0000000},
            'srai': {'type':'I','opcode':0b0010011,'funct3':0b101,'funct7':0b0100000},
            'lb':   {'type':'I','opcode':0b0000011,'funct3':0b000},
            'lh':   {'type':'I','opcode':0b0000011,'funct3':0b001},
            'lw':   {'type':'I','opcode':0b0000011,'funct3':0b010},
            'lbu':  {'type':'I','opcode':0b0000011,'funct3':0b100},
            'lhu':  {'type':'I','opcode':0b0000011,'funct3':0b101},
            'jalr': {'type':'I','opcode':0b1100111,'funct3':0b000},
            'ecall':{'type':'I','opcode':0b1110011,'funct3':0b000,'imm':0},
            'ebreak':{'type':'I','opcode':0b1110011,'funct3':0b000,'imm':1},
            'fence':{'type':'I','opcode':0b0001111,'funct3':0b000},

            # Formato S (almacenamientos)
            'sb': {'type':'S','opcode':0b0100011,'funct3':0b000},
            'sh': {'type':'S','opcode':0b0100011,'funct3':0b001},
            'sw': {'type':'S','opcode':0b0100011,'funct3':0b010},

            # Formato B (saltos condicionales)
            'beq': {'type':'B','opcode':0b1100011,'funct3':0b000},
            'bne': {'type':'B','opcode':0b1100011,'funct3':0b001},
            'blt': {'type':'B','opcode':0b1100011,'funct3':0b100},
            'bge': {'type':'B','opcode':0b1100011,'funct3':0b101},
            'bltu':{'type':'B','opcode':0b1100011,'funct3':0b110},
            'bgeu':{'type':'B','opcode':0b1100011,'funct3':0b111},

            # Formato U (cargas de inmediatos grandes)
            'lui':  {'type':'U','opcode':0b0110111},
            'auipc':{'type':'U','opcode':0b0010111},

            # Formato J (saltos largos)
            'jal': {'type':'J','opcode':0b1101111},
        }

        # -----------------------------
        # PSEUDOINSTRUCCIONES
        # -----------------------------
        # Lista de mnemónicos que no existen en la ISA real,
        # pero que este ensamblador traduce a instrucciones válidas.
        self.pseudo_instructions = {
            'nop','mv','not','neg','seqz','snez','sltz','sgtz',
            'beqz','bnez','blez','bgez','bltz','bgtz',
            'bgt','ble','bgtu','bleu',
            'j','jal','jr','jalr','ret','call','tail','li','la'
        }

        # Tabla de labels: en primera pasada guardamos (segment, offset)
        self.label_positions: Dict[str, Tuple[str,int]] = {}
        # Al final, labels -> direccion absoluta (bytes)
        self.labels: Dict[str,int] = {}

        # parsed_lines: (segment, lineno, label, instr, operands)
        self.parsed_lines: List[Tuple[str,int,Optional[str],str,List[str]]] = []

        self.current_segment = 'text'
        self.text_size = 0
        self.data_size = 0

    # ---------------------------------------------------------
    # FUNCIONES AUXILIARES
    # ---------------------------------------------------------

    """
    Convierte una cadena que representa un número a entero.
    - Soporta decimal, hexadecimal (0x...), binario (0b...).
    - También maneja hex negativos del estilo -0x10.
    - Si no se puede convertir, lanza AssemblerError.
    """
    def parse_immediate(self, s: str) -> int:
        s = s.strip()
        if s == '':
            raise AssemblerError("Inmediato vacÃ­o")
        try:
            if s.startswith('-0x') or s.startswith('-0X'):
                return -int(s[3:], 16)
            if s.startswith('0x') or s.startswith('0X'):
                return int(s, 16)
            if s.startswith('0b') or s.startswith('0B'):
                return int(s, 2)
            return int(s, 0)
        except ValueError:
            raise AssemblerError(f"Inmediato invÃ¡lido: '{s}'")

    """
    Convierte el nombre de un registro (ej: 'a0', 'x5') en su número entero.
    - Se normaliza a minúscula y se eliminan espacios.
    - Si no existe en la tabla de registros, se lanza error.
    """
    def get_register_number(self, reg: str) -> int:
        r = reg.strip().lower()
        if r in self.registers:
            return self.registers[r]
        raise AssemblerError(f"Registro invÃ¡lido: {reg}")

    """
    Analiza operandos tipo offset(registro), por ejemplo:
        '12(sp)' o 'label(x0)'
    - Usa regex para separar el offset (que puede ser número o etiqueta)
      y el nombre del registro.
    - Devuelve (offset, número de registro).
    - Si el offset es una etiqueta, intenta resolverla:
      * Si ya está en self.labels -> usa esa dirección.
      * Si está en label_positions pero no resuelta aún -> usa 0 como placeholder.
      * Si no existe -> también 0, esperando resolución posterior.
    """
    def parse_memory_operand(self, operand: str) -> Tuple[int,int]:
        operand = operand.strip()
        m = re.match(r'^([-\w+]+)\((\w+)\)$', operand)
        if not m:
            raise AssemblerError(f"Formato de memoria invÃ¡lido: {operand}")
        offset_str, reg_str = m.group(1), m.group(2)
        try:
            offset = self.parse_immediate(offset_str)
        except AssemblerError:
            # puede ser label => placeholder 0 en primera pasada
            if offset_str in self.labels:
                offset = self.labels[offset_str]
            elif offset_str in self.label_positions:
                offset = 0
            else:
                offset = 0
        rs = self.get_register_number(reg_str)
        return offset, rs

    """
    Divide una línea de código fuente en:
      (etiqueta, instrucción, lista de operandos)
    - Elimina comentarios después de '#'.
    - Detecta etiquetas seguidas de ':'.
    - Maneja operandos separados por comas, cuidando paréntesis (no corta dentro de '12(sp)').
    """
    def tokenize_line(self, line: str) -> Tuple[Optional[str], Optional[str], List[str]]:
        line_stripped = line.split('#')[0].strip()
        if not line_stripped:
            return None, None, []
        label = None
        if ':' in line_stripped:
            parts = line_stripped.split(':',1)
            label = parts[0].strip()
            line_stripped = parts[1].strip()
            if not line_stripped:
                return label, None, []
        parts = line_stripped.split(None,1)
        instr = parts[0].lower()
        operands: List[str] = []
        if len(parts) > 1:
            op_str = parts[1]
            cur = ''
            paren = 0
            for ch in op_str + ',':
                if ch == ',' and paren == 0:
                    if cur.strip():
                        operands.append(cur.strip())
                    cur = ''
                else:
                    if ch == '(':
                        paren += 1
                    elif ch == ')':
                        paren -= 1
                    cur += ch
            operands = [o.strip() for o in operands if o.strip()]
        return label, instr, operands

    # ----------------------------
    # Expansion de pseudoinstrucciones
    # ----------------------------

    """
    Expande pseudoinstrucciones a instrucciones reales del conjunto RV32I.
    - Devuelve una lista de tuplas (instrucción_real, [operandos]).
    - Si la instrucción no es pseudo, la devuelve tal cual.
    """
    def expand_pseudo_instruction(self, instruction: str, operands: List[str]) -> List[Tuple[str,List[str]]]:
        out: List[Tuple[str,List[str]]] = []
        TMP = 't0'  # registro temporal

        # -----------------------------
        # CASOS BÁSICOS
        # -----------------------------
        if instruction == 'nop':
            out.append(('addi',['x0','x0','0']))
        elif instruction == 'mv':
            if len(operands)!=2: raise AssemblerError("mv requiere 2 operandos")
            out.append(('addi',[operands[0],operands[1],'0']))
        elif instruction == 'not':
            if len(operands)!=2: raise AssemblerError("not requiere 2 operandos")
            out.append(('xori',[operands[0],operands[1],'-1']))
        elif instruction == 'neg':
            if len(operands)!=2: raise AssemblerError("neg requiere 2 operandos")
            out.append(('sub',[operands[0],'x0',operands[1]]))
        
        # -----------------------------
        # CONDICIONALES: "set on ..."
        # -----------------------------
        elif instruction == 'seqz':
            out.append(('sltiu',[operands[0],operands[1],'1']))
        elif instruction == 'snez':
            out.append(('sltu',[operands[0],'x0',operands[1]]))
        elif instruction == 'sltz':
            out.append(('slt',[operands[0],operands[1],'x0']))
        elif instruction == 'sgtz':
            out.append(('slt',[operands[0],'x0',operands[1]]))

        # -----------------------------
        # SALTOS CONDICIONALES SIMPLIFICADOS
        # -----------------------------
        elif instruction == 'beqz':
            out.append(('beq',[operands[0],'x0',operands[1]]))
        elif instruction == 'bnez':
            out.append(('bne',[operands[0],'x0',operands[1]]))
        elif instruction == 'blez':
            out.append(('bge',['x0',operands[0],operands[1]]))
        elif instruction == 'bgez':
            out.append(('bge',[operands[0],'x0',operands[1]]))
        elif instruction == 'bltz':
            out.append(('blt',[operands[0],'x0',operands[1]]))
        elif instruction == 'bgtz':
            out.append(('blt',['x0',operands[0],operands[1]]))

        # Comparaciones entre registros
        elif instruction == 'bgt':
            if len(operands)!=3: raise AssemblerError("bgt requiere 3 operandos")
            out.append(('blt',[operands[1],operands[0],operands[2]]))
        elif instruction == 'ble':
            if len(operands)!=3: raise AssemblerError("ble requiere 3 operandos")
            out.append(('bge',[operands[1],operands[0],operands[2]]))
        elif instruction == 'bgtu':
            if len(operands)!=3: raise AssemblerError("bgtu requiere 3 operandos")
            out.append(('bltu',[operands[1],operands[0],operands[2]]))
        elif instruction == 'bleu':
            if len(operands)!=3: raise AssemblerError("bleu requiere 3 operandos")
            out.append(('bgeu',[operands[1],operands[0],operands[2]]))

        # SALTOS / RETORNOS
        elif instruction == 'j':
            if len(operands)!=1: raise AssemblerError("j requiere 1 operando")
            out.append(('jal',['x0',operands[0]]))
        elif instruction == 'jal':
            # allow pseudo 'jal label' -> rd = ra
            if len(operands)==1:
                out.append(('jal',['ra',operands[0]]))
            elif len(operands)==2:
                out.append(('jal',[operands[0],operands[1]]))
            else:
                raise AssemblerError("jal requiere 1 o 2 operandos")
        elif instruction == 'jr':
            if len(operands)!=1: raise AssemblerError("jr requiere 1 operando")
            out.append(('jalr',['x0',operands[0]]))
        elif instruction == 'jalr':
            # allow pseudo 'jalr rs' -> jalr ra, rs, 0
            if len(operands)==1:
                out.append(('jalr',['ra',operands[0]]))
            else:
                out.append(('jalr',operands))

        elif instruction == 'ret':
            out.append(('jalr',['x0','ra']))

        # call / tail: expand to auipc + jalr sequences for far calls
        elif instruction == 'call':
            # call label  -> auipc ra, upper; jalr ra, ra, lower
            if len(operands)!=1: raise AssemblerError("call requiere 1 operando")
            label = operands[0]
            # We'll emit auipc + jalr; actual immediate parts resolved in second pass via la-like logic
            out.append(('auipc',['ra',label]))      # we will allow auipc to take label and be resolved similarly to la
            out.append(('jalr',['ra','ra',label]))  # jalr rd=ra, rs1=ra, imm=lower (resolved)
        elif instruction == 'tail':
            # tail label -> auipc t1, upper; jalr x0, t1, lower (x6==t1 mapping considered: using t1)
            if len(operands)!=1: raise AssemblerError("tail requiere 1 operando")
            label = operands[0]
            out.append(('auipc',['t1',label]))
            out.append(('jalr',['x0','t1',label]))

        # CARGA DE INMEDIATOS
        elif instruction == 'la':
            if len(operands)!=2: raise AssemblerError("la requiere 2 operandos")
            rd, label = operands[0], operands[1]
            # If label already known and small, addi; else generate lui + addi placeholders;
            if label in self.labels:
                addr = self.labels[label]
                if -2048 <= addr <= 2047:
                    out.append(('addi',[rd,'x0',str(addr)]))
                else:
                    upper = (addr + 0x800) >> 12
                    lower = addr & 0xFFF
                    if lower >= 0x800:
                        lower -= 0x1000
                    out.append(('lui',[rd,str(upper & 0xFFFFF)]))
                    if lower != 0:
                        out.append(('addi',[rd,rd,str(lower)]))
            else:
                # placeholder (resolve in second pass by interpreting label operand at encode time)
                out.append(('lui',[rd,'0']))
                out.append(('addi',[rd,rd,'0']))

        elif instruction == 'li':
            if len(operands)!=2: raise AssemblerError("li requiere 2 operandos")
            rd = operands[0]
            try:
                imm = self.parse_immediate(operands[1])
                if -2048 <= imm <= 2047:
                    out.append(('addi',[rd,'x0',str(imm)]))
                else:
                    upper = (imm + 0x800) >> 12
                    lower = imm & 0xFFF
                    if lower >= 0x800:
                        lower -= 0x1000
                    out.append(('lui',[rd,str(upper & 0xFFFFF)]))
                    if lower != 0:
                        out.append(('addi',[rd,rd,str(lower)]))
            except AssemblerError:
                # label -> la
                out.extend(self.expand_pseudo_instruction('la',[rd,operands[1]]))

        # Loads/stores by symbol: lw rd, symbol  => la t0,symbol ; lw rd, 0(t0)
        elif instruction in ('lb','lh','lw') and len(operands)==2 and '(' not in operands[1]:
            rd, sym = operands[0], operands[1]
            out.extend(self.expand_pseudo_instruction('la',[TMP, sym]) if False else self.expand_pseudo_instruction('la',[TMP := 't0', sym]))
            out.append((instruction,[rd,f'0({TMP})']))
        elif instruction in ('sb','sh','sw') and len(operands)==2 and '(' not in operands[1]:
            rs, sym = operands[0], operands[1]
            out.extend(self.expand_pseudo_instruction('la',[TMP := 't0', sym]))
            out.append((instruction,[rs,f'0({TMP})']))

        else:
            # not a recognized pseudo -> pass-through
            out.append((instruction, operands))

        return out

    # ----------------------------
    # Primera pasada
    # ----------------------------

    """
    Primera pasada sobre el código fuente:
    - Recorre línea por línea.
    - Identifica etiquetas y las guarda con su posición relativa dentro del segmento actual (.text o .data).
    - Expande pseudoinstrucciones (porque afectan al tamaño en bytes).
    - Actualiza los contadores text_size y data_size para saber cuánto mide cada segmento.
    """
    def first_pass(self, lines: List[str]):
        self.parsed_lines = []
        self.label_positions = {}
        self.text_size = 0
        self.data_size = 0
        self.current_segment = 'text'

        # Iteramos línea por línea del archivo fuente
        for lineno, raw in enumerate(lines, start=1):
            try:
                label, instr, ops = self.tokenize_line(raw)
                
                # Si hay una etiqueta, la guardamos con posición relativa
                if label:
                    if label in self.label_positions:
                        raise AssemblerError(f"Label duplicada: '{label}' en lÃ­nea {lineno}")
                    offset = self.text_size if self.current_segment == 'text' else self.data_size
                    self.label_positions[label] = (self.current_segment, offset)

                # Si no hay instrucción, saltamos
                if not instr:
                    continue

                # directivas de ensamblador
                if instr == '.text':
                    self.current_segment = 'text'
                    continue
                if instr == '.data':
                    self.current_segment = 'data'
                    continue

                if self.current_segment == 'data':
                    if instr == '.word':
                        # Reservar palabras en .data
                        self.parsed_lines.append(('data', lineno, label, '.word', ops))
                        self.data_size += 4 * len(ops)
                    else:
                        raise AssemblerError(f"Operacion invalida en .data: '{instr}' en li­nea {lineno}")
                    continue

                # text segment
                if self.current_segment == 'text':
                    # if pseudo or potential symbol-load/store: expand to know size
                    if instr in self.pseudo_instructions or (instr in ('lb','lh','lw','sb','sh','sw') and (len(ops)<2 or '(' not in ops[1])):
                        expanded = self.expand_pseudo_instruction(instr, ops)
                        for e_inst, e_ops in expanded:
                            if e_inst == '.word':
                                self.parsed_lines.append(('data', lineno, None, '.word', e_ops))
                                self.data_size += 4 * len(e_ops)
                            else:
                                self.parsed_lines.append(('text', lineno, None, e_inst, e_ops))
                                self.text_size += 4
                    elif instr in self.instructions:
                        self.parsed_lines.append(('text', lineno, label, instr, ops))
                        self.text_size += 4
                    else:
                        raise AssemblerError(f"Instruccion desconocida en .text: '{instr}' en li­nea {lineno}")

            except AssemblerError as e:
                raise AssemblerError(f"[Primera pasada] Li­nea {lineno}: {e}")

        # compute final label addresses: data placed immediately after text
        self.labels = {}
        for lbl, (seg, offset) in self.label_positions.items():
            if seg == 'text':
                addr = offset
            else:
                addr = self.text_size + offset
            self.labels[lbl] = addr

        return self.parsed_lines

    # ----------------------------
    # Encoders por tipo
    # ----------------------------

    """
    Codifica instrucciones tipo R (R-type).
    - Requiere exactamente 3 operandos: rd, rs1, rs2.
    - Se ensamblan los campos funct7, rs2, rs1, funct3, rd y opcode en el formato binario.
    - Devuelve la instrucción codificada como entero de 32 bits.
    """
    def encode_r_type(self, info: Dict, operands: List[str], lineno:int) -> int:
        if len(operands)!=3:
            raise AssemblerError(f"[L{lineno}] R-type requiere 3 operandos")
        rd = self.get_register_number(operands[0])
        rs1 = self.get_register_number(operands[1])
        rs2 = self.get_register_number(operands[2])
        instr = (info['funct7'] << 25) | (rs2 << 20) | (rs1 << 15) | (info['funct3'] << 12) | (rd << 7) | info['opcode']
        return instr & 0xFFFFFFFF

    """
    Codifica instrucciones tipo I (I-type).
    - Puede representar operaciones con inmediatos, cargas y jalr.
    - Maneja casos especiales:
        * Desplazamientos (slli, srli, srai) -> encoding de shamt y funct7.
        * Formato offset(rs1) en accesos a memoria.
        * Instrucciones jalr con o sin desplazamiento.
    - Valida que el inmediato esté en rango de 12 bits (-2048..2047).
    - Devuelve la instrucción codificada como entero de 32 bits.
    """
    def encode_i_type(self, info: Dict, operands: List[str], lineno:int) -> int:
        if len(operands) < 2:
            raise AssemblerError(f"[L{lineno}] I-type requiere al menos 2 operandos")
        rd = self.get_register_number(operands[0])

        # shifts (slli,srli,srai)
        if 'funct7' in info and info.get('funct3') in (0b001, 0b101):
            if len(operands)!=3:
                raise AssemblerError(f"[L{lineno}] Shift inmediato requiere 3 operandos")
            rs1 = self.get_register_number(operands[1])
            shamt = self.parse_immediate(operands[2])
            if shamt < 0 or shamt > 31:
                raise AssemblerError(f"[L{lineno}] Shift amount fuera de rango")
            imm = ((info['funct7'] & 0x7F) << 5) | (shamt & 0x1F)
        elif '(' in operands[-1]:
            # load rd, offset(rs1)
            memory_operand = operands[-1]
            offset, rs1 = self.parse_memory_operand(memory_operand)
            imm = offset
        elif len(operands) == 3:
            rs1 = self.get_register_number(operands[1])
            imm = self.parse_immediate(operands[2])
        elif len(operands) == 2:
            # jalr rd, rs1  (imm=0) or jalr rd, offset(rs1)
            if '(' in operands[1]:
                try:
                    offset, rs1 = self.parse_memory_operand(operands[1])
                    imm = offset
                except AssemblerError:
                    rs1 = self.get_register_number(operands[1])
                    imm = 0
            else:
                rs1 = self.get_register_number(operands[1])
                imm = 0
        else:
            rs1 = 0
            imm = info.get('imm', 0)

        if imm < -2048 or imm > 2047:
            raise AssemblerError(f"[L{lineno}] Inmediato fuera de rango (-2048..2047): {imm}")

        imm = imm & 0xFFF
        instr = (imm << 20) | (rs1 << 15) | (info['funct3'] << 12) | (rd << 7) | info['opcode']
        return instr & 0xFFFFFFFF

    """
    Codifica instrucciones tipo S (S-type).
    - Usadas en operaciones de almacenamiento (sb, sh, sw).
    - Requiere dos operandos: rs2 (fuente de datos) y offset(rs1) (dirección destino).
    - Divide el inmediato en partes altas y bajas según el formato.
    - Devuelve la instrucción ensamblada en 32 bits.
    """
    def encode_s_type(self, info: Dict, operands: List[str], lineno:int) -> int:
        if len(operands)!=2:
            raise AssemblerError(f"[L{lineno}] S-type requiere 2 operandos")
        rs2 = self.get_register_number(operands[0])
        memory_operand = operands[1]
        offset, rs1 = self.parse_memory_operand(memory_operand)
        if offset < -2048 or offset > 2047:
            raise AssemblerError(f"[L{lineno}] Offset S-type fuera de rango: {offset}")
        imm = offset & 0xFFF
        imm_high = (imm >> 5) & 0x7F
        imm_low = imm & 0x1F
        instr = (imm_high << 25) | (rs2 << 20) | (rs1 << 15) | (info['funct3'] << 12) | (imm_low << 7) | info['opcode']
        return instr & 0xFFFFFFFF

    """
    Codifica instrucciones tipo B (B-type).
    - Usadas en saltos condicionales (beq, bne, blt, etc.).
    - Requiere 3 operandos: rs1, rs2 y label.
    - Calcula el offset relativo entre la instrucción actual y la etiqueta.
    - Valida que el offset esté alineado (par) y dentro del rango permitido (-4096..4094).
    - Rearma los bits dispersos del inmediato en el formato B.
    """
    def encode_b_type(self, info: Dict, operands: List[str], current_addr:int, lineno:int) -> int:
        if len(operands)!=3:
            raise AssemblerError(f"[L{lineno}] B-type requiere 3 operandos")
        rs1 = self.get_register_number(operands[0])
        rs2 = self.get_register_number(operands[1])
        label = operands[2]
        if label not in self.labels:
            raise AssemblerError(f"[L{lineno}] Label indefinida en branch: {label}")
        target = self.labels[label]
        offset = target - current_addr
        if offset % 2 != 0:
            raise AssemblerError(f"[L{lineno}] Offset de branch debe ser par: {offset}")
        if offset < -4096 or offset > 4094:
            raise AssemblerError(f"[L{lineno}] Offset de branch fuera de rango: {offset}")
        off = offset & 0x1FFE
        imm_12 = (off >> 12) & 0x1
        imm_10_5 = (off >> 5) & 0x3F
        imm_4_1 = (off >> 1) & 0xF
        imm_11 = (off >> 11) & 0x1
        instr = (imm_12 << 31) | (imm_10_5 << 25) | (rs2 << 20) | (rs1 << 15) | (info['funct3'] << 12) | (imm_4_1 << 8) | (imm_11 << 7) | info['opcode']
        return instr & 0xFFFFFFFF

    """
    Codifica instrucciones tipo U (U-type).
    - Usadas para cargar inmediatos grandes (lui, auipc).
    - Requiere 2 operandos: rd y un inmediato de 20 bits.
    - Valida que el inmediato esté dentro del rango [0, 2^20-1].
    - Devuelve la instrucción codificada en 32 bits.
    """
    def encode_u_type(self, info: Dict, operands: List[str], lineno:int) -> int:
        if len(operands)!=2:
            raise AssemblerError(f"[L{lineno}] U-type requiere 2 operandos")
        rd = self.get_register_number(operands[0])
        imm = self.parse_immediate(operands[1])
        if imm < 0 or imm > 0xFFFFF:
            raise AssemblerError(f"[L{lineno}] Inmediato U-type fuera de rango: {imm}")
        instr = (imm << 12) | (rd << 7) | info['opcode']
        return instr & 0xFFFFFFFF

    """
    Codifica instrucciones tipo J (J-type).
    - Usadas en saltos largos (jal).
    - Puede recibir 1 o 2 operandos:
        * 1 operando: se asume rd = ra (registro 1).
        * 2 operandos: explícitamente rd y label.
    - Calcula el offset relativo hacia la etiqueta y valida su rango (-2^20 .. 2^20-2).
    - Distribuye los bits del offset en el formato J.
    """
    def encode_j_type(self, info: Dict, operands: List[str], current_addr:int, lineno:int) -> int:
        if len(operands) not in (1,2):
            raise AssemblerError(f"[L{lineno}] J-type requiere 1 o 2 operandos")
        if len(operands)==2:
            rd = self.get_register_number(operands[0])
            label = operands[1]
        else:
            rd = 1  # ra por defecto
            label = operands[0]
        if label not in self.labels:
            raise AssemblerError(f"[L{lineno}] Label indefinida en jump: {label}")
        target = self.labels[label]
        offset = target - current_addr
        if offset % 2 != 0:
            raise AssemblerError(f"[L{lineno}] Offset de jump debe ser par: {offset}")
        if offset < -1048576 or offset > 1048574:
            raise AssemblerError(f"[L{lineno}] Offset de jump fuera de rango: {offset}")
        off = offset & 0x1FFFFE
        imm_20 = (off >> 20) & 0x1
        imm_10_1 = (off >> 1) & 0x3FF
        imm_11 = (off >> 11) & 0x1
        imm_19_12 = (off >> 12) & 0xFF
        instr = (imm_20 << 31) | (imm_19_12 << 12) | (imm_11 << 20) | (imm_10_1 << 21) | (rd << 7) | info['opcode']
        return instr & 0xFFFFFFFF

    # ----------------------------
    # Segunda pasada
    # ----------------------------

    """
    Segunda pasada del ensamblador.
    - Recorre las líneas parseadas en la primera pasada.
    - Traduce cada instrucción (según su tipo R/I/S/B/U/J) a código máquina de 32 bits.
    - Resuelve etiquetas ya definidas y las sustituye en inmediatos.
    - También procesa la sección de datos (.word), convirtiendo valores o referencias a enteros.
    - Devuelve:
        * Lista con instrucciones codificadas (machine_code).
        * Lista con palabras de datos (data_words).
    """
    def second_pass(self) -> Tuple[List[int], List[int]]:
        machine_code: List[int] = []
        data_words: List[int] = []
        current_address = 0

        for seg, lineno, label, instr, ops in self.parsed_lines:
            try:
                if seg == 'text':
                    if instr not in self.instructions:
                        raise AssemblerError(f"[L{lineno}] InstrucciÃ³n no soportada en segunda pasada: {instr}")
                    info = self.instructions[instr]
                    t = info['type']
                    if t == 'R':
                        code = self.encode_r_type(info, ops, lineno)
                    elif t == 'I':
                        code = self.encode_i_type(info, ops, lineno)
                    elif t == 'S':
                        code = self.encode_s_type(info, ops, lineno)
                    elif t == 'B':
                        # Las instrucciones B usan la dirección actual para calcular offsets
                        code = self.encode_b_type(info, ops, current_address, lineno)
                    elif t == 'U':
                        # auipc/lui might have a label operand in our expansions: handle if operand is label
                        # Si el operando inmediato es una etiqueta (p.e. auipc ra, label) la resolvemos aquí
                        if instr in ('lui','auipc') and len(ops)==2:
                            rd = ops[0]
                            imm_op = ops[1]
                            # Si imm_op no es literal numérico, tratarla como etiqueta
                            if isinstance(imm_op,str) and not re.match(r'^-?0x[0-9a-fA-F]+$|^-?\d+$', imm_op):
                                if imm_op not in self.labels:
                                    # label not resolved -> 0 placeholder
                                    imm = 0
                                else:
                                    addr = self.labels[imm_op]
                                    upper = (addr + 0x800) >> 12
                                    imm = upper & 0xFFFFF
                                info_local = info.copy()
                                # Reemplazamos el operando por el número calculado para llamar a encode_u_type
                                code = self.encode_u_type(info_local, [rd, str(imm)], lineno)
                            else:
                                code = self.encode_u_type(info, ops, lineno)
                        else:
                            code = self.encode_u_type(info, ops, lineno)
                    elif t == 'J':
                        # jal puede requerir calculo de offset relativo
                        code = self.encode_j_type(info, ops, current_address, lineno)
                    else:
                        raise AssemblerError(f"[L{lineno}] Tipo desconocido: {t}")
                    machine_code.append(code)
                    current_address += 4

                else:
                    # data segment (.word)
                    if instr == '.word':
                        for op in ops:
                            try:
                                # intentar parsear valor literal
                                val = self.parse_immediate(op)
                            except AssemblerError:
                                # si no es literal, intentar como label de datos
                                if op in self.labels:
                                    val = self.labels[op]
                                else:
                                    raise AssemblerError(f"[L{lineno}] Label de data indefinida: {op}")
                            data_words.append(val & 0xFFFFFFFF)
                    else:
                        raise AssemblerError(f"[L{lineno}] Directiva/operaciÃ³n de data no soportada: {instr}")

            except AssemblerError as e:
                # Calcular la dirección donde ocurrió el error para mensaje más claro
                addr = current_address if seg=='text' else (self.text_size + len(data_words)*4)
                raise AssemblerError(f"Error en direcciÃ³n 0x{addr:08x}: {e}")

        return machine_code, data_words

    # ----------------------------
    # Ensamblar archivo (end-to-end)
    # ----------------------------

    """
    Ensambla un archivo de principio a fin.
    - Lee el archivo fuente (.asm).
    - Ejecuta primera y segunda pasada.
    - Genera tres archivos de salida:
        * .bin → instrucciones/datos en binario (texto de 0s y 1s por línea).
        * .hex → direcciones + código en hexadecimal.
        * .txt → reporte detallado (dirección, asm, binario y hex).
    - Maneja excepciones (archivo inexistente, errores de ensamblado).
    """
    def assemble_file(self, input_file: str, hex_out: str, bin_out: str):
        try:
            with open(input_file, 'r', encoding='utf-8') as f:
                lines = f.readlines()

            # Primera pasada: parseo y tablas de etiquetas
            parsed = self.first_pass(lines)
            # parsed_lines asignadas ya por first_pass
            self.parsed_lines = parsed

            # Segunda pasada: codificar instrucciones y datos
            machine_code, data_words = self.second_pass()

            # escribir binario como TEXTO legible (0 y 1)
            with open(bin_out, 'w', encoding='utf-8') as fb:
                for w in machine_code:
                    fb.write(f"{w:032b}\n")   # 32 bits en binario
                for w in data_words:
                    fb.write(f"{w:032b}\n")   # también datos en binario

            # escribir hex con direcciones
            with open(hex_out, 'w', encoding='utf-8') as fh:
                # instrucciones
                for i, w in enumerate(machine_code):
                    addr = i * 4
                    fh.write(f"{addr:08x}: {w:08x}\n")
                # datos (empiezan en text_size)
                for i, w in enumerate(data_words):
                    addr = self.text_size + i * 4
                    fh.write(f"{addr:08x}: {w:08x}\n")

            # escribir archivo de texto detallado
            txt_out = hex_out.replace(".hex", ".txt")
            with open(txt_out, 'w', encoding='utf-8') as f:
                f.write("RISC-V Assembly to Machine Code\n")
                f.write("=" * 50 + "\n\n")

                # Instrucciones de .text
                for i, w in enumerate(machine_code):
                    addr = i * 4
                    binary = f"{w:032b}"
                    hex_code = f"{w:08x}"
                    asm_line = self.parsed_lines[i]

                    if asm_line[0] == "text":
                        _, lineno, label, instr, ops = asm_line
                        asm_str = f"{instr} {', '.join(ops)}"
                    else:
                        asm_str = "(instrucción expandida)"

                    f.write(f"Address: 0x{addr:08x}\n")
                    f.write(f"Assembly: {asm_str}\n")
                    f.write(f"Binary:   {binary}\n")
                    f.write(f"Hex:      {hex_code}\n")
                    f.write("-" * 40 + "\n")

                # Datos de .data
                for i, w in enumerate(data_words):
                    addr = self.text_size + i * 4
                    binary = f"{w:032b}"
                    hex_code = f"{w:08x}"
                    f.write(f"Address: 0x{addr:08x}\n")
                    f.write(f"Data (.word)\n")
                    f.write(f"Binary:   {binary}\n")
                    f.write(f"Hex:      {hex_code}\n")
                    f.write("-" * 40 + "\n")

            print(f"[OK] Ensamblado completado. {len(machine_code)} instrucciones, {len(data_words)} palabras de datos.")
            print(f"Hex -> {hex_out}")
            print(f"Bin -> {bin_out}")
            print(f"Txt -> {txt_out}")

        except FileNotFoundError:
            raise AssemblerError(f"Archivo de entrada no encontrado: {input_file}")
        except AssemblerError:
            raise
        except Exception as e:
            raise AssemblerError(f"Error durante ensamblado: {e}")

# ----------------------------
# entrypoint
# ----------------------------
def main():
    if len(sys.argv) != 4:
        print("Uso: python assembler.py program.asm program.hex program.bin")
        sys.exit(1)
    asm_file, hex_file, bin_file = sys.argv[1], sys.argv[2], sys.argv[3]
    assembler = RISCVAssembler()
    try:
        assembler.assemble_file(asm_file, hex_file, bin_file)
    except AssemblerError as e:
        print(f"[ERROR] {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()