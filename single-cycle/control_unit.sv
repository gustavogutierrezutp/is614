module control_unit (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    
    output logic       alu_b_src,
    output logic [3:0] alu_op,
    output logic       mem_read,
    output logic       mem_write,
    output logic       reg_write,
    output logic       mem_to_reg
);

    localparam OP_R_TYPE   = 7'b0110011;
    localparam OP_I_TYPE   = 7'b0010011;
    localparam OP_LOAD     = 7'b0000011;
    localparam OP_STORE    = 7'b0100011;

    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_SLL  = 4'b0010;
    localparam ALU_SLT  = 4'b0011;
    localparam ALU_SLTU = 4'b0100;
    localparam ALU_XOR  = 4'b0101;
    localparam ALU_SRL  = 4'b0110;
    localparam ALU_SRA  = 4'b0111;
    localparam ALU_OR   = 4'b1000;
    localparam ALU_AND  = 4'b1001;

    always_comb begin
        alu_b_src  = 1'b0;
        alu_op     = 4'bxxxx;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        reg_write  = 1'b0;
        mem_to_reg = 1'b0;
        
        case (opcode)
            OP_R_TYPE: begin
                reg_write = 1'b1;
                alu_b_src = 1'b0;
                case (funct3)
                    3'b000: alu_op = (funct7 == 7'b0100000) ? ALU_SUB : ALU_ADD;
                    3'b001: alu_op = ALU_SLL;
                    3'b010: alu_op = ALU_SLT;
                    3'b011: alu_op = ALU_SLTU;
                    3'b100: alu_op = ALU_XOR;
                    3'b101: alu_op = (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL;
                    3'b110: alu_op = ALU_OR;
                    3'b111: alu_op = ALU_AND;
                    default: ;
                endcase
            end
            
            OP_I_TYPE: begin
                reg_write = 1'b1;
                alu_b_src = 1'b1;
                case (funct3)
                    3'b000: alu_op = ALU_ADD;
                    3'b001: alu_op = ALU_SLL;
                    3'b010: alu_op = ALU_SLT;
                    3'b011: alu_op = ALU_SLTU;
                    3'b100: alu_op = ALU_XOR;
                    3'b101: alu_op = (funct7 == 7'b0100000) ? ALU_SRA : ALU_SRL;
                    3'b110: alu_op = ALU_OR;
                    3'b111: alu_op = ALU_AND;
                    default: ;
                endcase
            end

            OP_LOAD: begin
                reg_write  = 1'b1;
                alu_b_src  = 1'b1;
                alu_op     = ALU_ADD;
                mem_read   = 1'b1;
                mem_to_reg = 1'b1;
            end

            OP_STORE: begin
                reg_write = 1'b0;
                alu_b_src = 1'b1;
                alu_op    = ALU_ADD;
                mem_write = 1'b1;
            end
            
            default: ;
        endcase
    end
endmodule