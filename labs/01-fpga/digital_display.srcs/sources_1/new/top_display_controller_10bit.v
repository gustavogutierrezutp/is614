module top_hex_display_controller (
    input wire [9:0] binary_input, // 10 switches
    input wire       negate_button,

    output wire [9:0] led_outputs, // 10 LEDS
    output wire [6:0] segments_d3, // Dígito más a la izquierda (para un posible '0' inicial o un uso futuro)
    output wire [6:0] segments_d2, 
    output wire [6:0] segments_d1, // Dígito hexadecimal MSB del input de 8 bits
    output wire [6:0] segments_d0  // Dígito hexadecimal LSB del input de 8 bits
);

    // Conexión directa de switches a LEDs
    // Cuando los switches (binary_input) están en '1', el LED correspondiente se encenderá.
    assign led_outputs = binary_input;

    // Lógica del complemento a 2
    // Si negate_button está activo, display_value será el complemento a 2 de binary_input.
    // De lo contrario, será el valor de binary_input.
    wire [9:0] display_value; // Modificado a 10 bits
    assign display_value = ~negate_button ? (~binary_input + 1'b1) : binary_input;

    // --- LÓGICA DE DIVISIÓN PARA HEXADECIMAL ---
    // Para un input de 10 bits, se necesitan 3 dígitos hexadecimales (000-FFF).
    // Mantendremos 4 salidas de segmentos como en tu código original,
    // asignando el dígito más a la izquierda (hex_d2) a '0'.
    wire [3:0] hex_d3; // Nibble para el dígito 3 (el más a la izquierda)
    wire [3:0] hex_d2; // Nibble para el digito 2 (el digito hexadecimal del medio)
    wire [3:0] hex_d1; // Nibble para el dígito 1 (el dígito hexadecimal más significativo)
    wire [3:0] hex_d0; // Nibble para el dígito 0 (el dígito hexadecimal menos significativo)

    assign hex_d3 = 4'b0000; // Se asigna '0' para que el dígito más a la izquierda muestre un cero.
                         // Podrías dejar este dígito sin conectar en el top-level si solo quieres dos.
    assign hex_d2 = {2'b00, display_value[9:8]}; // Es la forma de de mostrar los digitos más grandes aceptados por el nibble
    assign hex_d1 = display_value[7:4]; // Bits 7 al 4 del valor a mostrar
    assign hex_d0 = display_value[3:0]; // Bits 3 al 0 del valor a mostrar

    // --- INSTANCIAS DE LOS DECODIFICADORES HEX ---
    // Estas instancias asumen que tienes un módulo llamado `hex_to_7_segment`
    // que convierte un valor hexadecimal de 4 bits a los 7 segmentos de un display.

    // Dígito 3 (MSB) - Mostrará un '0'
    hex_to_7_segment decoder_d3 (
        .hex_in(hex_d3),
        .segments(segments_d3)
    );
    
    // Dígito 2 
    hex_to_7_segment decoder_d2 (
        .hex_in(hex_d2),
        .segments(segments_d2)
    );
    
    // Dígito 1 (MSB del valor de 8 bits)
    hex_to_7_segment decoder_d1 (
        .hex_in(hex_d1),
        .segments(segments_d1)
    );

    // Dígito 0 (LSB del valor de 8 bits)
    hex_to_7_segment decoder_d0 (
        .hex_in(hex_d0),
        .segments(segments_d0)
    );

endmodule
