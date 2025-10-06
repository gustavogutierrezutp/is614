module alu(
    input  logic [31:0] a, b,
    input  logic [3:0]  ALUControl,
    output logic [31:0] result,
    output logic zero
);

    always_comb begin
        case (ALUControl)
            4'b0010: result = a + b; // ADD
            4'b0110: result = a - b; // SUB
            4'b0000: result = a & b; // AND
            4'b0001: result = a | b; // OR
            4'b0011: result = a ^ b; // XOR
            4'b0100: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT
            default: result = 32'hDEADBEEF; // Error/debug
        endcase
    end

    assign zero = (result == 0);
endmodule
