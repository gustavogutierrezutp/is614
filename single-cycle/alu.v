module alu(
  input  wire [31:0] A,
  input  wire [31:0] B,
  input  wire [3:0] op,
  output reg  [31:0] ALUres,
  output reg  zero
);

always @(*) begin
  case (op)
    4'b0000: begin 
      zero <= 0;
      ALUres = A + B; 
    end
    4'b0001: begin 
      zero <= 0;
      ALUres = A - B; 
    end
    4'b0010: begin 
      zero <= 0;
      ALUres = A ^ B; 
    end
    4'b0011: begin 
      zero <= 0;
      ALUres = A & B; 
    end
    4'b0100: begin 
      zero <= 0;
      ALUres = A | B; 
    end
    4'b0101: begin 
      zero <= 0;
      ALUres = A << B[4:0]; 
    end
    4'b0110: begin 
      zero <= 0;
      ALUres = A >> B[4:0]; 
    end
    default: begin 
      zero <= 1;
      ALUres = 32'b0; 
    end
  endcase
end

endmodule
