//===========================================================
// Módulo: top_level
// Descripción: Convierte un valor de 4 bits proveniente de 
// los switches en la representación correspondiente en un 
// display de 7 segmentos (HEX0).
//===========================================================
module top_level (
    input  logic [3:0] SW,    // Entrada: 4 switches
    output logic [6:0] HEX0   // Salida: display de 7 segmentos
);

// Bloque combinacional: se evalúa cada cambio en "SW"
always_comb begin
    // Por defecto, apagamos el display (opcional, evita basura)
    HEX0 = 7'b1111111;

    // Selección del patrón según el valor del switch
    unique case (SW)   // "unique" ayuda a detectar valores faltantes
        4'd0  : HEX0 = 7'b1000000;  // 0
        4'd1  : HEX0 = 7'b1111001;  // 1
        4'd2  : HEX0 = 7'b0100100;  // 2
        4'd3  : HEX0 = 7'b0110000;  // 3
        4'd4  : HEX0 = 7'b0011001;  // 4
        4'd5  : HEX0 = 7'b0010010;  // 5
        4'd6  : HEX0 = 7'b0000010;  // 6
        4'd7  : HEX0 = 7'b1111000;  // 7
        4'd8  : HEX0 = 7'b0000000;  // 8
        4'd9  : HEX0 = 7'b0010000;  // 9
        4'd10 : HEX0 = 7'b0001000;  // A
        4'd11 : HEX0 = 7'b0000011;  // B
        4'd12 : HEX0 = 7'b1000110;  // C
        4'd13 : HEX0 = 7'b0100001;  // D
        4'd14 : HEX0 = 7'b0000110;  // E
        4'd15 : HEX0 = 7'b0001110;  // F
    endcase
end

endmodule
