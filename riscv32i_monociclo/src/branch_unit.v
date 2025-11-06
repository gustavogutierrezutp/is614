module branch_unit(
  input wire signed [31:0] A,        // Entrada A (32 bits, signo)
  input wire signed [31:0] B,        // Entrada B (32 bits, signo)
  input wire [4:0] BrOp,             // Código de operación de branch (5 bits)
  output reg NextPCSrc               // Salida para determinar la fuente de la próxima PC
);

  // Lógica combinacional para calcular NextPCSrc
  always @(*) begin
    if (BrOp[4]) begin
      NextPCSrc = 1'b1;                // Si BrOp[4] es 1, NextPCSrc es 1
    end else if (BrOp[3]) begin
      case (BrOp[2:0])
        3'b000: // BEQ
          NextPCSrc = (A == B);        // Igualdad
        3'b001: // BNE
          NextPCSrc = (A != B);        // Desigualdad
        3'b100: // BLT
          NextPCSrc = (A < B);         // Menor que
        3'b101: // BGE
          NextPCSrc = (A >= B);        // Mayor o igual que
        3'b110: // BLTU
          NextPCSrc = ($unsigned(A) < $unsigned(B)); // Menor que (sin signo)
        3'b111: // BGEU
          NextPCSrc = ($unsigned(A) >= $unsigned(B)); // Mayor o igual que (sin signo)
        default: NextPCSrc = 1'b0;     // Valor indeterminado
      endcase
    end else begin
      NextPCSrc = 1'b0;                // Si ninguna condición es verdadera, NextPCSrc es 0
    end
  end

endmodule

