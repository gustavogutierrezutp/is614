# ==============================================================================
# ENSAMBLADOR Y TRADUCTOR RISC-V (RV32I) - VERSIÓN COMPLETA
#
# Autor: Asistente de IA Gemini (con la colaboración del usuario)
# Fecha: Septiembre 2025
#
# Funcionalidades:
# - Implementa un ensamblador completo de dos pasadas.
# - Soporta el conjunto de instrucciones base RV32I.
# - Maneja directivas .text y .data (asignando direcciones a los datos).
# - Expande las pseudoinstrucciones más comunes.
# - Soporta las funciones de relocalización %hi() y %lo() para cargar direcciones.
# - Realiza un manejo robusto de errores de sintaxis, operandos y rango.
# - Ofrece un menú interactivo si no se usan argumentos de línea de comandos.
# - Genera un reporte detallado en pantalla, un archivo .txt con el reporte,
#   y archivos .bin y .hex con el código máquina puro.
# ==============================================================================

import re
import sys
import os
import platform
import subprocess

class RISCVTranslator:
    """
    Clase principal que encapsula toda la lógica del ensamblador.
    Mantiene el estado, como la tabla de registros y la tabla de símbolos (etiquetas).
    """

    def __init__(self):
        """
        Constructor de la clase. Inicializa las estructuras de datos.
        """
        # --- Tabla de Registros ---
        self.registers = {
            'zero': '00000', 'ra': '00001', 'sp': '00010', 'gp': '00011',
            'tp': '00100', 't0': '00101', 't1': '00110', 't2': '00111',
            's0': '01000', 'fp': '01000', 's1': '01001', 'a0': '01010',
            'a1': '01011', 'a2': '01100', 'a3': '01101', 'a4': '01110',
            'a5': '01111', 'a6': '10000', 'a7': '10001', 's2': '10010',
            's3': '10011', 's4': '10100', 's5': '10101', 's6': '10110',
            's7': '10111', 's8': '11000', 's9': '11001', 's10': '11010',
            's11': '11011', 't3': '11100', 't4': '11101', 't5': '11110',
            't6': '11111'
        }
        for i in range(32):
            self.registers[f'x{i}'] = format(i, '05b')

        # --- Tabla de Símbolos (Etiquetas) ---
        self.labels = {}

    def get_register_code(self, reg):
        """Devuelve el código binario de 5 bits para un registro."""
        reg = reg.lower().strip()
        if reg in self.registers:
            return self.registers[reg]
        raise ValueError(f"Registro no válido: '{reg}'")

    def to_binary(self, value, bits):
        """Convierte un número a binario en complemento a dos."""
        if isinstance(value, str):
            try:
                value = int(value, 0)
            except ValueError:
                raise ValueError(f"Valor inmediato inválido: '{value}'")
        if value < 0:
            value = (1 << bits) + value
        return format(value & ((1 << bits) - 1), f'0{bits}b')

    def find_labels(self, lines):
        """
        PRIMERA PASADA: Construye la tabla de símbolos (self.labels).
        Asigna direcciones de memoria a todas las etiquetas en .data y .text.
        """
        self.labels = {}
        code_address = 0
        data_address = 0x10010000  # Dirección base estándar para el segmento de datos
        in_data_segment = False

        for line in lines:
            clean_line = line.split('#', 1)[0].strip()
            if not clean_line: continue

            if clean_line.startswith('.'):
                if clean_line == '.data': in_data_segment = True
                elif clean_line == '.text': in_data_segment = False
                continue

            label = None
            m = re.match(r'^\s*([a-zA-Z_][a-zA-Z0-9_()]+):\s*(.*)$', clean_line)
            if m:
                label, clean_line = m.group(1), m.group(2).strip()

            if in_data_segment:
                if label: self.labels[label] = data_address
                if clean_line.startswith('.word'): data_address += 4
                elif clean_line.startswith('.space'): data_address += int(clean_line.split()[1])
            else:  # Segmento .text
                if label: self.labels[label] = code_address
                if clean_line:
                    expanded = self.expand_pseudoinstructions(clean_line)
                    code_address += len(expanded) * 4

    def get_immediate_value(self, imm_str):
        """
        Convierte un string de inmediato a un valor numérico.
        Soporta números, etiquetas y las funciones %hi() y %lo().
        """
        imm_str = imm_str.strip()
        
        match_lo = re.match(r'%lo\((\w+)\)', imm_str)
        if match_lo:
            label = match_lo.group(1)
            if label not in self.labels: raise ValueError(f"Etiqueta no definida para %lo: '{label}'")
            addr = self.labels[label]
            lower_12 = addr & 0xFFF
            return lower_12 if lower_12 < 2048 else lower_12 - 4096

        match_hi = re.match(r'%hi\((\w+)\)', imm_str)
        if match_hi:
            label = match_hi.group(1)
            if label not in self.labels: raise ValueError(f"Etiqueta no definida para %hi: '{label}'")
            addr = self.labels[label]
            return (addr + 0x800) >> 12

        try:
            return int(imm_str, 0)
        except ValueError:
            raise ValueError(f"Valor inmediato o expresión inválida: '{imm_str}'")

    def parse_r_type(self, parts, opcode, func3, func7='0000000'):
        rd, rs1, rs2 = map(self.get_register_code, [parts[1].strip(','), parts[2].strip(','), parts[3]])
        return func7 + rs2 + rs1 + func3 + rd + opcode

    def parse_i_type(self, parts, opcode, func3):
        rd, rs1 = self.get_register_code(parts[1].strip(',')), self.get_register_code(parts[2].strip(','))
        imm_val = self.get_immediate_value(parts[3])
        if not -2048 <= imm_val <= 2047:
            raise ValueError(f"Inmediato '{imm_val}' fuera de rango para I-type (-2048 a 2047)")
        imm = self.to_binary(imm_val, 12)
        return imm + rs1 + func3 + rd + opcode

    def parse_u_type(self, parts, opcode):
        rd = self.get_register_code(parts[1].strip(','))
        imm_val = self.get_immediate_value(parts[2])
        if not 0 <= imm_val <= 0xFFFFF:
            raise ValueError(f"Inmediato '{imm_val}' fuera de rango para U-type (0 a 1048575)")
        imm = self.to_binary(imm_val, 20)
        return imm + rd + opcode

    def parse_load_store_type(self, parts, opcode, func3, is_store=False):
        reg_part, mem_part = parts[1].strip(','), parts[2].strip()
        match = re.match(r'(.+)\((\w+)\)', mem_part)
        if not match: raise ValueError(f"Formato de memoria inválido: '{mem_part}'")
        
        offset_val = self.get_immediate_value(match.group(1))
        if not -2048 <= offset_val <= 2047:
            raise ValueError(f"Offset '{offset_val}' fuera de rango (-2048 a 2047)")
        
        rs1 = self.get_register_code(match.group(2))
        imm = self.to_binary(offset_val, 12)

        if is_store: # Formato S-Type
            rs2 = self.get_register_code(reg_part)
            return imm[0:7] + rs2 + rs1 + func3 + imm[7:12] + opcode
        else: # Formato I-Type (Load)
            rd = self.get_register_code(reg_part)
            return imm + rs1 + func3 + rd + opcode

    def parse_b_type(self, parts, opcode, func3, current_addr):
        rs1, rs2, label = self.get_register_code(parts[1].strip(',')), self.get_register_code(parts[2].strip(',')), parts[3].strip()
        if label not in self.labels: raise ValueError(f"Etiqueta no definida: '{label}'")
        offset = self.labels[label] - current_addr
        if not -4096 <= offset <= 4094: raise ValueError(f"Offset para '{label}' ({offset}) fuera de rango")
        imm13 = self.to_binary(offset, 13)
        return imm13[0] + imm13[2:8] + rs2 + rs1 + func3 + imm13[8:12] + imm13[1] + opcode

    def parse_j_type(self, parts, opcode, current_addr):
        rd, label = self.get_register_code(parts[1].strip(',')), parts[2].strip()
        if label not in self.labels: raise ValueError(f"Etiqueta no definida: '{label}'")
        offset = self.labels[label] - current_addr
        if not -1048576 <= offset <= 1048574: raise ValueError(f"Offset para '{label}' ({offset}) fuera de rango")
        imm21 = self.to_binary(offset, 21)
        return imm21[0] + imm21[10:20] + imm21[9] + imm21[1:9] + rd + opcode
    
    def expand_pseudoinstructions(self, instruction):
        """
        Expande pseudoinstrucciones a instrucciones base.
        Esta versión incluye el conjunto completo de pseudoinstrucciones estándar de RV32I.
        """
        parts = re.split(r'[\s,]+', instruction.strip())
        opcode = parts[0].lower()
        
        # --- Carga de valores ---
        if opcode == 'li':
            rd, imm_str = parts[1].strip(','), parts[2]
            try:
                imm = self.get_immediate_value(imm_str)
            except ValueError:
                return [instruction]  # Dejar que el parser principal lo marque como error
            if -2048 <= imm <= 2047:
                return [f"addi {rd}, zero, {imm}"]
            else:
                upper = (imm + 0x800) >> 12
                lower = imm & 0xFFF
                if lower > 2047: lower -= 4096
                result = [f"lui {rd}, {upper}"]
                if lower != 0:
                    result.append(f"addi {rd}, {rd}, {lower}")
                return result

        # --- Operaciones entre registros ---
        elif opcode == 'mv':
            return [f"addi {parts[1].strip(',')}, {parts[2]}, 0"]
        elif opcode == 'not':
            return [f"xori {parts[1].strip(',')}, {parts[2]}, -1"]
        elif opcode == 'neg':
            return [f"sub {parts[1].strip(',')}, zero, {parts[2]}"]
        
        # --- Comparaciones con Cero (Set if...) ---
        elif opcode == 'seqz':
            return [f"sltiu {parts[1].strip(',')}, {parts[2]}, 1"]
        elif opcode == 'snez':
            return [f"sltu {parts[1].strip(',')}, zero, {parts[2]}"]
        elif opcode == 'sltz':
            return [f"slt {parts[1].strip(',')}, {parts[2]}, zero"]
        elif opcode == 'sgtz':
            return [f"slt {parts[1].strip(',')}, zero, {parts[2]}"]

        # --- Saltos Condicionales contra Cero (Branch if...) ---
        elif opcode == 'beqz':
            return [f"beq {parts[1].strip(',')}, zero, {parts[2]}"]
        elif opcode == 'bnez':
            return [f"bne {parts[1].strip(',')}, zero, {parts[2]}"]
        elif opcode == 'blez':
            return [f"bge zero, {parts[1].strip(',')}, {parts[2]}"]
        elif opcode == 'bgez':
            return [f"bge {parts[1].strip(',')}, zero, {parts[2]}"]
        elif opcode == 'bltz':
            return [f"blt {parts[1].strip(',')}, zero, {parts[2]}"]
        elif opcode == 'bgtz':
            return [f"blt zero, {parts[1].strip(',')}, {parts[2]}"]
            
        # --- Saltos y Llamadas ---
        elif opcode == 'j':
            return [f"jal zero, {parts[1]}"]
        elif opcode == 'jr':
            return [f"jalr zero, {parts[1]}, 0"]
        elif opcode == 'ret':
            return ["jalr zero, ra, 0"]
        elif opcode == 'call':
            return [f"jal ra, {parts[1]}"]
        elif opcode == 'tail':
            return [f"jal zero, {parts[1]}"]
        
        # --- Misceláneos ---
        elif opcode == 'nop':
            return ["addi zero, zero, 0"]
        
        # Si no es una pseudoinstrucción conocida, la devuelve tal cual.
        return [instruction]

  
    def translate_instruction(self, instruction, current_addr):
        """Despachador principal: selecciona el parser adecuado para cada instrucción."""
        parts = re.split(r'[\s,]+', instruction)
        op = parts[0].lower()
        # Mapeos para simplificar la selección
        R_TYPES = {'add':'000', 'sub':'000', 'xor':'100', 'or':'110', 'and':'111', 'sll':'001', 'srl':'101', 'sra':'101', 'slt':'010', 'sltu':'011'}
        I_TYPES = {'addi':'000', 'xori':'100', 'ori':'110', 'andi':'111', 'slti':'010', 'sltiu':'011', 'jalr':'000'}
        LOAD_TYPES = {'lb':'000', 'lh':'001', 'lw':'010', 'lbu':'100', 'lhu':'101'}
        STORE_TYPES = {'sb':'000', 'sh':'001', 'sw':'010'}
        BRANCH_TYPES = {'beq':'000', 'bne':'001', 'blt':'100', 'bge':'101', 'bltu':'110', 'bgeu':'111'}
        
        if op in R_TYPES: return self.parse_r_type(parts, '0110011', R_TYPES[op], '0100000' if op in ['sub', 'sra'] else '0000000')
        if op in I_TYPES: return self.parse_i_type(parts, '1100111' if op == 'jalr' else '0010011', I_TYPES[op])
        if op in LOAD_TYPES: return self.parse_load_store_type(parts, '0000011', LOAD_TYPES[op], is_store=False)
        if op in STORE_TYPES: return self.parse_load_store_type(parts, '0100011', STORE_TYPES[op], is_store=True)
        if op in BRANCH_TYPES: return self.parse_b_type(parts, '1100011', BRANCH_TYPES[op], current_addr)
        if op in ['lui', 'auipc']: return self.parse_u_type(parts, '0110111' if op == 'lui' else '0010111')
        if op == 'jal': return self.parse_j_type(parts, '1101111', current_addr)
        raise SyntaxError(f"Instrucción no soportada o mal formada: '{op}'")

    def assemble(self, assembly_code):
        """
        Orquestador principal. Realiza las dos pasadas y genera todos los productos finales.
        Returns:
            tuple: (reporte_string, lista_binaria, lista_hexadecimal)
        """
        lines = assembly_code.strip().split('\n')
        self.find_labels(lines)
        
        report_lines, bin_lines, hex_lines = [], [], []
        address, in_data_segment = 0, False
        
        for i, line in enumerate(lines, 1):
            original_line = line.rstrip('\n')
            clean_line = original_line.split('#', 1)[0].strip()

            if not clean_line or clean_line.startswith('.'):
                report_lines.append(f"Línea {i:2d}: {original_line}")
                if clean_line == '.data': in_data_segment = True
                elif clean_line == '.text': in_data_segment = False; address = 0
                continue
            if in_data_segment:
                report_lines.append(f"Línea {i:2d}: {original_line}")
                continue

            try:
                instruction_to_process, label_info = clean_line, ""
                m = re.match(r'^\s*([a-zA-Z_][a-zA-Z0-9_()]+):\s*(.*)$', clean_line)
                if m:
                    label, instruction_to_process = m.group(1), m.group(2).strip()
                    label_info = f"🏷️  Etiqueta '{label}' en PC=0x{self.labels.get(label, 0):08X}"
                
                report_lines.append(f"Línea {i:2d}: {original_line}")
                if label_info: report_lines.append(f"        {label_info}")
                if not instruction_to_process: continue

                expanded = self.expand_pseudoinstructions(instruction_to_process)
                if len(expanded) > 1:
                    report_lines.append(f"        (Pseudoinstrucción expandida)")
                
                for inst in expanded:
                    binary = self.translate_instruction(inst, address)
                    bin_lines.append(binary)
                    hex_lines.append(f"{int(binary, 2):08x}")
                    
                    formatted_bin = " ".join(binary[i:i+4] for i in range(0, 32, 4))
                    hex_val = f"0x{int(binary, 2):08X}"
                    report_lines.append(f" PC=0x{address:04X} | {inst:<25} | Hex: {hex_val} | Bin: {formatted_bin}")
                    address += 4
            except (ValueError, SyntaxError, IndexError) as e:
                report_lines.append(f" ❌ ERROR: {e}")

        if self.labels:
            report_lines.append("\n" + "="*50)
            report_lines.append("📋 TABLA DE SÍMBOLOS (ETIQUETAS):")
            for label, addr in sorted(self.labels.items()):
                report_lines.append(f"🏷️  {label:<25} → Dirección (PC) = 0x{addr:08X}")
            report_lines.append("="*50)

        return '\n'.join(report_lines), bin_lines, hex_lines

