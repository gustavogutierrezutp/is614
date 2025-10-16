// Unidad de Control
module control_unit (
  input  logic [6:0] opcode, // Campo opcode de la instruccion
    output logic Branch, // Señal para branch
    output logic MemRead, // Lectura de memoria de datos
    output logic MemtoReg, // Seleccion para escribir en registro
    output logic [1:0] ALUOp, // Codigo para alu_control
    output logic MemWrite, // Escritura en memoria de datos
    output logic ALUSrc, // Seleccion del segundo operando de ALU (registro o inmediato)
    output logic RegWrite // Escritura en banco de registros
);

    // Codificación de opcodes según RV32I
    localparam OPCODE_R = 7'b0110011; // Tipo R (ADD, SUB, AND, OR, SLT, etc.)
    localparam OPCODE_I = 7'b0010011; // Tipo I (ADDI, ANDI, ORI, etc.)
    localparam OPCODE_LW = 7'b0000011; // Tipo I (LW)
    localparam OPCODE_S = 7'b0100011; // Tipo S (SW)

    always_comb begin
        // Valores por defecto
        Branch   = 0;
        MemRead  = 0;
        MemtoReg = 0;
        ALUOp    = 2'b00;
        MemWrite = 0;
        ALUSrc   = 0;
        RegWrite = 0;

        case (opcode)
            // Tipo R
            OPCODE_R: begin
                RegWrite = 1;
                ALUSrc   = 0;
                MemtoReg = 0;
                MemRead  = 0;
                MemWrite = 0;
                ALUOp    = 2'b10;
            end

            // Tipo I (ADDI, ANDI, ORI)
            OPCODE_I: begin
                RegWrite = 1;
                ALUSrc   = 1;
                MemtoReg = 0;
                MemRead  = 0;
                MemWrite = 0;
                ALUOp    = 2'b11;
            end

            // Tipo I (LW)
            OPCODE_LW: begin
                RegWrite = 1;
                ALUSrc   = 1;
                MemtoReg = 1;
                MemRead  = 1;
                MemWrite = 0;
                ALUOp    = 2'b00;
            end

            // Tipo S (SW)
            OPCODE_S: begin
                RegWrite = 0;
                ALUSrc   = 1;
                MemtoReg = 0;
                MemRead  = 0;
                MemWrite = 1;
                ALUOp    = 2'b00;
            end

            default: begin
                // Mantener todo en 0
            end
        endcase
    end
endmodule
