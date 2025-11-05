module control_unit (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    
    output logic [3:0] ALU_op,
    output logic       ALU_src,
    output logic       reg_write,
    output logic       mem_to_reg,
    output logic       mem_write,
    output logic       branch,
    output logic       jump,
    output logic [2:0] branch_type,
    output logic [2:0] immsrc     // agregado para controlar el imm_gen
);

    always_comb begin
        // Valores por defecto
        ALU_op      = 4'b0000;
        ALU_src     = 1'b0;
        reg_write   = 1'b0;
        mem_to_reg  = 1'b0;
        mem_write   = 1'b0;
        branch      = 1'b0;
        jump        = 1'b0;
        branch_type = 3'b000;
        immsrc      = 3'b000;

        case (opcode)

            // ---------------------- R-TYPE ----------------------
            7'b0110011: begin
                ALU_src   = 1'b0;
                reg_write = 1'b1;
                immsrc    = 3'b000; // no inmediato

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

            // ---------------------- I-TYPE ----------------------
            7'b0010011: begin
                ALU_src   = 1'b1;
                reg_write = 1'b1;
                immsrc    = 3'b000; // tipo I

                case (funct3)
                    3'b000: ALU_op = 4'b0010; // ADDI
                    3'b100: ALU_op = 4'b0011; // XORI
                    3'b110: ALU_op = 4'b0001; // ORI
                    3'b111: ALU_op = 4'b0000; // ANDI
                    3'b010: ALU_op = 4'b1000; // SLTI
                    3'b011: ALU_op = 4'b1001; // SLTIU
                    3'b001: ALU_op = 4'b0100; // SLLI
                    3'b101: begin
                        if (funct7 == 7'b0000000)
                            ALU_op = 4'b0101; // SRLI
                        else if (funct7 == 7'b0100000)
                            ALU_op = 4'b0111; // SRAI
                    end
                    default: ALU_op = 4'b0000;
                endcase
            end

            // ---------------------- LOAD ----------------------
            7'b0000011: begin
                ALU_src    = 1'b1;
                ALU_op     = 4'b0010; // ADD
                reg_write  = 1'b1;
                mem_to_reg = 1'b1;
                immsrc     = 3'b000;  // tipo I
            end

            // ---------------------- STORE ----------------------
            7'b0100011: begin
                ALU_src    = 1'b1;
                ALU_op     = 4'b0010; // ADD
                mem_write  = 1'b1;
                immsrc     = 3'b001;  // tipo S
            end

            // ---------------------- BRANCH ----------------------
            7'b1100011: begin
                ALU_src     = 1'b0;
                ALU_op      = 4'b0110; // SUB
                branch      = 1'b1;
                branch_type = funct3;
                immsrc      = 3'b010; // tipo B
            end

            // ---------------------- LUI ----------------------
            7'b0110111: begin
                ALU_src   = 1'b1;
                ALU_op    = 4'b0000; // pasa inmediato
                reg_write = 1'b1;
                immsrc    = 3'b011;  // tipo U
            end

            // ---------------------- AUIPC ----------------------
            7'b0010111: begin
                ALU_src   = 1'b1;
                ALU_op    = 4'b0010; // ADD
                reg_write = 1'b1;
                immsrc    = 3'b011;  // tipo U
            end

            // ---------------------- JAL ----------------------
            7'b1101111: begin
                ALU_src   = 1'b1;
                ALU_op    = 4'b0010; // ADD
                reg_write = 1'b1;
                jump      = 1'b1;
                immsrc    = 3'b100;  // tipo J
            end

            // ---------------------- JALR ----------------------
            7'b1100111: begin
                ALU_src   = 1'b1;
                ALU_op    = 4'b0010; // ADD
                reg_write = 1'b1;
                jump      = 1'b1;
                immsrc    = 3'b000;  // tipo I
            end

            default: begin
                // NOP o instrucción inválida
            end
        endcase
    end

endmodule
