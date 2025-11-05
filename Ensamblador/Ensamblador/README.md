# Ensamblador RV32I en Python

Este proyecto implementa un ensamblador para la arquitectura RISC-V (RV32I) en Python.
Convierte código en ensamblador RISC-V a su representación binaria de 32 bits y hexadecimal

# Estructura del proyecto

-   ## assembler.py
    Es el archivo principal que gestiona el proceso de ensamblado:
    - Recibe un archivo .asm y realiza un proceso de dos pasadas para identificar etiquetas y directivas, realizando un diccionario de las mismas en la primera pasada y asi codificar cada una de las instrucciones a su equivalente en binario y hexadecimal, generando un archivo para cada uno.
    - Para este proceso se apoya de una gramatica y un diccionario.

-   ## diccionarios.py
    Contiene:
    -   Diccionarios de instrucciones tipo R, I, S, B, U, J con sus respectivos campos (`opcode`, `funct3`, `funct7`).
    -   Mapeo de registros ABI y `x0-x31`.
    -   Definición de pseudoinstrucciones que no manejan memoria.

-   ## rv32i_grammar.py
    Define la gramática del lenguaje ensamblador usando la libreria SLY de python.
    -   **Lexer**: Se encarga del analisis léxico; reconoce instrucciones, registros, números, directivas y etiquetas.
    -   **Parser**: Se encarga del analisis sintáctico; construye un árbol sintáctico (AST) con soporte para
        todos los tipos de instrucciones RV32I.\
    -   Maneja instrucciones tipo R, I, S, B, U, J, además de `ecall` y `ebreak`.

## Instalación

1.  Clonar o descargar este repositorio.

2.  Instalar la libreria SLY:

    ``` bash
    pip install sly
    ```


## Uso

Ejecuta el ensamblador con:

``` bash
python assembler.py <input.asm> <output.bin> <output.hex>
```

Ejemplo:

``` bash
python assembler.py program.asm program.bin program.hex
```

-   `program.asm`: archivo de entrada en ensamblador RV32I.\
-   `program.bin`: salida en binario (instrucciones de 32 bits).\
-   `program.hex`: salida en hexadecimal (8 caracteres por instrucción).

Al finalizar mostrará:

    Ensamblado completado.
    - Binario: program.bin
    - Hexadecimal: program.hex

## Funcionalidades principales

-   Soporte completo para instrucciones **RV32I**.
-   Expansión automática de **pseudoinstrucciones** a instrucciones nativas.\
-   Validación de inmediatos con comprobación de rango (según el tipo de instrucción).\
-   Manejo de **etiquetas y saltos** mediante un sistema de dos pasadas.\
-   Salida en **binario** y **hexadecimal**.\

## Notas
-   No acepta las pseudoinstrucciones: la, li, call y tail. 
