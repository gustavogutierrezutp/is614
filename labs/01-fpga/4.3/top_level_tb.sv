`timescale 1ns/1ps                   // Define la unidad de tiempo de simulación (1 ns) y la precisión (1 ps)

module top_level_tb;                 // Inicio del módulo testbench llamado "top_level_tb"

  // Entradas como registros
  reg [9:0] SW;                      // Declaración de "SW" como registro (reg), ya que se asigna en bloques initial

  // Salidas como wires
  wire [9:0] LEDR;                   // Señal de salida hacia LEDs (wire porque es salida del DUT)
  wire [6:0] HEX0, HEX1, HEX2, HEX3; // Señales de salida hacia los 4 displays de 7 segmentos

  // Instancia del DUT (Device Under Test)
  top_level dut (                    // Se crea la instancia del módulo que se va a probar ("dut")
    .SW(SW),                         // Conecta la entrada SW del DUT con la señal reg SW del testbench
    .LEDR(LEDR),                     // Conecta salida LEDR del DUT al wire LEDR del testbench
    .HEX0(HEX0),                     // Conecta salida HEX0 al wire HEX0
    .HEX1(HEX1),                     // Conecta salida HEX1 al wire HEX1
    .HEX2(HEX2),                     // Conecta salida HEX2 al wire HEX2
    .HEX3(HEX3)                      // Conecta salida HEX3 al wire HEX3
  );

  initial begin                      // Bloque inicial: define el estímulo de prueba
    // Caso inicial
    SW = 10'b0000000000;             // Todos los switches en 0 → valor mostrado en displays debe ser 0
    #10;                             // Esperar 10 ns de simulación

    // Caso 1: Número pequeño
    SW = 10'b0000000101;             // Se coloca el número 5 en los switches
    #10;                             // Esperar 10 ns

    // Caso 2: Número mediano
    SW = 10'b0000111111;             // Se coloca el número 63 en los switches
    #10;                             // Esperar 10 ns

    // Caso 3: Número grande
    SW = 10'b1111111111;             // Se coloca el número 1023 en los switches
    #10;                             // Esperar 10 ns

    // Caso 4: Valor intermedio
    SW = 10'b1000000000;             // Se coloca el número 512 en los switches
    #10;                             // Esperar 10 ns

    $finish;                         // Termina la simulación y cierra el testbench
  end

endmodule                             // Fin del módulo testbench
