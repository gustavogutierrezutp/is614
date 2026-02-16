module imm_gen (
  input  wire [31:0] inst,
  output reg  [31:0] imm
);
  always @(*) begin
    imm = 32'b0; // valor por defecto

    case (inst[6:0])
      7'b0010011: // I-type (ADDI, ANDI, ORI, etc.)
        imm = {{20{inst[31]}}, inst[31:20]}; // extensión de signo

      7'b0000011: // Load (LW, LH, LB)
        imm = {{20{inst[31]}}, inst[31:20]}; // extensión de signo

      7'b0100011: // S-type (Store: SW, SH, SB)
        imm = {{20{inst[31]}}, inst[31:25], inst[11:7]}; // extensión de signo combinada

      default:
        imm = 32'b0;
    endcase
  end
endmodule
