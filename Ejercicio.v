module Ejercicio (
    input  [9:0] SW,          // Switches de entrada
	 input  [1:0] KEY,         // KEY[0] = complemento a 1, KEY[1] = complemento a 2
    output [6:0] HEX0,        // Display 0 (menos significativo)
    output [6:0] HEX1,        // Display 1
    output [6:0] HEX2         // Display 2 (más significativo)
);

    wire [11:0] numero;       // número extendido a 12 bits
	 reg  [11:0] resultado;    // resultado según el botón


    assign numero = {2'b00, SW};  // Extiende los 10 bits a 12
	 
	 always @(*) begin
        if (~KEY[0]) begin
            // Complemento a 1
            resultado = ~numero;
        end else if (~KEY[1]) begin
            // Complemento a 2
            resultado = ~numero + 1;
        end else begin
            // Sin transformación, muestra el número original
            resultado = numero;
        end
    end


    // Instancias del decodificador para cada display
    display_7seg h0 (.x(resultado[3:0]),  .seg(HEX0));
    display_7seg (.x(resultado[7:4]),  .seg(HEX1));
    display_7seg (.x(resultado[11:8]), .seg(HEX2));

endmodule


// ========================================================
// Decodificador Hexadecimal a Display de 7 Segmentos
// Activo en bajo (como la DE1-SoC)
// ========================================================
module display_7seg (
    input  [3:0] x,
    output reg [6:0] seg
);
    always @(*) begin
        case (x)
            4'h0: seg = 7'b1000000; // 0
            4'h1: seg = 7'b1111001; // 1
            4'h2: seg = 7'b0100100; // 2
            4'h3: seg = 7'b0110000; // 3
            4'h4: seg = 7'b0011001; // 4
            4'h5: seg = 7'b0010010; // 5
            4'h6: seg = 7'b0000010; // 6
            4'h7: seg = 7'b1111000; // 7
            4'h8: seg = 7'b0000000; // 8
            4'h9: seg = 7'b0010000; // 9
            4'hA: seg = 7'b0001000; // A
            4'hB: seg = 7'b0000011; // b
            4'hC: seg = 7'b1000110; // C
            4'hD: seg = 7'b0100001; // d
            4'hE: seg = 7'b0000110; // E
            4'hF: seg = 7'b0001110; // F
            default: seg = 7'b1111111; // apagado
        endcase
    end
endmodule
