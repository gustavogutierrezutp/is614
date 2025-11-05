module control_unit(
  input  wire [6:0] opcode,
  input  wire [2:0] funct3,
  input  wire [6:0] funct7,
  output reg  [4:0] ALUOp,
  output reg  [2:0] IMMSrc,
  output reg        ALUBSrc,
  output reg        RegWrite,
  output reg        MemtoReg,
  output reg        DMWR,       // 1 = store, 0 = load/none
  output reg  [2:0] DMCtrl,     // 000=byte,001=half,010=word, etc
  output reg  [4:0] BrOp        // Señal hacia Branch Unit
);

  
  localparam [6:0] RTYPE  = 7'b0110011;
  localparam [6:0] IARITH = 7'b0010011;
  localparam [6:0] ILOAD  = 7'b0000011;
  localparam [6:0] STORE  = 7'b0100011;
  localparam [6:0] BRANCH = 7'b1100011;


  localparam [4:0] ADD     = 5'b00000;
  localparam [4:0] SUB     = 5'b00001;
  localparam [4:0] SLL     = 5'b00010;
  localparam [4:0] SLT     = 5'b00011;
  localparam [4:0] SLTU    = 5'b00100;
  localparam [4:0] XOR_    = 5'b00101;
  localparam [4:0] SRL     = 5'b00110;
  localparam [4:0] SRA     = 5'b00111;
  localparam [4:0] OR_     = 5'b01000;
  localparam [4:0] AND_    = 5'b01001;
  localparam [4:0] ALU_NOP = 5'b11111;


  localparam [4:0] BR_NOP = 5'b00000;
  localparam [4:0] BR_EQ  = 5'b00001;
  localparam [4:0] BR_NE  = 5'b00010;
  localparam [4:0] BR_LT  = 5'b00011;
  localparam [4:0] BR_GE  = 5'b00100;
  localparam [4:0] BR_LTU = 5'b00101;
  localparam [4:0] BR_GEU = 5'b00110;

  // funct7 constants
  localparam [6:0] F7_0000000 = 7'b0000000;
  localparam [6:0] F7_0100000 = 7'b0100000;

  always @(*) begin
    // Valores por defecto
    ALUOp    = ALU_NOP;
    IMMSrc   = 3'b000;
    ALUBSrc  = 1'b0;
    RegWrite = 1'b0;
    MemtoReg = 1'b0;
    DMWR     = 1'b0;
    DMCtrl   = 3'b000;
    BrOp     = BR_NOP;

    case (opcode)
      RTYPE: begin
        RegWrite = 1'b1;
        ALUBSrc  = 1'b0;
        IMMSrc   = 3'b000;

        case (funct3)
          3'b000: ALUOp = (funct7 == F7_0100000) ? SUB : ADD;
          3'b100: ALUOp = XOR_;
          3'b110: ALUOp = OR_;
          3'b111: ALUOp = AND_;
          3'b001: ALUOp = SLL;
          3'b101: ALUOp = (funct7 == F7_0100000) ? SRA : SRL;
          3'b010: ALUOp = SLT;
          3'b011: ALUOp = SLTU;
          default: ALUOp = ALU_NOP;
        endcase
      end
		
      IARITH: begin
        RegWrite = 1'b1;
        ALUBSrc  = 1'b1;
        IMMSrc   = 3'b000;

        case (funct3)
          3'b000: ALUOp = ADD;
          3'b100: ALUOp = XOR_;
          3'b110: ALUOp = OR_;
          3'b111: ALUOp = AND_;
          3'b001: ALUOp = (funct7 == F7_0000000) ? SLL : ALU_NOP;
          3'b101: ALUOp = (funct7 == F7_0100000) ? SRA : SRL;
          3'b010: ALUOp = SLT;
          3'b011: ALUOp = SLTU;
          default: ALUOp = ALU_NOP;
        endcase
      end

      ILOAD: begin
        RegWrite = 1'b1;
        MemtoReg = 1'b1;
        ALUBSrc  = 1'b1;
        IMMSrc   = 3'b000;
        ALUOp    = ADD;
        DMWR     = 1'b0;

        case (funct3)
          3'b010: DMCtrl = 3'b010; // LW
          3'b001: DMCtrl = 3'b001; // LH
          3'b000: DMCtrl = 3'b000; // LB
          3'b100: DMCtrl = 3'b100; // LBU
          3'b101: DMCtrl = 3'b101; // LHU
          default: DMCtrl = 3'b000;
        endcase
      end
		
      STORE: begin
        RegWrite = 1'b0;
        ALUBSrc  = 1'b1;
        IMMSrc   = 3'b001;
        ALUOp    = ADD;
        DMWR     = 1'b1;

        case (funct3)
          3'b010: DMCtrl = 3'b010; // SW
          3'b001: DMCtrl = 3'b001; // SH
          3'b000: DMCtrl = 3'b000; // SB
          default: DMCtrl = 3'b000;
        endcase
      end
		
      BRANCH: begin
        RegWrite = 1'b0;
        ALUBSrc  = 1'b0;   // comparación entre registros
        IMMSrc   = 3'b101; // inmediato tipo B

        case (funct3)
          3'b000: BrOp = BR_EQ;   // BEQ
          3'b001: BrOp = BR_NE;   // BNE
          3'b100: BrOp = BR_LT;   // BLT
          3'b101: BrOp = BR_GE;   // BGE
          3'b110: BrOp = BR_LTU;  // BLTU
          3'b111: BrOp = BR_GEU;  // BGEU
          default: BrOp = BR_NOP;
        endcase
      end

      default: begin
        // Nada
      end
    endcase
  end

endmodule
