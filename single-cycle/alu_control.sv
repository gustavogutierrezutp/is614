// Description: Unidad de Control de la ALU
module alu_control (
    input  logic [1:0] ALUOp, // Señal general de la Unidad de Control
    input  logic [2:0] funct3, // Campo funct3 de la instrucción
    input  logic [6:0] funct7, // Campo funct7 de la instrucción (solo para tipo R)
    output logic [3:0] alu_ctrl // Código que indica la operación específica para la ALU
);

    // Codificación interna para las operaciones de la ALU
    localparam ALU_ADD = 4'b0000;
    localparam ALU_SUB = 4'b0001;
    localparam ALU_AND = 4'b0010;
    localparam ALU_OR  = 4'b0011;
    localparam ALU_XOR = 4'b0100;
    localparam ALU_SLT = 4'b0101;
    localparam ALU_SLL = 4'b0110;
    localparam ALU_SRL = 4'b0111;

    always_comb begin
        alu_ctrl = ALU_ADD; // Valor por defecto (suma)

        case (ALUOp)
            // LW y SW usan suma para calcular direcciones de memoria
            2'b00: alu_ctrl = ALU_ADD;

            // Tipo R
            2'b10: begin
                case (funct3)
                    3'b000: alu_ctrl = (funct7 == 7'b0100000) ? ALU_SUB : ALU_ADD; // SUB o ADD
                    3'b111: alu_ctrl = ALU_AND; // AND
                    3'b110: alu_ctrl = ALU_OR;  // OR
                    3'b100: alu_ctrl = ALU_XOR; // XOR
                    3'b010: alu_ctrl = ALU_SLT; // SLT (Set Less Than)
                    3'b001: alu_ctrl = ALU_SLL; // Shift Left Logical
                    3'b101: alu_ctrl = ALU_SRL; // Shift Right Logical
                    default: alu_ctrl = ALU_ADD;
                endcase
            end

            // Tipo I
            2'b11: begin
                case (funct3)
                    3'b000: alu_ctrl = ALU_ADD; // ADDI
                    3'b111: alu_ctrl = ALU_AND; // ANDI
                    3'b110: alu_ctrl = ALU_OR;  // ORI
                    3'b100: alu_ctrl = ALU_XOR; // XORI
                    3'b010: alu_ctrl = ALU_SLT; // SLTI
                    3'b001: alu_ctrl = ALU_SLL; // SLLI
                    3'b101: alu_ctrl = ALU_SRL; // SRLI
                    default: alu_ctrl = ALU_ADD;
                endcase
            end

            default: alu_ctrl = ALU_ADD;
        endcase
    end

endmodule
