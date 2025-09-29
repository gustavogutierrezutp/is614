from src.pass1 import first_pass
from src.pass2 import second_pass, write_bin, write_hex

def main():
    input_file = "input/program.asm"
    hex_file = "output/program.hex"
    bin_file = "output/program.bin"

    # Primera pasada
    symtab = first_pass(input_file)
    print("Tabla de símbolos:")
    for label, addr in symtab.dump().items():
        print(f"{label}: {addr:08X}")

    # Segunda pasada
    program = second_pass(input_file, symtab)

    # Escribir archivos de salida
    write_bin(bin_file, program)
    write_hex(hex_file, program)
    print("Archivos generados en 'output'")

if __name__ == "__main__":
    main()
