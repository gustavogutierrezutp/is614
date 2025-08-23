# Proyecto: Ejercicios 4.1–4.4 — FPGA DE1-SoC (Cyclone V)

**Autores:** Juan Alejandro Rojas Valencia · Christian Velásquez Perdomo  
**Asignatura:** Arquitectura de Computadores   
**Lenguaje:** Verilog (clásico)

---

## Descripción

Implementación progresiva en un solo archivo Verilog de:

- **4.1 LED Reflection:** `LEDR[9:0]` refleja `SW[9:0]`.
- **4.2 HEX (4 bits):** `SW[3:0]` → dígito hexadecimal en `HEX0` (7 segmentos **activo en bajo**).
- **4.3 HEX (10 bits):** `SW[9:0]` → 3 dígitos HEX en `HEX2:HEX1:HEX0` (máx. `3FF`).
- **4.4 Modo signed/unsigned:** con **KEY0 (activo-bajo)**:
  - **KEY0 = 0 (presionado)** → **unsigned**.
  - **KEY0 = 1 (no presionado)** → **signed (two’s complement)**.
  - La visualización siempre es **hexadecimal sin signo** (p. ej., `-1` → `FFF`).