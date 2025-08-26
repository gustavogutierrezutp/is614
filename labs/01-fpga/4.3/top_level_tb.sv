`timescale 1ns/1ps

module top_level_tb;

  // Señales de entrada (simuladas como registros)
  reg [9:0] SW;

  // Señales de salida (se conectan al DUT)
  wire [9:0] LEDR;
  wire [6:0] HEX0, HEX1, HEX2, HEX3;

  // Instancia del módulo bajo prueba (DUT = Device Under Test)
  top_level uut (
    .SW(SW),
    .LEDR(LEDR),
    .HEX0(HEX0),
    .HEX1(HEX1),
    .HEX2(HEX2),
    .HEX3(HEX3)
  );

  // Bloque inicial de pruebas
  initial begin
    $display("Iniciando simulación de top_level...");

    // Caso 0: Todos los switches apagados
    SW = 10'd0;
    #10;

    // Caso 1: Valor pequeño (5)
    SW = 10'd5;
    #10;

    // Caso 2: Valor medio (63)
    SW = 10'd63;
    #10;

    // Caso 3: Valor máximo (1023)
    SW = 10'd1023;
    #10;

    // Caso 4: Valor intermedio (512)
    SW = 10'd512;
    #10;

    $display("Finalizando simulación.");
    $finish; // Termina la simulación
  end

endmodule