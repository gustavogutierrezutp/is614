main:
    # 1. CARGA DE DATOS {4, 3, 2, 1}
    # -----------------------------------------------
    addi x10, x0, 0     # Base 
    
    addi x5, x0, 3      # Val 3
    sw x5, 4(x10)     
    
    addi x5, x0, 2      # Val 2
    sw x5, 8(x10)     
    
    addi x5, x0, 1      # Val 1
    sw x5, 12(x10)    
    # Límite fijo para comparar (Dirección 12 / 0x0C)
    addi x21, x0, 12    

# ===================================================
# REINICIO DEL BUCLE EXTERNO (Pass)
# ===================================================
outer_loop:
    addi x22, x0, 0     # x22: Flag "Swapped" (0 = Limpio)
    addi x23, x0, 0     # x23: Índice i = 0 (Dirección actual en bytes)

# ===================================================
# BUCLE INTERNO (Comparar pares)
# ===================================================
inner_loop:
    # 1. Calcular dirección del vecino (j = i + 4)
    addi x24, x23, 4    
    
    # 2. Protección de Límites
    # Si (i+4) > 12, terminamos esta pasada
    # Usamos SLT: Si 12 < vecio(x24), entonces x28 = 1
    slt x28, x21, x24
    
    # NOPs de seguridad (Para que x28 se guarde bien)
    addi x0, x0, 0
    addi x0, x0, 0
    
    # Si x28 es 1 (Nos pasamos del límite), ir a check_swapped
    bne x28, x0, check_swapped

    # 3. Cargar Datos (A y B)
    add x25, x10, x23  # Dir A
    lw x6, 0(x25)     # Valor A
    
    add x26, x10, x24  # Dir B
    lw x7, 0(x26)     # Valor B

    # --- NOPS CRÍTICOS ---
    # Esperamos a que los LW terminen y los datos estén estables
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0 

    # 4. Comparación (A < B?)
    # Usamos SLT para ser más seguros que BLT directo
    slt x29, x6, x7    # x29 = 1 si A < B (Está ordenado)
    
    addi x0, x0, 0      # NOP para resultado SLT
    addi x0, x0, 0      
    
    # Si x29 es 1 (A < B), NO hacemos swap
    bne x29, x0, no_swap
    
    # Comparación de Igualdad (A == B)
    # Si son iguales, saltamos a no_swap
    beq x6, x7, no_swap

    # 5. Intercambio (SWAP)
    # Si llegamos aquí, A > B. Hay que invertir.
    sw x7, 0(x25)     # B -> Pos A
    sw x6, 0(x26)     # A -> Pos B
    
    # Levantar bandera de cambio
    addi x22, x0, 1     

no_swap:
    # 6. Avanzar al siguiente par
    addi x23, x23, 4    # i = i + 4
    
    # Volver al inicio del bucle interno
    jal x0, inner_loop 

# ===================================================
# VERIFICACIÓN DE CAMBIOS
# ===================================================
check_swapped:
    # Si x22 (flag) es 1, significa que hubo cambios. Repetimos todo.
    addi x31, x0, 1
    
    # NOPs para asegurar comparación
    addi x0, x0, 0
    addi x0, x0, 0
    
    beq x22, x31, outer_loop

    # ===================================================
    # FIN DEL PROGRAMA
    # ===================================================
    # Si x22 es 0, todo está ordenado.
    addi x30, x0, 255   # Código éxito FF

finish:
    ebreak