# --------------------------------------------------------------------------
# SECCIÓN PRINCIPAL DE EJECUCIÓN
# --------------------------------------------------------------------------

def open_file_in_os(filepath):
    """Abre un archivo con la aplicación predeterminada del sistema."""
    if not filepath: return
    try:
        if platform.system() == 'Windows': os.startfile(filepath)
        elif platform.system() == 'Darwin': subprocess.run(['open', filepath], check=True)
        else: subprocess.run(['xdg-open', filepath], check=True)
    except Exception as e:
        print(f"⚠️ No se pudo abrir el archivo de reporte automáticamente. Error: {e}")

def main():
    """Punto de entrada del script."""
    if len(sys.argv) not in [1, 2]:
        print("\n❌ Uso: python tu_script.py [archivo_entrada.asm]")
        sys.exit(1)

    input_file = ""
    if len(sys.argv) == 2:
        input_file = sys.argv[1]
    else:
        print("\n" + "="*60)
        print("⚙️  Ensamblador RISC-V Interactivo")
        print("="*60)
        input_file = input("➡️  Ingrese el nombre del archivo de entrada (.asm): ").strip()

    base_name = input_file.rsplit('.', 1)[0]
    report_output_file = f"{base_name}_reporte.txt"
    bin_output_file = f"{base_name}.bin"
    hex_output_file = f"{base_name}.hex"

    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            assembly_code = f.read()
    except FileNotFoundError:
        print(f"\n❌ Error: El archivo de entrada '{input_file}' no fue encontrado.")
        sys.exit(1)

    translator = RISCVTranslator()
    print(f"\n🔄 Ensamblando '{input_file}'...")
    
    reporte_final, bin_lines, hex_lines = translator.assemble(assembly_code)
    
    print("\n" + "="*80)
    print("📋 REPORTE DE ENSAMBLAJE")
    print("="*80)
    print(reporte_final)
    
    try:
        with open(report_output_file, 'w', encoding='utf-8') as f: f.write(reporte_final)
        with open(bin_output_file, 'w', encoding='utf-8') as f: f.write('\n'.join(bin_lines))
        with open(hex_output_file, 'w', encoding='utf-8') as f: f.write('\n'.join(hex_lines))
        
        print(f"\n✅ Archivos de salida generados:")
        print(f"   - Reporte Detallado: '{report_output_file}'")
        print(f"   - Binario:           '{bin_output_file}'")
        print(f"   - Hexadecimal:       '{hex_output_file}'")
        
        open_file_in_os(report_output_file)
    except IOError as e:
        print(f"\n❌ Error al guardar los archivos de salida: {e}")

if __name__ == "__main__":
    main()