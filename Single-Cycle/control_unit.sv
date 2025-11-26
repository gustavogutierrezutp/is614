
module control_unit (

    input  logic [6:0] opcode,      // Código de operación 
    input  logic [2:0] funct3,      // Campo de función de 3 bits
    input  logic [6:0] funct7,      // Campo de función de 7 bits

   
    output logic [3:0] ALU_op,      // Operación a realizar por la ALU
    output logic       ALU_src,     // Mux entrada B ALU: 0 = rs2, 1 = Inmediato
    output logic       ALU_Asrc,    // Mux entrada A ALU: 0 = rs1, 1 = PC Actual

    output logic       reg_write,   // Habilita escritura en Banco de Registros
    output logic       mem_to_reg,  // Selección de dato a escribir: 0 = ALU, 1 = Memoria
    output logic       mem_write,   // Habilita escritura en Memoria de Datos
    output logic       branch,      // Indica si es una instrucción de salto condicional
    output logic       jump,        // Indica si es un salto incondicional 
    output logic [2:0] branch_type, // Tipo de comparación para saltos (BEQ, BNE, etc.)
    output logic [2:0] immsrc,      // Tipo de inmediato a generar 

    output logic [6:0] funct7_out,   // Pasa funct7 para lógica externa 
    output logic [2:0] mem_ctrl_out, // Pasa funct3 para controlar tamaño de carga/guarda 
  
    output logic       is_halted     // Activa si se detecta EBREAK
	 
);

    always_comb begin
       
        ALU_op       = 4'b0000;
        ALU_src      = 1'b0;
        ALU_Asrc     = 1'b0;   
        reg_write    = 1'b0;
        mem_to_reg   = 1'b0;
        mem_write    = 1'b0;
        branch       = 1'b0;
        jump         = 1'b0;
        branch_type  = 3'b000;
        immsrc       = 3'b111; 
        
        funct7_out   = 7'b0;   
        mem_ctrl_out = 3'b0;   
        is_halted    = 1'b0;   

        // ========================================================
        // DECODIFICACIÓN POR OPCODE
        // ========================================================
		  
        case (opcode)

            // ----------------------------------------------------
            // R-TYPE (Operaciones entre registros)
            // opcode: 0110011
            // ----------------------------------------------------
				
            7'b0110011: begin
                ALU_src    = 1'b0; // B = rs2
                ALU_Asrc   = 1'b0; // A = rs1
                reg_write  = 1'b1; // Escribir resultado en rd
                immsrc     = 3'b111;
                funct7_out = funct7; 

                case ({funct7, funct3})
                    10'b0000000_000: ALU_op = 4'b0010; // ADD
                    10'b0100000_000: ALU_op = 4'b0110; // SUB
                    10'b0000000_111: ALU_op = 4'b0000; // AND
                    10'b0000000_110: ALU_op = 4'b0001; // OR
                    10'b0000000_100: ALU_op = 4'b0011; // XOR
                    10'b0000000_010: ALU_op = 4'b1000; // SLT
                    10'b0000000_011: ALU_op = 4'b1001; // SLTU
                    10'b0000000_001: ALU_op = 4'b0100; // SLL
                    10'b0000000_101: ALU_op = 4'b0101; // SRL
                    10'b0100000_101: ALU_op = 4'b0111; // SRA
                    default:         ALU_op = 4'b0000;
                endcase
            end

            // ----------------------------------------------------
            // I-TYPE (Operaciones con Inmediato)
            // opcode: 0010011
            // ----------------------------------------------------
				
            7'b0010011: begin
                ALU_src   = 1'b1; // B = Inmediato
                ALU_Asrc  = 1'b0; // A = rs1
                reg_write = 1'b1; // Escribir en rd
                immsrc    = 3'b000;

                case (funct3)
                    3'b000: ALU_op = 4'b0010; // ADDI
                    3'b100: ALU_op = 4'b0011; // XORI
                    3'b110: ALU_op = 4'b0001; // ORI
                    3'b111: ALU_op = 4'b0000; // ANDI
                    3'b010: ALU_op = 4'b1000; // SLTI
                    3'b011: ALU_op = 4'b1001; // SLTIU
                 
                    3'b001: begin 
                        ALU_op = 4'b0100;     // SLLI
                        funct7_out = funct7; 
                    end
                    3'b101: begin
                        funct7_out = funct7; 
                        if (funct7 == 7'b0000000) 
                            ALU_op = 4'b0101; // SRLI
                        else 
                            ALU_op = 4'b0111; // SRAI
                    end
                    default: ALU_op = 4'b0000;
                endcase
            end

            // ----------------------------------------------------
            // LOAD (Carga de memoria)
            // opcode: 0000011
            // ----------------------------------------------------
				
            7'b0000011: begin
                ALU_src      = 1'b1;     // B = Inmediato
                ALU_Asrc     = 1'b0;     // A = rs1 (Base)
                ALU_op       = 4'b0010;  // ADD (Calcular dirección: Base + Offset)
                reg_write    = 1'b1;     // Escribir en rd
                mem_to_reg   = 1'b1;     // Dato viene de memoria, no de ALU
                immsrc       = 3'b000;   // Inmediato Tipo I
                mem_ctrl_out = funct3;   // LB, LH, LW, LBU, LHU
            end

            // ----------------------------------------------------
            // STORE (Guarda en memoria)
            // opcode: 0100011
            // ----------------------------------------------------
				
            7'b0100011: begin
                ALU_src      = 1'b1;     // B = Inmediato
                ALU_Asrc     = 1'b0;     // A = rs1 (Base)
                ALU_op       = 4'b0010;  // ADD (Calcular dirección)
                mem_write    = 1'b1;     // Habilitar escritura en memoria
                immsrc       = 3'b001;   // Inmediato Tipo S
                mem_ctrl_out = funct3;   // SB, SH, SW
            end

            // ----------------------------------------------------
            // BRANCH (Saltos condicionales)
            // opcode: 1100011
            // ----------------------------------------------------
				
            7'b1100011: begin
                
                ALU_src     = 1'b1;    // B = Inmediato
                ALU_Asrc    = 1'b1;    // A = PC Actual
                ALU_op      = 4'b0010; // ADD (Target = PC + Inmediato)
                
                branch      = 1'b1;    // Habilitar lógica de branch
                branch_type = funct3;  // BEQ, BNE, etc.
                immsrc      = 3'b010;  // Inmediato Tipo B
            end

            // ----------------------------------------------------
            // LUI (Load Upper Immediate)
            // opcode: 0110111
            // ----------------------------------------------------
				
            7'b0110111: begin
                ALU_src    = 1'b1; 
                ALU_Asrc   = 1'b0;     // A = x0 (que es 0)
                ALU_op     = 4'b0010;  // ADD
                reg_write  = 1'b1; 
                immsrc     = 3'b011;   // Inmediato Tipo U
            end

            // ----------------------------------------------------
            // AUIPC (Add Upper Immediate to PC)
            // opcode: 0010111
            // ----------------------------------------------------
				
            7'b0010111: begin
                ALU_src    = 1'b1; 
                ALU_Asrc   = 1'b1;     // A = PC
                ALU_op     = 4'b0010;  // ADD (Resultado = PC + Imm)
                reg_write  = 1'b1; 
                immsrc     = 3'b011;   // Inmediato Tipo U
            end

            // ----------------------------------------------------
            // JAL (Jump and Link - Salto incondicional)
            // opcode: 1101111
            // ----------------------------------------------------
				
            7'b1101111: begin
                ALU_src    = 1'b1; 
                ALU_Asrc   = 1'b1;     // A = PC
                ALU_op     = 4'b0010;  // ADD (Target = PC + Imm)
                reg_write  = 1'b1;     // Guardar PC+4 en rd (Link)
                jump       = 1'b1;     // Señal de salto incondicional
                immsrc     = 3'b100;   // Inmediato Tipo J
            end

            // ----------------------------------------------------
            // JALR (Jump and Link Register)
            // opcode: 1100111
            // ----------------------------------------------------
				
            7'b1100111: begin
                ALU_src    = 1'b1; 
                ALU_Asrc   = 1'b0;     // A = rs1 (Diferencia clave con JAL)
                ALU_op     = 4'b0010;  // ADD (Target = rs1 + Imm)
                reg_write  = 1'b1;     // Guardar PC+4 en rd
                jump       = 1'b1; 
                immsrc     = 3'b000;   // Inmediato Tipo I
            end

            // ----------------------------------------------------
            // SYSTEM
            // opcode: 1110011
            // ----------------------------------------------------
				
            7'b1110011: begin
                is_halted = 1'b1;      // EBREAK
            end

            default: begin end
        endcase
    end
endmodule