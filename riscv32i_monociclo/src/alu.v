module alu(
  input wire [31:0] A, 
  input wire [31:0] B,
  input wire [3:0] ALUOp,  
  output reg [31:0] ALURes
);
  
  always @(*) begin // Se ejecutará siempre que haya un cambio en cualquier señal de entrada
    case(ALUOp)
      4'b0000: begin
        ALURes = A + B;      // Suma
      end
      4'b1000: begin
        ALURes = A - B;      // Resta
      end
      4'b0001: begin
        ALURes = A << B;     // Shift lógico a la izquierda
      end
      4'b0010: begin
        ALURes = (A < B) ? 32'b1 : 32'b0;  // Menor que, signed
      end
      4'b0011: begin
        ALURes = ($unsigned(A) < $unsigned(B)) ? 32'b1 : 32'b0; // Menor que, unsigned
      end
      4'b0100: begin
        ALURes = A ^ B;      // XOR
      end
      4'b0101: begin
        ALURes = A >> B;     // Shift lógico a la derecha
      end
      4'b1101: begin
        ALURes = A >>> B;    // Shift aritmético a la derecha
      end
      4'b0110: begin
        ALURes = A | B;      // OR
      end
      4'b0111: begin
        ALURes = A & B;      // AND
      end
      4'b1111: begin
        ALURes = B;          // Paso directo de B
      end
      default: ALURes = 32'bx; // Valor indeterminado si no hay cases
    endcase
  end

endmodule
