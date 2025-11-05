module imm_generator(
  input   [31:0] instruction,
  input   [2:0]  ImmSrc,
  output  [31:0] imm_out
);

  always @(*) begin
    case (ImmSrc)
      3'b000: // tipo I
        imm_out = {{20{instruction[31]}}, instruction[31:20]};
		  
      3'b001: //tipo S
        imm_out = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
		  
      3'b101: // tipo B
        imm_out = {{19{instruction[31]}}, instruction[31], instruction[7],
                    instruction[30:25], instruction[11:8], 1'b0};

		 
    endcase
  end

endmodule
