module genInm (
  input  wire [31:0] instr,
  input  wire [2:0] IMMSrc,
  output logic [31:0] imm_out
);

  localparam IARITH_LOAD = 3'b000; 
  localparam STORE_TYPE  = 3'b001; 
  localparam BRANCH_TYPE = 3'b101;

  always @(*) begin
    case (IMMSrc)
      IARITH_LOAD: begin
        imm_out = {{20{instr[31]}}, instr[31:20]};
      end
      STORE_TYPE: begin
        imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]};
      end
		
		BRANCH_TYPE: begin
			imm_out = {{19{instr[31]}}, instr[31], instr[7],instr[30:25], instr[11:8], 1'b0};
		end
      default: imm_out = 32'b0;
    endcase
  end

endmodule
