"""
Script para extraer el segmento .data de un programa ensamblado y guardarlo en un archivo .hex
"""
import sys
import os
from core.ensamblador import Ensamblador

def extraer_data_a_hex(archivo_asm, archivo_hex):
    # Leer el archivo ASM
    with open(archivo_asm, 'r', encoding='utf-8') as f:
        lineas = f.readlines()
    
    # Ensamblar el programa
    ensamblador = Ensamblador()
    resultado = ensamblador.ensamblar(lineas)
    if resultado is None:
        print("Error: El ensamblador reportó errores.")
        return False
    
    segmento_data = resultado['data']
    if not segmento_data:
        print("No se encontró segmento .data inicializado.")
        return False
    
    # Escribir el contenido en formato hexadecimal
    with open(archivo_hex, 'w', encoding='utf-8') as f:
        for byte in segmento_data:
            f.write(f"{byte:02X}\n")
    print(f"Archivo .hex generado correctamente: {archivo_hex}")
    return True

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Uso: python extract_data_hex.py <programa.asm> <salida.hex>")
        sys.exit(1)
    archivo_asm = sys.argv[1]
    archivo_hex = sys.argv[2]
    extraer_data_a_hex(archivo_asm, archivo_hex)
