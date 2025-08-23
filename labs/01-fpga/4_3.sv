module top_level (
    input  logic [9:0] SW,       // 10 switches -> número binario (0-1023)
    output logic [6:0] HEX0,     // Primer dígito (menos significativo)
    output logic [6:0] HEX1,     // Segundo dígito
    output logic [6:0] HEX2      // Tercer dígito (más significativo, 0-3)
);

    // -------------------------------
    // Función para decodificar hex -> 7 segmentos
    // -------------------------------
    function automatic logic [6:0] hex_to_7seg(input logic [3:0] value);
        case (value)
            4'h0: hex_to_7seg = 7'b1000000; // 0
            4'h1: hex_to_7seg = 7'b1111001; // 1
            4'h2: hex_to_7seg = 7'b0100100; // 2
            4'h3: hex_to_7seg = 7'b0110000; // 3
            4'h4: hex_to_7seg = 7'b0011001; // 4
            4'h5: hex_to_7seg = 7'b0010010; // 5
            4'h6: hex_to_7seg = 7'b0000010; // 6
            4'h7: hex_to_7seg = 7'b1111000; // 7
            4'h8: hex_to_7seg = 7'b0000000; // 8
            4'h9: hex_to_7seg = 7'b0010000; // 9
            4'hA: hex_to_7seg = 7'b0001000; // A
            4'hB: hex_to_7seg = 7'b0000011; // B
            4'hC: hex_to_7seg = 7'b1000110; // C
            4'hD: hex_to_7seg = 7'b0100001; // D
            4'hE: hex_to_7seg = 7'b0000110; // E
            4'hF: hex_to_7seg = 7'b0001110; // F
            default: hex_to_7seg = 7'b1111111; // apagado
        endcase
    endfunction

    // -------------------------------
    // Asignaciones
    // -------------------------------
    always_comb begin
        HEX0 = hex_to_7seg(SW[3:0]);         // Dígito menos significativo
        HEX1 = hex_to_7seg(SW[7:4]);         // Dígito intermedio
        HEX2 = hex_to_7seg({2'b00, SW[9:8]});// Dígito más significativo (0-3)
    end

endmodule
