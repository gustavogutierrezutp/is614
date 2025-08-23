module top_level (
    input  logic [9:0] SW,     // Interruptores (10 bits)
    input  logic       KEY0,   // Botón para alternar interpretación
    output logic [6:0] HEX0,   // Unidades
    output logic [6:0] HEX1,   // Decenas
    output logic [6:0] HEX2,   // Centenas
    output logic [6:0] HEX3    // Miles
);

    logic signed [9:0] number;     // Número en binario de 10 bits
    logic signed [15:0] num_signed; // Valor interpretado (positivos o complemento a2)
    logic [15:0] abs_value;        // Valor absoluto para mostrar en 7seg

    // Asignación inicial: el número desde los switches
    assign number = SW;

    always_comb begin
        if (KEY0) begin
            // Modo "siempre positivo"
            num_signed = number;
        end else begin
            // Modo complemento a2
            num_signed = $signed(number);
        end

        // Usamos valor absoluto (para poder mostrar negativos)
        if (num_signed < 0)
            abs_value = -num_signed;
        else
            abs_value = num_signed;

        // Descomponer en dígitos decimales
        HEX0 = dec_to_7seg(abs_value % 10);          // unidades
        HEX1 = dec_to_7seg((abs_value / 10) % 10);   // decenas
        HEX2 = dec_to_7seg((abs_value / 100) % 10);  // centenas
        HEX3 = dec_to_7seg((abs_value / 1000) % 10); // miles
    end

    // Función de conversión: decimal (0-9) → display 7 segmentos
    function automatic logic [6:0] dec_to_7seg(input logic [3:0] d);
        case (d)
            4'd0: dec_to_7seg = 7'b1000000;
            4'd1: dec_to_7seg = 7'b1111001;
            4'd2: dec_to_7seg = 7'b0100100;
            4'd3: dec_to_7seg = 7'b0110000;
            4'd4: dec_to_7seg = 7'b0011001;
            4'd5: dec_to_7seg = 7'b0010010;
            4'd6: dec_to_7seg = 7'b0000010;
            4'd7: dec_to_7seg = 7'b1111000;
            4'd8: dec_to_7seg = 7'b0000000;
            4'd9: dec_to_7seg = 7'b0010000;
            default: dec_to_7seg = 7'b1111111; // apagado
        endcase
    endfunction

endmodule

