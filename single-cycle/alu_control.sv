module alu_control(
    input  logic [1:0]  ALUOp,
    input  logic [6:0]  funct7,
    input  logic [2:0]  funct3,
    output logic [3:0]  ALUControl
);

    always_comb begin
        case (ALUOp)
            2'b00: ALUControl = 4'b0010;
            2'b01: ALUControl = 4'b0110;
            2'b10: begin
                case ({funct7, funct3})
                    10'b0000000_000: ALUControl = 4'b0010; // ADD
                    10'b0100000_000: ALUControl = 4'b0110; // SUB
                    10'b0000000_111: ALUControl = 4'b0000; // AND
                    10'b0000000_110: ALUControl = 4'b0001; // OR
                    10'b0000000_100: ALUControl = 4'b0011; // XOR
                    10'b0000000_010: ALUControl = 4'b0100; // SLT (Set Less Than)
                    default:          ALUControl = 4'b1111; // Desconocida
                endcase
            end
            default: ALUControl = 4'b1111;
        endcase
    end
endmodule
