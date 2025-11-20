module imm_generator(
  input   [31:0] instruction,
  input   [2:0]  ImmSrc,
  output  [31:0] imm_out
);

wire [2:0] funct3 = instruction[14:12];

  always @(*) begin
    case (ImmSrc)
      3'b000: // tipo I
		  begin
		    if (funct3 == 3'b001 || funct3 == 3'b101)
              imm_out = {27'b0, instruction[24:20]}; 
          else
				  imm_out = {{20{instruction[31]}}, instruction[31:20]};
		  end
      3'b001: //tipo S
        imm_out = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
		  
      3'b101: // tipo B
        imm_out = {{19{instruction[31]}}, instruction[31], instruction[7],
                    instruction[30:25], instruction[11:8], 1'b0};
						  
		3'b110: // tipo J (JAL)
		  imm_out = {{12{instruction[31]}}, instruction[19:12], instruction[20], 
						  instruction[30:21], 1'b0};
					
		3'b010: // tipo U
        imm_out = {instruction[31:12], 12'b0};
      
      default:
        imm_out = 32'b0;

    endcase
  end

endmodule
