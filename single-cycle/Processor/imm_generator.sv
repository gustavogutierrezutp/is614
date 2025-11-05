module immediate_generator(
    input  logic [31:0] instr,     // full instruction
    input  logic [2:0]  imm_src,   // instruction type code
    output logic [31:0] imm        // 32-bit sign-extended immediate
);

/*
  imm_src codes:
  000 -> I-type (arithmetic/logical)
  001 -> I-type (load instructions)
  010 -> S-type (store: SB, SH, SW)
*/

always_comb begin
    case (imm_src)
        // I-type (ADDI, ANDI, ORI, etc.)
        3'b000: imm = {{20{instr[31]}}, instr[31:20]};
        
        // I-type (loads: LB, LH, LW, LBU, LHU)
        3'b001: imm = {{20{instr[31]}}, instr[31:20]};
        
        // S-type (stores: SB, SH, SW)
        3'b010: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        
        default: imm = 32'b0;
    endcase
end
endmodule
