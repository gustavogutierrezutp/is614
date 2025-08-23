module top_level (
    input  logic [9:0] SW,       // switches de entrada (SW9..SW0)
    input  logic       KEY0,     // botón: 1=unsigned, 0=signed (default)
    output logic [9:0] LED,      // leds de salida
    output logic [6:0] HEX0,     // display 7 segmentos (LSB)
    output logic [6:0] HEX1,     // display 7 segmentos
    output logic [6:0] HEX2      // display 7 segmentos (MSB)
);

    // Conectar LEDs a los switches
    assign LED = SW;

    // Número en decimal (signed o unsigned)
    logic signed [9:0] signed_value;
    logic        [9:0] unsigned_value;
    logic [9:0] display_value;

    assign signed_value   = SW;   // Interpretación complemento a2 (signed)
    assign unsigned_value = SW;   // Interpretación binaria pura (unsigned)

    // Selección: por defecto signed, si KEY0 presionado => unsigned
    assign display_value = (KEY0) ? unsigned_value : signed_value;

    // Dividir en nibbles para hex
    logic [3:0] nibble0; // menos significativo
    logic [3:0] nibble1;
    logic [3:0] nibble2; // más significativo

    assign nibble0 = display_value[3:0];
    assign nibble1 = display_value[7:4];
    assign nibble2 = {2'b00, display_value[9:8]}; // solo 2 bits usados

    // Instancias del decodificador 7 segmentos
    hex7seg h0 (.bin(nibble0), .seg(HEX0));
    hex7seg h1 (.bin(nibble1), .seg(HEX1));
    hex7seg h2 (.bin(nibble2), .seg(HEX2));

endmodule


// Decodificador de 4 bits a display 7 segmentos (activo en bajo, gfedcba)
module hex7seg (
    input  logic [3:0] bin,
    output logic [6:0] seg
);
    always_comb begin
        case (bin)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;
            default: seg = 7'b1111111; // todo apagado
        endcase
    end
endmodule
