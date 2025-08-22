`timescale 1ns/1ps

module tb_display;

   // Entradas
   reg [9:0] SW;
   reg KEY0;

   // Salidas
   wire [9:0] LEDR;
   wire [6:0] HEX0, HEX1, HEX2;

   // Instancia del módulo a probar
   display uut (
      .SW(SW),
      .KEY0(KEY0),
      .LEDR(LEDR),
      .HEX0(HEX0),
      .HEX1(HEX1),
      .HEX2(HEX2)
   );

   initial begin
      // Monitor para ver cambios
      $monitor("t=%0d | SW=%b (%0d) | KEY0=%b | LEDR=%b | HEX2=%b HEX1=%b HEX0=%b",
                $time, SW, SW, KEY0, LEDR, HEX2, HEX1, HEX0);

      // Caso 1: valor pequeño positivo
      SW   = 10'b0000000011;  // 3 decimal
      KEY0 = 0;               // mostrar original
      #10;

      // Caso 2: mismo número pero KEY0=1 (mostrar complemento)
      KEY0 = 1;
      #10;

      // Caso 3: un valor grande
      SW   = 10'b1111111111;  // 1023 decimal
      KEY0 = 0;
      #10;

      // Caso 4: su complemento
      KEY0 = 1;
      #10;

      // Caso 5: valor intermedio
      SW   = 10'b1000000000;  // 512 decimal
      KEY0 = 0;
      #10;

      KEY0 = 1;
      #10;

      // Terminar simulación
      $finish;
   end

endmodule



