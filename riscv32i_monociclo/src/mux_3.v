// Módulo para implementar el mux que permite saber que se va a escribir en rd
module mux_3(
  input wire [31:0] A,     // Entrada A de 32 bits
  input wire [31:0] B,     // Entrada B de 32 bits
  input wire [31:0] C,     // Entrada C de 32 bits
  input wire [1:0] select, // Señal de selección de 2 bits
  output reg [31:0] Out    // Salida de 32 bits
);

  // Bloque combinacional, se ejecuta siempre que select, A, B o C cambian
  always @(*) begin
    case(select)
      2'b10: Out = A;       // Si select es 10, salida es A
      2'b01: Out = B;       // Si select es 01, salida es B
      2'b00: Out = C;       // Si select es 00, salida es C
      default: Out = 32'bx; // Valor indefinido si no coincide con ningún caso
    endcase
  end

endmodule
