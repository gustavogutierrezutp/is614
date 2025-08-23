module display( 
   input wire [9:0] SW,
   input wire KEY0,
   output wire [9:0] LEDR, 
   output reg [6:0] HEX0,
   output reg [6:0] HEX1,
   output reg [6:0] HEX2,
   output reg [6:0] HEX3,
   output reg [6:0] HEX4,
   output reg [6:0] HEX5
);

   // asignar los switches a los leds
   assign LEDR = SW; 

   // señales internas 
   wire [11:0] original;
   wire [11:0] CompA2;
   wire [11:0] final;

   reg [3:0] fdig0, fdig1, fdig2;

   // extender a 12 bits para poder usar los 3 hex
   assign original = {2'b00, SW};

   // cálculo del complemento a 2 
   assign CompA2 = ~original + 12'b0000_0000_0001;

   // decidir si mostrar el complemento o el original
   assign final = (KEY0 == 1'b0) ? original : CompA2;

  always @(*) begin
   fdig0 = final[3:0];
   fdig1 = final[7:4];
   fdig2 = final[11:8];

   HEX0 = dig_7s(fdig0);
   HEX1 = dig_7s(fdig1);
   HEX2 = dig_7s(fdig2);

   if (KEY0 == 1'b1) begin
      // al tener complemento mostrar los hex sin uso como F ( extender bits )
      HEX3 = 7'b0001110;
      HEX4 = 7'b0001110;
      HEX5 = 7'b0001110;
   end else begin
      // al estar en positivo apagar los hex
      HEX3 = 7'b1111111;
      HEX4 = 7'b1111111;
      HEX5 = 7'b1111111;
   end
end


   function [6:0] dig_7s;
      input [3:0] dig;
      begin
         case(dig)
            4'b0000: dig_7s = 7'b1000000; // 0
            4'b0001: dig_7s = 7'b1111001; // 1
            4'b0010: dig_7s = 7'b0100100; // 2
            4'b0011: dig_7s = 7'b0110000; // 3
            4'b0100: dig_7s = 7'b0011001; // 4
            4'b0101: dig_7s = 7'b0010010; // 5
            4'b0110: dig_7s = 7'b0000010; // 6
            4'b0111: dig_7s = 7'b1111000; // 7
            4'b1000: dig_7s = 7'b0000000; // 8
            4'b1001: dig_7s = 7'b0010000; // 9
            4'b1010: dig_7s = 7'b0001000; // A
            4'b1011: dig_7s = 7'b0000011; // B
            4'b1100: dig_7s = 7'b1000110; // C
            4'b1101: dig_7s = 7'b0100001; // D
            4'b1110: dig_7s = 7'b0000110; // E
            4'b1111: dig_7s = 7'b0001110; // F
            default: dig_7s = 7'b1111111; // apagado
         endcase
      end
   endfunction

endmodule
