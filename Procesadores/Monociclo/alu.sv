module alu(
  input  [31:0] AluA,
  input  [31:0] AluB, 
  input  [4:0]  AluOp,		
  output [31:0] AluRes
);

  always @(*)
  
  case(AluOp)
    5'b00000: AluRes = AluA + AluB; 
	 5'b01000: AluRes = AluA - AluB;		
    5'b00100: AluRes = AluA ^ AluB;	//XOR
    5'b00110: AluRes = AluA | AluB;	//OR
    5'b00111: AluRes = AluA & AluB;	//AND
    5'b00101: AluRes = AluA >> AluB;	//Desplazamiento a la derecha
    5'b00001: AluRes = AluA << AluB;	//Desplazamiento a la izquierda
	 5'b01101: AluRes = $signed(AluA) >>> AluB;
    5'b00010: AluRes = $signed(AluA) < $signed(AluB);	
    5'b00011: AluRes = AluA < AluB;
	 5'b11111: AluRes = AluB;
  endcase

endmodule
