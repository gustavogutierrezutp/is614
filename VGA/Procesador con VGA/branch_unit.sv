module branch_unit(
  input [31:0] A,
  input [31:0] B,
  input [4:0] BrOp,
  output branchOut
);

always @(*) begin
    case (BrOp)
      5'b01000: branchOut = (A == B);         // BEQ
      5'b01001: branchOut = (A != B);         // BNE
      5'b01100: branchOut = ($signed(A) <  $signed(B));  // BLT
      5'b01101: branchOut = ($signed(A) >= $signed(B));  // BGE
      5'b01110: branchOut = (A < B);          // BLTU
      5'b01111: branchOut = (A >= B);         // BGEU
		5'b11111: branchOut = 1'b0;
		5'b10111: branchOut = 1'b1;
		5'b10101: branchOut = 1'b0;
      default: branchOut = 1'b0;
    endcase
end

endmodule
