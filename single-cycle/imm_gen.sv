// Generador de Inmediatos
module imm_gen (
  input  logic [31:0] instr, // Instrucción completa
  output logic [31:0] imm_out // Inmediato extendido (sign-extended)
);

    logic [6:0] opcode;

    assign opcode = instr[6:0];

    always_comb begin
        case (opcode)
            // I-TYPE: addi, lw, etc - imm[11:0] = instr[31:20]
            7'b0010011, // addi, xori, ori, andi, slli, srli, srai
            7'b0000011: // lw
                imm_out = {{20{instr[31]}}, instr[31:20]};

            // S-TYPE: sw - imm[11:5] = instr[31:25], imm[4:0] = instr[11:7]
            7'b0100011: // sw
                imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            default:
                imm_out = 32'b0;
        endcase
    end

endmodule
