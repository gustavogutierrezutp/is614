`timescale 1ns/1ps

module top_level_tb;

  // -----------------------------
  // Declaración de entradas
  // -----------------------------
  reg [9:0] switches;   // 10 switches de entrada
  reg modo_signo;       // Selector de modo: 1 = sin signo, 0 = con signo

  // -----------------------------
  // Declaración de salidas
  // -----------------------------
  wire [6:0] display0;
  wire [6:0] display1;
  wire [6:0] display2;
  wire [6:0] display3;

  // -----------------------------
  // Instanciación del módulo bajo prueba
  // -----------------------------
  top_level uut (
    .SW(switches),
    .KEY0(modo_signo),
    .HEX0(display0),
    .HEX1(display1),
    .HEX2(display2),
    .HEX3(display3)
  );

  // -----------------------------
  // Bloque inicial de pruebas
  // -----------------------------
  initial begin
    // Monitor para mostrar resultados en consola cada cambio de señal
    $monitor("Tiempo=%0t | SW=%b | ModoSigno=%b | HEX3=%b HEX2=%b HEX1=%b HEX0=%b",
              $time, switches, modo_signo, display3, display2, display1, display0);

    // -----------------------------
    // Prueba 1: Número positivo pequeño (15 decimal)
    // -----------------------------
    switches = 10'b0000001111;
    modo_signo = 1;  // sin signo
    #10;
    modo_signo = 0;  // con signo
    #10;

    // -----------------------------
    // Prueba 2: Número máximo (1023 sin signo / -1 con signo)
    // -----------------------------
    switches = 10'b1111111111;
    modo_signo = 1;
    #10;
    modo_signo = 0;
    #10;

    // -----------------------------
    // Prueba 3: Valor intermedio (512)
    // -----------------------------
    switches = 10'b1000000000;
    modo_signo = 1;
    #10;
    modo_signo = 0;
    #10;

    // -----------------------------
    // Prueba 4: Número pequeño (2 decimal)
    // -----------------------------
    switches = 10'b0000000010;
    modo_signo = 1;
    #10;
    modo_signo = 0;
    #10;

    // -----------------------------
    // Terminar simulación
    // -----------------------------
    $display("Simulación completada.");
    $finish;
  end

endmodule