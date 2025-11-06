module control_unit(
  input wire [6:0] OpCode,        // Código de operación
  input wire [2:0] Funct3,        // Campo funct3 del conjunto de instrucciones
  input wire [6:0] Funct7,        // Campo funct7 del conjunto de instrucciones
  output reg [2:0] ImmSrc,        // Fuente de inmediato (3 bits)
  output reg ALUASrc,             // Selección de entrada A para ALU
  output reg ALUBSrc,             // Selección de entrada B para ALU
  output reg [3:0] ALUOp,         // Operación de la ALU (4 bits)
  output reg [1:0] RUDataWrSrc,   // Fuente de datos para escribir en registros
  output reg RUWr,                // Habilitación de escritura en registros
  output reg [4:0] BrOp,          // Control de operación de branch (5 bits)
  output reg DMWr,                // Señal de escritura en la memoria de datos
  output reg [2:0] DMCtrl         // Señal de control de la memoria de datos
);

  // Siempre se ejecutará cuando haya un cambio en las señales de entrada
  always @(*) begin
    case(OpCode)
      7'b0110011: begin // Tipo R
        ImmSrc = 3'bxxx;           // No imm
        ALUASrc = 1'b0;            // A proviene del registro
        ALUBSrc = 1'b0;            // B proviene del registro
        ALUOp = {Funct7[5], Funct3}; // Operación ALU compuesta por Funct7 y Funct3
        RUDataWrSrc = 2'b00;       // Fuente de datos para escritura en registros
        RUWr = 1'b1;                // Habilita escritura en registros
        BrOp = 5'b00xxx;           // No branch
        DMWr = 1'b0;               // No se escribe en la memoria de datos
        DMCtrl = 3'bxxx;           // No hay control de memoria
      end

      7'b0010011: begin // Tipo I
        ImmSrc = 3'b000;           // Imm
        ALUASrc = 1'b0;            // A proviene del registro
        ALUBSrc = 1'b1;            // B proviene del inmediato
        if (Funct3 == 3'b101)
          ALUOp = {Funct7[5], Funct3}; // Operaciones SRAI y SRLI
        else
          ALUOp = {1'b0, Funct3};      // Otras operaciones
        RUDataWrSrc = 2'b00;       // Fuente de datos para escritura en registros
        RUWr = 1'b1;                // Habilita escritura en registros
        BrOp = 5'b00xxx;           // No branch
        DMWr = 1'b0;               // No se escribe en la memoria de datos
        DMCtrl = 3'bxxx;           // No hay control de memoria
      end

      7'b1100011: begin // Tipo B
        ImmSrc = 3'b101;           // Imm
        ALUASrc = 1'b1;            // A proviene del inmediato
        ALUBSrc = 1'b1;            // B proviene del inmediato
        ALUOp = 4'b0000;           // Operación de comparación para branch
        RUDataWrSrc = 2'bxx;       // No se escribe en registro
        RUWr = 1'b0;               // No habilita escritura en registros
        BrOp = {2'b01, Funct3};    // Branch
        DMWr = 1'b0;               // No se escribe en la memoria de datos
        DMCtrl = 3'bxxx;           // No hay control de memoria
      end

      7'b0000011: begin // Tipo I Loads (Load de memoria)
        ImmSrc = 3'b000;           // Imm
        ALUASrc = 1'b0;            // A proviene del registro
        ALUBSrc = 1'b1;            // B proviene del inmediato
        ALUOp = 4'b0000;           // ALU suma para direccionar la memoria
        RUDataWrSrc = 2'b01;       // Los datos provienen de la memoria para escritura en registros
        RUWr = 1'b1;               // Habilita escritura en registros
        BrOp = 5'b00xxx;           // No branch
        DMWr = 1'b0;               // No se escribe en la memoria (carga)
        DMCtrl = Funct3;           // Control para acceder a la memoria con Funct3
      end

      7'b0100011: begin // Tipo S (Store de memoria)
        ImmSrc = 3'b001;           // Imm para store
        ALUASrc = 1'b0;            // A proviene del registro
        ALUBSrc = 1'b1;            // B proviene del inmediato
        ALUOp = 4'b0000;           // ALU suma para direccionar la memoria
        RUDataWrSrc = 2'bxx;       // No se escribe en registro
        RUWr = 1'b0;               // No habilita escritura en registros
        BrOp = 5'b00xxx;           // No branch
        DMWr = 1'b1;               // Habilita escritura en la memoria de datos
        DMCtrl = Funct3;           // Control para acceso a la memoria con Funct3
      end

      7'b1100111: begin // Tipo I JALR
        ImmSrc = 3'b000;           // Imm
        ALUASrc = 1'b0;            // A proviene del registro
        ALUBSrc = 1'b1;            // B proviene del inmediato
        ALUOp = 4'b0000;           // ALU calcula la dirección del salto
        RUDataWrSrc = 2'b10;       // Los datos para escritura en registros provienen del PC
        RUWr = 1'b1;               // Habilita escritura en registros
        BrOp = 5'b1xxxx;           // Branch para salto
        DMWr = 1'b0;               // No se escribe en la memoria de datos
        DMCtrl = 3'bxxx;           // No hay control de memoria
      end

      7'b1101111: begin // JAL
        ImmSrc = 3'b110;           // Imm
        ALUASrc = 1'b1;            // A proviene del inmediato
        ALUBSrc = 1'b1;            // B proviene del inmediato
        ALUOp = 4'b0000;           // ALU calcula la dirección del salto
        RUDataWrSrc = 2'b10;       // Los datos para escritura en registros provienen del PC
        RUWr = 1'b1;               // Habilita escritura en registros
        BrOp = 5'b1xxxx;           // Branch para salto
        DMWr = 1'b0;               // No se escribe en la memoria de datos
        DMCtrl = 3'bxxx;           // No hay control de memoria
      end

      default: begin // Operación desconocida
        ImmSrc = 3'bxxx;
        ALUASrc = 1'bx;
        ALUBSrc = 1'bx;
        ALUOp = 4'bxxxx;
        RUDataWrSrc = 2'bxx;
        RUWr = 1'b0;
        BrOp = 5'b00xxx;
        DMWr = 1'b0;               // No se escribe en la memoria de datos
        DMCtrl = 3'bxxx;           // No hay control de memoria
      end
    endcase
  end
endmodule

