`timescale 1ns/1ps

module top_level_tb;

  // Entradas como registros
  reg [9:0] SW;

  // Salidas como wires
  wire [9:0] LEDR;
  wire [6:0] HEX0, HEX1, HEX2, HEX3;

  // Instancia del DUT (Device Under Test)
  top_level dut (
    .SW(SW),
    .LEDR(LEDR),
    .HEX0(HEX0),
    .HEX1(HEX1),
    .HEX2(HEX2),
    .HEX3(HEX3)
  );

  initial begin
    // Caso inicial
    SW = 10'b0000000000;
    #10;

    // Caso 1: Número pequeño
    SW = 10'b0000000101;  // 5
    #10;

    // Caso 2: Número mediano
    SW = 10'b0000111111;  // 63
    #10;

    // Caso 3: Número grande
    SW = 10'b1111111111;  // 1023
    #10;

    // Caso 4: Valor intermedio
    SW = 10'b1000000000;  // 512
    #10;

    $finish; // Terminar simulación
  end

endmodule
