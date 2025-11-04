# -----------------------------------------------
# ejemplo.asm
# Programa de prueba para ensamblador (R, I, S-Type)
# -----------------------------------------------
#
# Objetivo:
# 1. Carga los números 50 y 25 en registros.
# 2. Los suma (R-Type).
# 3. Prepara una dirección de memoria (200).
# 4. Guarda el resultado (75) en la memoria (S-Type).
# 5. Vuelve a cargar el resultado desde la memoria (I-Type).
# 6. Lo mueve a otro registro (Pseudoinstrucción).
# 7. Se detiene.
# -----------------------------------------------

.text
main:
    # 1. Cargar valores iniciales (Pseudoinstrucción 'li')
    li  x5, 50          # Carga 50 en el registro x5
                        # (El ensamblador lo convertirá en: addi x5, x0, 50)

    li  x6, 25          # Carga 25 en el registro x6
                        # (El ensamblador lo convertirá en: addi x6, x0, 25)

    # 2. Sumar los valores (R-Type)
    add x7, x5, x6      # x7 = x5 + x6  (x7 = 50 + 25 = 75)

    # 3. Preparar para guardar en memoria (I-Type)
    li  x8, 200         # Carga la dirección de memoria 200 (0xC8) en x8
                        # (El ensamblador lo convertirá en: addi x8, x0, 200)

    # 4. Guardar el resultado (S-Type)
    sw  x7, 0(x8)       # Guarda el valor de x7 (75) en la dirección 200

    # 5. Cargar el valor de vuelta (I-Type Load)
    lw  x9, 0(x8)       # Carga el valor de la dirección 200 en x9
                        # x9 debería ser 75 ahora.

    # 6. Mover el resultado (Pseudoinstrucción 'mv')
    mv  x10, x9         # Mueve el valor de x9 a x10 (x10 = 75)
                        # (El ensamblador lo convertirá en: addi x10, x9, 0)

    # 7. Bucle infinito para "detener" el procesador
loop:
    nop                 # No hacer nada (addi x0, x0, 0)
    nop
    nop