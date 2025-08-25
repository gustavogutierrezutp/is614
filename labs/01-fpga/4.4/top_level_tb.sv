`timescale 1ns/1ps

module top_level_tb;

  // Entradas
  reg [9:0] SW;   // switches (hasta 10 bits, tú ajustas según tu diseño)
  reg KEY0;       // pulsador para alternar entre con signo / sin signo

  // Salidas
  wire [6:0] HEX0;
  wire [6:0] HEX1;
  wire [6:0] HEX2;
  wire [6:0] HEX3;

  // Instanciar el DUT (Device Under Test)
  top_level dut (
    .SW(SW),
    .KEY0(KEY0),
    .HEX0(HEX0),
    .HEX1(HEX1),
    .HEX2(HEX2),
    .HEX3(HEX3)
  );

  initial begin
    // Monitor para ver el resultado en consola
    $monitor("Tiempo=%0t | SW=%b | KEY0=%b | HEX3=%b HEX2=%b HEX1=%b HEX0=%b",
              $time, SW, KEY0, HEX3, HEX2, HEX1, HEX0);

    // Caso 1: Número positivo 0000001111 (15 decimal)
    SW = 10'b0000001111;
    KEY0 = 1; // sin signo
    #10;
    KEY0 = 0; // con signo
    #10;

    // Caso 2: Número grande (ejemplo 1111111111 = 1023 sin signo / -1 con signo)
    SW = 10'b1111111111;
    KEY0 = 1; // sin signo
    #10;
    KEY0 = 0; // con signo
    #10;

    // Caso 3: Mitad del rango (ejemplo 1000000000)
    SW = 10'b1000000000;
    KEY0 = 1;
    #10;
    KEY0 = 0;
    #10;

    // Caso 4: Número pequeño (ejemplo 0000000010 = 2 decimal)
    SW = 10'b0000000010;
    KEY0 = 1;
    #10;
    KEY0 = 0;
    #10;

    // Finalizar simulación
    $finish;
  end

endmodule
