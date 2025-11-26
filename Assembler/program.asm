.data
    val1: .word 10   # Dir 0x00
    val2: .word 20   # Dir 0x04
    val3: .word 30  
    res1:  .word 0  # Dir 0x08
    res:  .word 0    # Dir 0x0C (Aquí guardaremos el 60)

.text

main:
    # --- 1. CONFIGURACIÓN Y ESCRITURA EN MEMORIA ---
    addi x1, x0, 0      # x1 = Base de memoria (0)

    # Escribimos los valores manualmente (Test SW)
    addi x5, x0, 10     # x5 = 10
    sw   x5, 0(x1)      # Mem[0] = 10
    
    addi x5, x0, 20     # x5 = 20
    sw   x5, 4(x1)      # Mem[4] = 20
    
    addi x5, x0, 30     # x5 = 30
    sw   x5, 8(x1)      # Mem[8] = 30

    # --- 2. PRUEBA DE SALTO INCONDICIONAL (JAL) ---
    # Saltamos sobre la instrucción "trampa". 
    # Si JAL funciona, x31 SE QUEDARÁ EN 0.
    # Si JAL falla, x31 valdrá 0xFFFFFFFF.
    
    jal x2, start_sum   # Salto incondicional a la etiqueta
    
    # === TRAMPA DE ERROR ===
    addi x31, x0, -1    # Si ves FFFFFFFF en x31, el JUMP falló.

start_sum:
    # --- 3. PREPARACIÓN DEL BUCLE ---
    addi x10, x0, 3     # x10 = Contador (3 iteraciones)
    addi x11, x0, 0     # x11 = Acumulador (Suma total)
    addi x12, x0, 0     # x12 = Offset de dirección (0, 4, 8)

loop:
    # --- 4. CUERPO DEL BUCLE (Load + Add) ---
    add  x13, x1, x12   # x13 = Dirección actual (Base + Offset)
    lw   x6, 0(x13)     # x6  = Cargar valor de memoria (Test LW)

    add  x11, x11, x6   # x11 = x11 + x6 (Suma acumulada)

    # Actualizar punteros
    addi x12, x12, 4    # Siguiente dirección (+4 bytes)
    addi x10, x10, -1   # Decrementar contador

    # --- 5. PRUEBA DE SALTO CONDICIONAL (BNE) ---
    # Si contador (x10) != 0, salta atrás a 'loop'
    # Si x10 == 0, continúa abajo (fall-through)
    bne  x10, x0, loop

    # --- 6. GUARDAR RESULTADO ---
    # La suma debe ser 10 + 20 + 30 = 60 (0x3C en Hex)
    sw   x11, 12(x1)    # Guardar 60 en Memoria[12] (0x0C)

   # x7 = 0

ebreak