module top_level (                           // Definición del módulo principal "top_level"
    input  logic [9:0] SW,                   // Entrada: 10 switches (bits de entrada)
    output logic [9:0] LEDR,                 // Salida: 10 LEDs rojos
    output logic [6:0] HEX0, HEX1, HEX2, HEX3 // Salida: 4 displays de 7 segmentos (cada uno usa 7 bits)
);

    // Reflejo directo de switches en LEDs
    assign LEDR = SW;                        // Lo que se encienda en los switches se refleja igual en los LEDs

    // Expandir a 16 bits (por comodidad)
    logic [15:0] value;                      // Se crea una variable interna de 16 bits
    assign value = SW;                       // Se copia el valor de los switches en "value" (los bits extra se rellenan en 0)

    // Conversión a 7 segmentos (activos en bajo)
    function automatic [6:0] to7seg(input logic [3:0] nibble); // Función que recibe 4 bits y devuelve el patrón de 7 segmentos
        case (nibble)                       // Se selecciona el patrón según el valor hexadecimal del nibble
            4'h0: to7seg = 7'b1000000;      // Dígito 0
            4'h1: to7seg = 7'b1111001;      // Dígito 1
            4'h2: to7seg = 7'b0100100;      // Dígito 2
            4'h3: to7seg = 7'b0110000;      // Dígito 3
            4'h4: to7seg = 7'b0011001;      // Dígito 4
            4'h5: to7seg = 7'b0010010;      // Dígito 5
            4'h6: to7seg = 7'b0000010;      // Dígito 6
            4'h7: to7seg = 7'b1111000;      // Dígito 7
            4'h8: to7seg = 7'b0000000;      // Dígito 8
            4'h9: to7seg = 7'b0010000;      // Dígito 9
            4'hA: to7seg = 7'b0001000;      // Letra A
            4'hB: to7seg = 7'b0000011;      // Letra b
            4'hC: to7seg = 7'b1000110;      // Letra C
            4'hD: to7seg = 7'b0100001;      // Letra d
            4'hE: to7seg = 7'b0000110;      // Letra E
            4'hF: to7seg = 7'b0001110;      // Letra F
            default: to7seg = 7'b1111111;   // Apagado en cualquier otro caso
        endcase
    endfunction

    always_comb begin
        HEX0 = to7seg(value[3:0]);   // Convierte los 4 bits menos significativos a un dígito de 7 segmentos
        HEX1 = to7seg(value[7:4]);   // Convierte los siguientes 4 bits en el segundo display
        HEX2 = to7seg(value[9:8]);   // Muestra los bits 8 y 9 (solo 2 bits) en un display de 7 segmentos
        HEX3 = 7'b1111111;           // Mantiene apagado el display 3
    end
endmodule
