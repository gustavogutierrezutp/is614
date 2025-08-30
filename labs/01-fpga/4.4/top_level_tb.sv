`timescale 1ns/1ps                      // Define unidad de tiempo (1ns) y precisión de simulación (1ps)

module top_level_tb;                    // Definición del módulo testbench

  // -------------------------------
  // Entradas hacia el DUT (reg porque se asignan en el testbench)
  // -------------------------------
  reg [9:0] SW;                         // Simula el valor de los switches de entrada (10 bits)
  reg      KEY0;                        // Simula el pulsador que selecciona entre con signo / sin signo

  // -------------------------------
  // Salidas desde el DUT (wire porque son conducidas por el DUT)
  // -------------------------------
  wire [6:0] HEX0, HEX1, HEX2, HEX3;    // Señales que representan cada display de 7 segmentos

  // -------------------------------
  // Instanciación del DUT (Device Under Test)
  // -------------------------------
  top_level dut (                       // Se crea una instancia del módulo "top_level"
    .SW   (SW),                         // Conecta el testbench SW → DUT SW
    .KEY0 (KEY0),                       // Conecta el testbench KEY0 → DUT KEY0
    .HEX0 (HEX0),                       // Conecta la salida HEX0 del DUT al testbench
    .HEX1 (HEX1),                       // Conecta la salida HEX1 del DUT al testbench
    .HEX2 (HEX2),                       // Conecta la salida HEX2 del DUT al testbench
    .HEX3 (HEX3)                        // Conecta la salida HEX3 del DUT al testbench
  );

  // -------------------------------
  // Bloque inicial: genera estímulos de prueba
  // -------------------------------
  initial begin
    // Mostrar información en la consola cada vez que cambien señales
    $monitor("Tiempo=%0t | SW=%b | KEY0=%b | HEX3=%b HEX2=%b HEX1=%b HEX0=%b",
              $time, SW, KEY0, HEX3, HEX2, HEX1, HEX0);

    // -------------------------------
    // Caso 1: número positivo pequeño (15 decimal)
    // -------------------------------
    SW   = 10'b0000001111;              // Coloca valor 15 en switches
    KEY0 = 1;                           // Modo sin signo
    #10;                                // Esperar 10ns
    KEY0 = 0;                           // Modo con signo
    #10;

    // -------------------------------
    // Caso 2: número máximo (1023 sin signo / -1 con signo)
    // -------------------------------
    SW   = 10'b1111111111;              // Coloca todos los switches en 1
    KEY0 = 1;                           // Modo sin signo (1023)
    #10;
    KEY0 = 0;                           // Modo con signo (-1)
    #10;

    // -------------------------------
    // Caso 3: valor intermedio (512 sin signo / -512 con signo)
    // -------------------------------
    SW   = 10'b1000000000;              // Activa solo el bit más significativo
    KEY0 = 1;                           // Modo sin signo
    #10;
    KEY0 = 0;                           // Modo con signo
    #10;

    // -------------------------------
    // Caso 4: número pequeño (2 decimal)
    // -------------------------------
    SW   = 10'b0000000010;              // Coloca valor 2 en switches
    KEY0 = 1;                           // Modo sin signo
    #10;
    KEY0 = 0;                           // Modo con signo
    #10;

    // -------------------------------
    // Fin de simulación
    // -------------------------------
    $finish;                            // Termina la simulación
  end

endmodule                               // Fin del testbench
