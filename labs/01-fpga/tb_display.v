`timescale 1ns/1ps

module tb_display;

   // Entradas
   reg [9:0] SW;
   reg KEY0;

   // Salidas
   wire [9:0] LEDR;
   wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

   // Instancia del módulo a probar
   display uut (
      .SW(SW),
      .KEY0(KEY0),
      .LEDR(LEDR),
      .HEX0(HEX0),
      .HEX1(HEX1),
      .HEX2(HEX2),
      .HEX3(HEX3),
      .HEX4(HEX4),
      .HEX5(HEX5)
   );

   initial begin
      // Monitor para ver cambios (UNA SOLA CADENA)
      $monitor("t=%0d | SW=%b (%0d) | KEY0=%b | LEDR=%b | HEX5=%b | HEX4=%b | HEX3=%b | HEX2=%b | HEX1=%b | HEX0=%b",
                $time, SW, SW, KEY0, LEDR, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);

      // ---- Caso 0: cero ----
      SW   = 10'b0000000000;
      KEY0 = 0;  #10;  // original
      KEY0 = 1;  #10;  // complemento
      if (HEX0 != 7'b0001110 || HEX1 != 7'b0001110 || HEX2 != 7'b0001110)
         $display("ERROR: En complemento, 0 debería mostrar F en HEX0-2");

      // ---- Caso 1: número pequeño positivo ----
      SW   = 10'b0000000011;  // 3 decimal
      KEY0 = 0;  #10;
      KEY0 = 1;  #10;
      if (HEX1 != 7'b0001110 || HEX2 != 7'b0001110)
         $display("ERROR: En complemento, dígitos vacíos deben mostrar F");

      // ---- Caso 2: máximo positivo (511) ----
      SW   = 10'b0111111111;  // 511
      KEY0 = 0;  #10;
      KEY0 = 1;  #10;
      if (HEX2 != 7'b0001110)
         $display("ERROR: HEX2 debe ser F en complemento cuando está vacío");

      // ---- Caso 3: mínimo negativo (-512) ----
      SW   = 10'b1000000000;  // -512
      KEY0 = 0;  #10;
      KEY0 = 1;  #10;
      if (HEX1 != 7'b0001110)
         $display("ERROR: HEX1 debe ser F en complemento cuando está vacío");

      // ---- Caso 4: -1 (todos unos) ----
      SW   = 10'b1111111111;  // -1
      KEY0 = 0;  #10;
      KEY0 = 1;  #10;

      $finish;
   end

endmodule
