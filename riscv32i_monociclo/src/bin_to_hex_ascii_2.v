module bin_to_hex_ascii_2(
    input [7:0] bin_in,         // Valor binario de 32 bits
    output [15:0] ascii_out      // Salida ASCII de 64 bits (8 caracteres x 8 bits)
);
    
    // Mapeo de cada dígito hexadecimal de bin_in a su representación ASCII
    
    to_ascii digit1(.hex_digit(bin_in[7:4]),   .ascii(ascii_out[15:8]));
    to_ascii digit0(.hex_digit(bin_in[3:0]),   .ascii(ascii_out[7:0]));

endmodule
