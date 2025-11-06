module bin_to_hex_ascii(
    input [31:0] bin_in,         // Valor binario de 32 bits
    output [63:0] ascii_out      // Salida ASCII de 64 bits (8 caracteres x 8 bits)
);
    
    // Mapeo de cada dígito hexadecimal de bin_in a su representación ASCII
    to_ascii digit7(.hex_digit(bin_in[31:28]), .ascii(ascii_out[63:56]));
    to_ascii digit6(.hex_digit(bin_in[27:24]), .ascii(ascii_out[55:48]));
    to_ascii digit5(.hex_digit(bin_in[23:20]), .ascii(ascii_out[47:40]));
    to_ascii digit4(.hex_digit(bin_in[19:16]), .ascii(ascii_out[39:32]));
    to_ascii digit3(.hex_digit(bin_in[15:12]), .ascii(ascii_out[31:24]));
    to_ascii digit2(.hex_digit(bin_in[11:8]),  .ascii(ascii_out[23:16]));
    to_ascii digit1(.hex_digit(bin_in[7:4]),   .ascii(ascii_out[15:8]));
    to_ascii digit0(.hex_digit(bin_in[3:0]),   .ascii(ascii_out[7:0]));

endmodule
