`timescale 1ns/1ps

module tb_display;

   reg [9:0] SWITCHES;
   reg BUTTON;

   wire [9:0] LEDS;
   wire [6:0] HEX_UNIDADES;
   wire [6:0] HEX_DECENAS;
   wire [6:0] HEX_CENTENAS;
   wire [6:0] HEX_MILES;

   display uut (
      .SWITCHES(SWITCHES),
      .BUTTON(BUTTON),
      .LEDS(LEDS),
      .HEX_UNIDADES(HEX_UNIDADES),
      .HEX_DECENAS(HEX_DECENAS),
      .HEX_CENTENAS(HEX_CENTENAS),
      .HEX_MILES(HEX_MILES)
   );

   initial begin
      $display("Iniciando simulación...");
      
 
      SWITCHES = 10'b0000000000; BUTTON = 1;
      #10 $display("SW=0000000000, Unsigned -> LEDS=%b", LEDS);

      //SW = 15 (0x0F)
      SWITCHES = 10'b0000001111; BUTTON = 1;
      #10 $display("SW=0000001111, Unsigned -> LEDS=%b", LEDS);

      //SW = 1023 (0x3FF)
      SWITCHES = 10'b1111111111; BUTTON = 1;
      #10 $display("SW=1111111111, Unsigned -> LEDS=%b", LEDS);

      //SW = 512 (0x200)
      SWITCHES = 10'b1000000000; BUTTON = 1;
      #10 $display("SW=1000000000, Unsigned -> LEDS=%b", LEDS);

      //SW = 512 (0x200)
      SWITCHES = 10'b1000000000; BUTTON = 0;
      #10 $display("SW=1000000000, Signed -> LEDS=%b", LEDS);

      //SW = 1023 (0x3FF)
      SWITCHES = 10'b1111111111; BUTTON = 0;
      #10 $display("SW=1111111111, Signed -> LEDS=%b", LEDS);


      $display("Simulación terminada.");
      $stop;
   end

endmodule
