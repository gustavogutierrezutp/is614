module top_level (
    input  logic [9:0] SW,         // Entradas: 10 switches
    output logic [9:0] LEDR,       // Salidas: 10 LEDs rojos
    output logic [6:0] HEX0, HEX1, HEX2, HEX3 // Displays 7 segmentos
);

    // Reflejar directamente el estado de los switches en los LEDs
    assign LEDR = SW;

    // Se amplía el bus a 16 bits (para organizar mejor los nibbles)
    logic [15:0] dato_ext;
    assign dato_ext[9:0]  = SW;     // Los 10 bits provienen de los switches
    assign dato_ext[15:10] = 6'b0;  // Bits superiores en cero

    // Función para decodificar un valor hexadecimal en formato 7 segmentos
    function automatic [6:0] seg7_decode(input logic [3:0] valor);
        case (valor)
            4'h0: seg7_decode = 7'b1000000;
            4'h1: seg7_decode = 7'b1111001;
            4'h2: seg7_decode = 7'b0100100;
            4'h3: seg7_decode = 7'b0110000;
            4'h4: seg7_decode = 7'b0011001;
            4'h5: seg7_decode = 7'b0010010;
            4'h6: seg7_decode = 7'b0000010;
            4'h7: seg7_decode = 7'b1111000;
            4'h8: seg7_decode = 7'b0000000;
            4'h9: seg7_decode = 7'b0010000;
            4'hA: seg7_decode = 7'b0001000;
            4'hB: seg7_decode = 7'b0000011;
            4'hC: seg7_decode = 7'b1000110;
            4'hD: seg7_decode = 7'b0100001;
            4'hE: seg7_decode = 7'b0000110;
            4'hF: seg7_decode = 7'b0001110;
            default: seg7_decode = 7'b1111111; // Apagado
        endcase
    endfunction

    // Asignación a cada display de 7 segmentos
    always_comb begin
        HEX0 = seg7_decode(dato_ext[3:0]);   // Primer nibble (4 bits menos significativos)
        HEX1 = seg7_decode(dato_ext[7:4]);   // Segundo nibble
        HEX2 = seg7_decode({2'b00, dato_ext[9:8]}); // Solo 2 bits, se rellenan con ceros
        HEX3 = 7'b1111111;                   // Display apagado
    end
endmodule