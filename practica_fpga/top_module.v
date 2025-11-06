//===========================================================
// Proyecto: Ejercicios 4.1 a 4.4 - DE1-SoC Cyclone V
// Descripción: Implementa LED reflection, conversión a HEX,
// visualización en displays 7 segmentos, interpretación unsigned
// y complemento a 2 usando KEY0 para alternar.
//===========================================================

module top_module (
    input  [9:0] SW,       // 10 switches SW0-SW9
    input  [3:0] KEY,      // Push-buttons (KEY0 se usa para modo)
    output [9:0] LEDR,     // 10 LEDs
    output [6:0] HEX0,     // Primer display 7 segmentos
    output [6:0] HEX1,     // Segundo display 7 segmentos
    output [6:0] HEX2      // Tercer display 7 segmentos
);


// Reflejar switches en LEDs

assign LEDR = SW;

// Conversión a HEX y visualización en displays
// Variable para modo: KEY0 (activo bajo) -> si presionado = unsigned, si no presionado = signed
wire mode_unsigned;
assign mode_unsigned = (KEY[0] == 1'b0); // Si KEY0 está presionado, modo unsigned

// Número binario de entrada (10 bits)
wire [9:0] bin_input = SW;

// Interpretación según modo
// Si unsigned: se usa tal cual
// Si signed (two's complement): extender signo y convertir
wire [11:0] number_signed;  // Extender a 12 bits para mostrar en 3 displays
assign number_signed = mode_unsigned ? {2'b00, bin_input} : {{2{bin_input[9]}}, bin_input};

// Ahora dividimos el número en 3 dígitos hexadecimales (12 bits -> 3 nibbles)
wire [3:0] hex0, hex1, hex2;
assign hex0 = number_signed[3:0];   // nibble menos significativo
assign hex1 = number_signed[7:4];
assign hex2 = number_signed[11:8];


// Instanciación de módulos para convertir a 7 segmentos
hex_to_7seg seg0 (.hex(hex0), .seg(HEX0));
hex_to_7seg seg1 (.hex(hex1), .seg(HEX1));
hex_to_7seg seg2 (.hex(hex2), .seg(HEX2));

endmodule


// Módulo: hex_to_7seg
// Convierte un dígito hexadecimal (4 bits) en el patrón
// de un display 7 segmentos activo en bajo (0 enciende segmento)
module hex_to_7seg (
    input  [3:0] hex,
    output reg [6:0] seg
);
always @(*) begin
    case (hex)
        4'h0: seg = 7'b1000000; // 0
        4'h1: seg = 7'b1111001; // 1
        4'h2: seg = 7'b0100100; // 2
        4'h3: seg = 7'b0110000; // 3
        4'h4: seg = 7'b0011001; // 4
        4'h5: seg = 7'b0010010; // 5
        4'h6: seg = 7'b0000010; // 6
        4'h7: seg = 7'b1111000; // 7
        4'h8: seg = 7'b0000000; // 8
        4'h9: seg = 7'b0010000; // 9
        4'hA: seg = 7'b0001000; // A
        4'hB: seg = 7'b0000011; // b
        4'hC: seg = 7'b1000110; // C
        4'hD: seg = 7'b0100001; // d
        4'hE: seg = 7'b0000110; // E
        4'hF: seg = 7'b0001110; // F
        default: seg = 7'b1111111; // Apagar todo
    endcase
end
endmodule
