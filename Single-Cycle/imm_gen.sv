module imm_gen (
    input  logic [31:0] instruction,
    input  logic [2:0]  immsrc,   // Selector de tipo de inmediato
    output logic [31:0] imm_out
);

    always_comb begin
        case (immsrc)
            3'b000: // Tipo I (ADDI, LW, JALR)
                imm_out = {{20{instruction[31]}}, instruction[31:20]};
            
            3'b001: // Tipo S (SW, SH, SB)
                imm_out = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            
            3'b010: // Tipo B (BEQ, BNE, BLT, BGE)
                imm_out = {{19{instruction[31]}}, instruction[31], instruction[7],
                           instruction[30:25], instruction[11:8], 1'b0};
            
            3'b011: // Tipo U (LUI, AUIPC)
                imm_out = {instruction[31:12], 12'b0};
            
            3'b100: // Tipo J (JAL)
                imm_out = {{11{instruction[31]}}, instruction[31],
                           instruction[19:12], instruction[20],
                           instruction[30:21], 1'b0};
            
            default:
                imm_out = 32'b0;
        endcase
    end

endmodule
