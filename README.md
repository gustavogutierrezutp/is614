# is614
A simple quartus project and dev container configuration for the course IS614 Computer Organization

# Laboratorio 1: Introducción a FPGA con DE1-SoC

## Integrantes

- Juan David Roman
- Santiago Gomez Ramirez
  
## Descripción

Este laboratorio introduce los conceptos básicos de FPGAs utilizando la tarjeta DE1-SoC con el FPGA Cyclone V. Se implementaron 4 ejercicios progresivos que exploran el uso de switches, LEDs y displays de 7 segmentos.

## Ejercicios Implementados

### 4.1 - Reflejo de LEDs
Implementación directa donde cada switch (SW0-SW9) controla su LED correspondiente (LED0-LED9).

### 4.2 - Display Hexadecimal
Uso de los primeros 4 switches (SW0-SW3) para mostrar dígitos hexadecimales (0-F) en el primer display de 7 segmentos (HEX0).

### 4.3 - Números Grandes
Extensión para usar los 10 switches completos (SW0-SW9) y mostrar números decimales de 0-1023 en múltiples displays de 7 segmentos.

### 4.4 - Números Negativos
Implementación de aritmética de complemento a 2 con toggle entre modo sin signo y con signo usando el botón KEY0. Incluye display de signo negativo.

## Archivos

Cada ejercicio incluye:
- `top_level.v` - Módulo principal con la lógica del circuito
- `tb_top_level.v` - Testbench para simulación

## Herramientas Utilizadas

- **Intel Quartus Prime** - Síntesis y implementación
- **ModelSim** - Simulación de testbenches
- **Lenguaje:** Verilog HDL

## Funcionamiento

1. **Switches (SW0-SW9):** Entrada binaria
2. **LEDs (LED0-LED9):** Salida visual del estado de switches
3. **Displays 7-segmentos (HEX0-HEX5):** Visualización de números decimales/hexadecimales
4. **Botón KEY0:** Control de modo signed/unsigned (solo ejercicio 4.4)

## Compilación y Simulación

1. Abrir proyecto en Quartus Prime
2. Compilar el diseño (`top_level.v`)
3. Simular con ModelSim usando el testbench correspondiente

## Notas Técnicas

- Los displays de 7 segmentos son **activos en bajo** (0 = encendido)
- Los botones KEY son **activos en bajo** (0 cuando presionados)
- El complemento a 2 se implementa como: `(~valor + 1)`
