// ALU

module alu (
    input  logic [31:0] a, // Operando 1 (rs1)
    input  logic [31:0] b, // Operando 2 (rs2 o inmediato)
    input  logic [3:0]  alu_ctrl, // Señal de control de la ALU
    output logic [31:0] result, // Resultado
    output logic        zero // 1 si el resultado es 0
);

    always_comb begin
        case (alu_ctrl)
            4'b0000: result = a + b; // ADD
            4'b0001: result = a - b; // SUB
            4'b0010: result = a & b; // AND
            4'b0011: result = a | b; // OR
            4'b0100: result = a ^ b; // XOR
            4'b0101: result = a << b[4:0]; // SLL
            4'b0110: result = a >> b[4:0]; // SRL
            4'b0111: result = $signed(a) >>> b[4:0]; // SRA
            4'b1000: result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0; // SLT
            4'b1001: result = (a < b) ? 32'b1 : 32'b0; // SLTU
            default: result = 32'b0;
        endcase
    end

    assign zero = (result == 32'b0);

endmodule
