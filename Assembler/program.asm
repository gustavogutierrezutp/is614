.data
# Datos iniciales
num1:
    .word 10
num2:
    .word 20
resultado:
    .word 0

.text
main:
    # Instrucciones tipo I (inmediato)
    addi x1, x0, 5          # x1 = 0 + 5 = 5
    addi x2, x0, 3          # x2 = 0 + 3 = 3
    
    # Instrucciones tipo R (registro-registro)
    add x3, x1, x2          # x3 = x1 + x2 = 8
    sub x4, x1, x2          # x4 = x1 - x2 = 2
    and x5, x1, x2          # x5 = x1 & x2
    or x6, x1, x2           # x6 = x1 | x2
    
    # Más instrucciones tipo I
    xori x7, x3, 15         # x7 = x3 XOR 15
    slti x8, x4, 10         # x8 = 1 si x4 < 10, sino 0
    
    # Instrucciones tipo I - Load (cargar desde memoria)
    lui x10, %hi(num1)      # Carga parte alta de dirección
    addi x10, x10, %lo(num1) # Suma parte baja
    lw x11, 0(x10)          # x11 = valor en num1 (10)
    lw x12, 4(x10)          # x12 = valor en num2 (20)
    
    # Instrucciones tipo R con valores cargados
    add x13, x11, x12       # x13 = 10 + 20 = 30
    
    # Instrucciones tipo S (store - guardar en memoria)
    lui x14, %hi(resultado)
    addi x14, x14, %lo(resultado)
    sw x13, 0(x14)          # Guarda x13 en resultado
    
    # Terminar

