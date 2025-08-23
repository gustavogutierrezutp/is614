module top_level ( 
    input  logic [9:0] SW,       // switches de entrada (SW9..SW0)
    input  logic       KEY0,     // botón: 1=unsigned, 0=signed (default)
    output logic [9:0] LED,      // leds de salida
    output logic [6:0] HEX0,     // display 7 segmentos (LSB)
    output logic [6:0] HEX1,     // display 7 segmentos
    output logic [6:0] HEX2,
    output logic [6:0] HEX3      // display 7 segmentos 
);

    // Conectar LEDs a los switches
    assign LED = SW;

    // Número en decimal (signed o unsigned)
    logic signed [9:0] signed_value;
    logic        [9:0] unsigned_value;
    logic [15:0] display_value;  // ampliamos a 16 bits para usar 4 nibbles

    assign signed_value   = SW;   // Interpretación complemento a2 (signed)
    assign unsigned_value = SW;   // Interpretación binaria pura (unsigned)

    // Selección: por defecto signed, si KEY0 presionado => unsigned
    assign display_value = (KEY0) ? {6'b0, unsigned_value} : {{6{signed_value[9]}}, signed_value};
    // unsigned => se rellena con ceros
    // signed   => se extiende el signo a 16 bits

    // Dividir en nibbles para hex
    logic [3:0] nibble0; // menos significativo
    logic [3:0] nibble1;
    logic [3:0] nibble2;
    logic [3:0] nibble3; // más significativo

    assign nibble0 = display_value[3:0];
    assign nibble1 = display_value[7:4];
    assign nibble2 = display_value[11:8];
    assign nibble3 = display_value[15:12];

    // Instancias del decodificador 7 segmentos
    hex7seg h0 (.bin(nibble0), .seg(HEX0));
    hex7seg h1 (.bin(nibble1), .seg(HEX1));
    hex7seg h2 (.bin(nibble2), .seg(HEX2));
    hex7seg h3 (.bin(nibble3), .seg(HEX3));

endmodule


// Decodificador de 4 bits a display 7 segmentos (activo en bajo, gfedcba)
module hex7seg (
    input  logic [3:0] bin,
    output logic [6:0] seg
);
    always_comb begin
        case (bin)
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
            4'hB: seg = 7'b0000011; // B
            4'hC: seg = 7'b1000110; // C
            4'hD: seg = 7'b0100001; // D
            4'hE: seg = 7'b0000110; // E
            4'hF: seg = 7'b0001110; // F
            default: seg = 7'b1111111; // todo apagado
        endcase
    end
endmodule
