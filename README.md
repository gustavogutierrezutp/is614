# is614
A simple quartus project and dev container configuration for the course IS614 Computer Organization

# Tarea 1 – Conversión de Binario a Hexadecimal y Complemento a 2 con Displays de 7 Segmentos.

Este proyecto implementa en SystemVerilog un sistema que recibe como entrada el estado de 10 switches y un botón.  
El valor hexadecimal se representa en 4 displays de 7 segmentos y en el número binario ingresado en switches se refleja en los LEDs.

En los displays se muestra el valor ingresado en los switches con las siguientes condiciones del botón:
  - Si KEY0 = 0, el valor es binario normal.
  - Si KEY0 = 1, al valor se le aplica el complemento a 2.

## FUNCIONAMIENTO:
1. El vector `SW[9:0]` representa un número entero de 10 bits.  
2. Si `KEY0 = 0`, se toma el valor directo de `SW`.  
3. Si `KEY0 = 1`, se calcula el complemento a 2 del número.  
4. El resultado se separa en 4 bits para cada display `HEX0..HEX3`.  
5. Cada display usa el módulo `hex7seg` para convertir el valor a hexadecimal y mostrarlo en los displays.

## AUTORES:
Valentina Murillo Muñoz - 1085717310
Jeronimo Escudero Cuartas - 1091273110
