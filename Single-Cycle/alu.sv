module alu (
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic [3:0]  ALU_op,
    output logic [31:0] ALU_res,
    output logic        zero   
);

    always_comb begin
        case (ALU_op)
            4'b0000: ALU_res = A & B;                          // AND
            4'b0001: ALU_res = A | B;                          // OR
            4'b0010: ALU_res = A + B;                          // ADD / ADDI
            4'b0110: ALU_res = A - B;                          // SUB
            4'b0011: ALU_res = A ^ B;                          // XOR
            4'b0100: ALU_res = A << B[4:0];                    // SLL / SLLI
            4'b0101: ALU_res = A >> B[4:0];                    // SRL / SRLI
            4'b0111: ALU_res = $signed(A) >>> B[4:0];          // SRA / SRAI
            4'b1000: ALU_res = ($signed(A) < $signed(B)) 
                               ? 32'b1 : 32'b0;                // SLT / SLTI
            4'b1001: ALU_res = (A < B) ? 32'b1 : 32'b0;        // SLTU / SLTIU
            default: ALU_res = 32'b0;
        endcase
    end

    // Bandera de cero para ramas BEQ/BNE
    assign zero = (ALU_res == 32'b0);

endmodule
