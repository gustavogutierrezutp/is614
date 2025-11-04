    .text
    # --- Inicio del programa ---
start:
    nop                     # pseudoinstrucción
    li x5, 1234             # cargar inmediato en un registro
    li x6, 0xABCD           # inmediato hexadecimal
    mv x7, x5               # mover registros
    not x8, x7              # NOT
    neg x9, x8              # NEG
    add x10, x5, x6         # suma (R-type)
    sub x11, x10, x6        # resta
    and x12, x5, x6         # AND
    or  x13, x5, x6         # OR
    xor x14, x5, x6         # XOR

    # --- Saltos y comparaciones ---
    beqz x5, else_block     # branch if equal to zero
    bnez x6, then_block     # branch if not equal to zero

then_block:
    sgtz x15, x5            # set greater than zero
    j end_if                # salto incondicional

else_block:
    sltz x15, x6            # set less than zero

end_if:
    # --- Jump & Link ---
    jal ra, func_call       # llamar a función
    ret                     # regresar (jalr x0, ra)

    # --- Función ---
func_call:
    addi x5, x5, 1          # incrementar x5
    jr ra                   # regresar al caller

    # --- Cargar y guardar en memoria ---
    la x20, var1            # cargar dirección de var1
    lw x21, 0(x20)          # cargar valor
    addi x21, x21, 10       # sumarle 10
    sw x21, var1            # guardar valor actualizado

    # --- Bucle ---
loop:
    addi x22, x22, 1
    blt x22, x21, loop      # repetir hasta x22 >= x21

    # --- Fin ---
    j end

end:
    nop

    .data
var1:   .word 42
var2:   .word 100, 200, 300
