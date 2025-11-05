# Programa de prueba para procesador RISC-V 32 bits
# Incluye instrucciones tipo R, I, Load y Store

# ==== INSTRUCCIONES TIPO I (Inmediatas) ====
ADDI x1, x0, 10      # x1 = 0 + 10 = 10
ADDI x2, x0, 20      # x2 = 0 + 20 = 20
ADDI x3, x0, 5       # x3 = 0 + 5 = 5
ADDI x4, x0, -3      # x4 = 0 + (-3) = -3

ANDI x5, x1, 15      # x5 = x1 & 15
ORI x6, x2, 3        # x6 = x2 | 3
XORI x7, x3, 7       # x7 = x3 ^ 7

SLLI x8, x1, 2       # x8 = x1 << 2 = 40
SRLI x9, x2, 1       # x9 = x2 >> 1 = 10
SRAI x10, x4, 1      # x10 = x4 >>> 1 (aritmético)

SLTI x11, x1, 15     # x11 = (x1 < 15) ? 1 : 0
SLTIU x12, x2, 25    # x12 = (x2 < 25) ? 1 : 0 (sin signo)

# ==== INSTRUCCIONES TIPO R (Registro-Registro) ====
ADD x13, x1, x2      # x13 = x1 + x2 = 30
SUB x14, x2, x1      # x14 = x2 - x1 = 10
AND x15, x1, x2      # x15 = x1 & x2
OR x16, x1, x3       # x16 = x1 | x3
XOR x17, x2, x3      # x17 = x2 ^ x3

SLL x18, x1, x3      # x18 = x1 << x3
SRL x19, x2, x3      # x19 = x2 >> x3
SRA x20, x4, x3      # x20 = x4 >>> x3

SLT x21, x1, x2      # x21 = (x1 < x2) ? 1 : 0
SLTU x22, x4, x1     # x22 = (x4 < x1) ? 1 : 0 (sin signo)

# ==== INSTRUCCIONES STORE (Tipo S) ====
ADDI x23, x0, 0      # x23 = dirección base = 0

SW x1, 0(x23)        # memoria[0] = x1
SW x2, 4(x23)        # memoria[4] = x2
SW x13, 8(x23)       # memoria[8] = x13

SH x3, 12(x23)       # memoria[12] = x3 (halfword)
SB x5, 14(x23)       # memoria[14] = x5 (byte)

# ==== INSTRUCCIONES LOAD (Tipo I) ====
LW x24, 0(x23)       # x24 = memoria[0]
LW x25, 4(x23)       # x25 = memoria[4]
LW x26, 8(x23)       # x26 = memoria[8]

LH x27, 12(x23)      # x27 = memoria[12] (halfword con signo)
LHU x28, 12(x23)     # x28 = memoria[12] (halfword sin signo)

LB x29, 14(x23)      # x29 = memoria[14] (byte con signo)
LBU x30, 14(x23)     # x30 = memoria[14] (byte sin signo)

# ==== OPERACIONES FINALES ====
ADD x31, x24, x25    # x31 = x24 + x25

# Fin del programa