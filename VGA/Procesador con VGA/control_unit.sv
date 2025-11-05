module control_unit (
  input   [6:0] opcode,   // Bits [6:0] 
  input   [2:0] funct3,   // Bits [14:12]
  input   [6:0] funct7,   // Bits [31:25]
  output        RUWr,
  output        AluASrc,
  output        AluBSrc,
  output  [4:0] AluOp,
  output  [2:0] ImmSrc,
  output        DMWR,       
  output  [2:0] DMCtrl,
  output  [1:0] RUDataWrSrc,
  output  [4:0] BrOp

);

  always @(*) begin
  
    RUWr = 1'b0;
	 AluASrc = 1'b0;
    AluBSrc = 1'b0;
    AluOp = 5'b00000;
	 ImmSrc  = 3'b000;
	 DMWR = 1'b0;
	 DMCtrl = 3'b000;
	 RUDataWrSrc = 2'b00;
	 BrOp = 5'b00000;

    case (opcode)
	 
      7'b0110011: //tipo R
		begin
        RUWr = 1'b1;
        AluBSrc = 1'b0;

        case ({funct7, funct3})
          10'b0000000_000: AluOp = 5'b00000; // ADD
          10'b0100000_000: AluOp = 5'b01000; // SUB
          10'b0000000_100: AluOp = 5'b00100; // XOR
          10'b0000000_110: AluOp = 5'b00110; // OR
          10'b0000000_111: AluOp = 5'b00111; // AND
          10'b0000000_001: AluOp = 5'b00001; // SLL
          10'b0000000_101: AluOp = 5'b00101; // SRL
          10'b0100000_101: AluOp = 5'b01101; // SRA
          10'b0000000_010: AluOp = 5'b00010; // SLT
          10'b0000000_011: AluOp = 5'b00011; // SLTU
        endcase
      end

      7'b0010011: // tipo I
		begin
        RUWr = 1'b1;
        AluBSrc = 1'b1; 
		  ImmSrc  = 3'b000;

        case (funct3)
          3'b000: AluOp = 5'b00000; // ADDI
			 3'b100: AluOp = 5'b00100; // XORI
			 3'b110: AluOp = 5'b00110; // ORI
			 3'b111: AluOp = 5'b00111; // ANDI
			 3'b001: AluOp = 5'b00001; // SLLI
          3'b010: AluOp = 5'b00010; // SLTI
          3'b011: AluOp = 5'b00011; // SLTIU
          3'b101: begin
            if (funct7 == 7'b0000000)
              AluOp = 5'b00101; // SRLI
            else if (funct7 == 7'b0100000)
              AluOp = 5'b01101; // SRAI
				end
        endcase
      end
		
		7'b0000011: // tipo I-Load
		begin
		  RUWr = 1'b1;
		  AluBSrc = 1'b1;
		  ImmSrc  = 3'b000;
		  AluOp   = 5'b00000;
		  DMWR    = 1'b0;
		  RUDataWrSrc = 2'b01;

		  case (funct3)
			 3'b000: DMCtrl = 3'b000; // LB
			 3'b001: DMCtrl = 3'b001; // LH
			 3'b010: DMCtrl = 3'b010; // LW
			 3'b100: DMCtrl = 3'b100; // LBU
			 3'b101: DMCtrl = 3'b101; // LHU
		  endcase
		end

			
		7'b0100011: // tipo S
		begin 
		  RUWr = 1'b0;
		  AluBSrc = 1'b1;
		  ImmSrc = 3'b001;
		  AluOp  = 5'b00000;
		  DMWR = 1'b1;

		  case (funct3)
			 3'b000: DMCtrl = 3'b010; // SB
			 3'b001: DMCtrl = 3'b001; // SH
			 3'b010: DMCtrl = 3'b000; // SW
		  endcase
		end
		
		
      7'b1100011: // tipo B
      begin
		  AluASrc = 1'b1;
        AluBSrc = 1'b1; 
        ImmSrc = 3'b101;
        DMWR = 1'b0;
        AluOp = 5'b01000; // resta

        case (funct3)
          3'b000: BrOp = 5'b01000; // BEQ
          3'b001: BrOp = 5'b01001; // BNE
          3'b100: BrOp = 5'b01100; // BLT
          3'b101: BrOp = 5'b01101; // BGE
          3'b110: BrOp = 5'b01110; // BLTU
          3'b111: BrOp = 5'b01111; // BGEU
          default: BrOp = 5'b00000; 
        endcase
      end


    endcase
  end

endmodule
