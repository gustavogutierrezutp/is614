module to_ascii (
    input [3:0] hex_digit, // Dato hexadecimal de 4 bits
    output reg [7:0] ascii  // Salida ASCII de 8 bits
);
    
    always @(*) begin
        case (hex_digit)
            4'h0: ascii = 8'h30; // '0'
            4'h1: ascii = 8'h31; // '1'
            4'h2: ascii = 8'h32; // '2'
            4'h3: ascii = 8'h33; // '3'
            4'h4: ascii = 8'h34; // '4'
            4'h5: ascii = 8'h35; // '5'
            4'h6: ascii = 8'h36; // '6'
            4'h7: ascii = 8'h37; // '7'
            4'h8: ascii = 8'h38; // '8'
            4'h9: ascii = 8'h39; // '9'
            4'hA: ascii = 8'h41; // 'A'
            4'hB: ascii = 8'h42; // 'B'
            4'hC: ascii = 8'h43; // 'C'
            4'hD: ascii = 8'h44; // 'D'
            4'hE: ascii = 8'h45; // 'E'
            4'hF: ascii = 8'h46; // 'F'
            default: ascii = 8'h20; // Espacio en blanco por defecto
        endcase
    end

endmodule
