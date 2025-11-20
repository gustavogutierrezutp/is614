# Procesador Monociclo RISC-V

**Autores:** Jeronimo Escudero Cuartas y Valentina Murillo Muñoz

Este proyecto implementa un **procesador monociclo RISC-V RV32I** usando **SystemVerilog y Verilog**, diseñado para ejecutarse en una FPGA con VGA.  
Soporta **todas las instrucciones RV32I excepto `ecall`**.  
La salida VGA muestra señales internas, registros y memoria.  
La ejecución se controla con botones físicos de la FPGA:

- **KEY0** → Clock manual: avanza 1 instrucción por pulsación  
- **KEY1** → Reset del procesador  
- Si la CPU encuentra un **`ebreak`**, se muestra en la VGA: **“El programa ha terminado”** y el procesador se congela hasta el siguiente reset.

---

## Características principales

- CPU monociclo de 32 bits (RV32I).
- Implementado en **SystemVerilog + Verilog**.
- Compatible con la FPGA Cyclone V: 5CSEMA5F31C6.
- Visualización en pantalla con VGA.



