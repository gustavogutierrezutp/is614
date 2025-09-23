import sys
from src.pass1 import build_symbol_table
from src.pass2 import assemble
from src.utils import format_hex, format_bin

def main():
    if len(sys.argv) != 4:
        print("\npython assembler.py input/program.asm output/program.hex output/program.bin\n")
        sys.exit(1)

    input_file, hex_file, bin_file = sys.argv[1:]

    # Primera pasada
    #print("Ejecutando la primera pasada...")
    symbol_table, instructions = build_symbol_table(input_file)

    # Segunda pasada
    #print("Ejecutando la segunda pasada...")
    words = assemble(instructions, symbol_table)

    # Guardar resultados
    print("\nEjecucion completa.")
    print(f"\nArchivos guardados en:\n * Binario --> {bin_file}\n * Hexadecimal --> {hex_file}\n")
    with open(hex_file, "w", encoding="utf-8") as f:
        for w in words:
            f.write(format_hex(w) + "\n")

    with open(bin_file, "w", encoding="utf-8") as f:
        for w in words:
            f.write(format_bin(w) + "\n")

if __name__ == "__main__":
    main()
