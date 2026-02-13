// seven_segment_decoder.sv
//
// Convierte un número de 4 bits (un dígito hexadecimal) a las señales
// necesarias para encender un display de 7 segmentos.
//
// NOTA: Es para displays de ÁNODO COMÚN (como los de la DE1-SoC),
// lo que significa que un '0' enciende el segmento y un '1' lo apaga.

module seven_segment_decoder (
    input  logic [3:0] binary_in, // Entrada en binario (0-15 o 0-F)
    output logic [6:0] segments   // Salida para los 7 segmentos (a,b,c,d,e,f,g)
                                   // Asignación: segments[6:0] -> (g,f,e,d,c,b,a)
);

    always_comb begin
        case (binary_in)
            //                gfedcba
            4'h0: segments = 7'b1000000; // 0
            4'h1: segments = 7'b1111001; // 1
            4'h2: segments = 7'b0100100; // 2
            4'h3: segments = 7'b0110000; // 3
            4'h4: segments = 7'b0011001; // 4
            4'h5: segments = 7'b0010010; // 5
            4'h6: segments = 7'b0000010; // 6
            4'h7: segments = 7'b1111000; // 7
            4'h8: segments = 7'b0000000; // 8
            4'h9: segments = 7'b0010000; // 9
            4'hA: segments = 7'b0001000; // A
            4'hB: segments = 7'b0000011; // b
            4'hC: segments = 7'b1000110; // C
            4'hD: segments = 7'b0100001; // d
            4'hE: segments = 7'b0000110; // E
            4'hF: segments = 7'b0001110; // F
            default: segments = 7'b1111111; // Apagado
        endcase
    end

endmodule