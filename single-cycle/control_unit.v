module control_unit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg  [3:0] alu_op,
    output reg        reg_write,
	 output reg        mem_read,
    output reg        mem_write,
    output reg        mem_to_reg
);
    always @(*) begin
        // valores por defecto
        alu_op = 4'b0000;
        reg_write = 1'b0;
		  mem_read   = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;

        case (opcode)
            7'b0110011: begin // R-type
                reg_write = 1'b1;
                case ({funct7, funct3})
                    10'b0000000_000: alu_op = 4'b0000; // ADD
                    10'b0100000_000: alu_op = 4'b0001; // SUB
                    10'b0000000_111: alu_op = 4'b0010; // AND
                    10'b0000000_110: alu_op = 4'b0011; // OR
                    10'b0000000_100: alu_op = 4'b0100; // XOR
                    10'b0000000_001: alu_op = 4'b0101; // SLL
                    10'b0000000_101: alu_op = 4'b0110; // SRL
                    10'b0100000_101: alu_op = 4'b0111; // SRA
                    10'b0000000_010: alu_op = 4'b1000; // SLT
                    default: alu_op = 4'b0000;
                endcase
            end

            7'b0010011: begin // I-type (inmediatos: ADDI, ANDI, ORI, XORI)
                reg_write = 1'b1;
                case (funct3)
                    3'b000: alu_op = 4'b0000; // ADDI
                    3'b111: alu_op = 4'b0010; // ANDI
                    3'b110: alu_op = 4'b0011; // ORI
                    3'b100: alu_op = 4'b0100; // XORI
                    default: alu_op = 4'b0000;
                endcase
            end

            7'b0000011: begin // LW / LB / LH (Load)
                reg_write  = 1'b1;
                mem_read   = 1'b1;
                mem_to_reg = 1'b1;
                alu_op     = 4'b0000; // dirección = base + offset
            end

            7'b0100011: begin // S-type (Store: SW, SB, SH)
                reg_write  = 1'b0;
                mem_write  = 1'b1;
                alu_op     = 4'b0000; // dirección = base + offset
            end

            default: begin
                alu_op     = 4'b0000;
                reg_write  = 1'b0;
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                mem_to_reg = 1'b0;
            end
        endcase
    end
endmodule
