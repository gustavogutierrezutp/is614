// Módulo para implementar elos mux 2_1 del procesador
module mux_2(
  input wire [31:0] A,     // Entrada A de 32 bits
  input wire [31:0] B,     // Entrada B de 32 bits
  input wire select,       // Señal de selección
  output reg [31:0] Out    // Salida de 32 bits
);

  // Bloque combinacional, se ejecuta siempre que select, A o B cambian
  always @(*) begin
    case(select)
      1'b0: Out = A;       // Si select es 0, salida es A
      1'b1: Out = B;       // Si select es 1, salida es B
    endcase
  end

endmodule
