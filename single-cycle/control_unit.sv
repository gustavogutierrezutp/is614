module control_unit(
    input wire [31:0] instruction,
    output reg reg_write,
    output reg alu_src,
    output reg mem_write,
    output reg mem_read,
    output reg mem_to_reg,
    output reg [3:0] alu_control
);
    localparam R_TYPE = 7'b0110011;
    localparam I_TYPE = 7'b0010011;
    localparam LOAD   = 7'b0000011;
    localparam STORE  = 7'b0100011;
    
    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire funct7_bit = instruction[30];
    
    always @(*) begin
        // Valores por defecto
        reg_write = 1'b0;
        alu_src = 1'b0;
        mem_write = 1'b0;
        mem_read = 1'b0;
        mem_to_reg = 1'b0;
        alu_control = 4'b0000;
        
        case (opcode)
            R_TYPE: begin
                reg_write = 1'b1;
                alu_src = 1'b0;
                case (funct3)
                    3'b000: alu_control = funct7_bit ? 4'b0001 : 4'b0000; // SUB : ADD
                    3'b111: alu_control = 4'b0010; // AND
                    3'b110: alu_control = 4'b0011; // OR
                    3'b100: alu_control = 4'b0100; // XOR
                    3'b001: alu_control = 4'b0101; // SLL
                    3'b101: alu_control = funct7_bit ? 4'b0111 : 4'b0110; // SRA : SRL
                    3'b010: alu_control = 4'b1000; // SLT
                    3'b011: alu_control = 4'b1001; // SLTU
                    default: alu_control = 4'b0000;
                endcase
            end
            
            I_TYPE: begin
                reg_write = 1'b1;
                alu_src = 1'b1;
                case (funct3)
                    3'b000: alu_control = 4'b0000; // ADDI
                    3'b111: alu_control = 4'b0010; // ANDI
                    3'b110: alu_control = 4'b0011; // ORI
                    3'b100: alu_control = 4'b0100; // XORI
                    3'b001: alu_control = 4'b0101; // SLLI
                    3'b101: alu_control = funct7_bit ? 4'b0111 : 4'b0110; // SRAI : SRLI
                    3'b010: alu_control = 4'b1000; // SLTI
                    3'b011: alu_control = 4'b1001; // SLTIU
                    default: alu_control = 4'b0000;
                endcase
            end
            
            LOAD: begin
                reg_write = 1'b1;
                alu_src = 1'b1;
                mem_read = 1'b1;
                mem_to_reg = 1'b1;
                alu_control = 4'b0000; // ADD para calcular dirección
            end
            
            STORE: begin
                reg_write = 1'b0;
                alu_src = 1'b1;
                mem_write = 1'b1;
                alu_control = 4'b0000; // ADD para calcular dirección
            end
            
            default: begin
                reg_write = 1'b0;
                alu_src = 1'b0;
                mem_write = 1'b0;
                mem_read = 1'b0;
                mem_to_reg = 1'b0;
                alu_control = 4'b0000;
            end
        endcase
    end
endmodule