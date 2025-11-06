// Módulo de generador de inmediatos
module imm_generator(
    input wire [31:0] Inst,        // Instrucción de 32 bits
    input wire [2:0] ImmSrc,       // Selección del tipo de inmediato
    output reg [31:0] ImmExt       // Inmediato extendido de 32 bits
);

    // Bloque siempre combinacional
    always @* begin
        case (ImmSrc)
            3'b000: ImmExt = {{20{Inst[31]}}, Inst[31:20]};                  // I-type (extensión de signo)
            3'b001: ImmExt = {{20{Inst[31]}}, Inst[31:25], Inst[11:7]};      // S-type (extensión de signo)
            3'b101: ImmExt = {{19{Inst[31]}}, Inst[31], Inst[7], Inst[30:25], Inst[11:8], 1'b0}; // B-type (extensión de signo)
            3'b010: ImmExt = {Inst[31:12], 12'b0};                           // U-type (sin extensión de signo)
            3'b110: ImmExt = {{19{Inst[31]}}, Inst[31], Inst[19:12], Inst[20], Inst[30:21], 1'b0}; // J-type (extensión de signo)
            default: ImmExt = 32'b0;                                         // Valor indefinido por defecto
        endcase
    end

endmodule
