module control_unit(
    input wire [31:0] instruction,
    output reg reg_write,
    output reg alu_src,
    output reg mem_write,
    output reg mem_read,
    output reg mem_to_reg,
    output reg [3:0] alu_control
);

    localparam TIPO_R = 7'b0110011;
    localparam TIPO_I = 7'b0010011;
    localparam CARGA  = 7'b0000011;
    localparam STORE  = 7'b0100011;
    
    wire [6:0] opcode = instruction[6:0];
    wire [2:0] funct3 = instruction[14:12];
    wire bit_funct7 = instruction[30];
    
    always @(*) begin
        reg_write = 1'b0;
        alu_src = 1'b0;
        mem_write = 1'b0;
        mem_read = 1'b0;
        mem_to_reg = 1'b0;
        alu_control = 4'b0000;
        
        case (opcode)
            TIPO_R: begin
                reg_write = 1'b1;
                alu_src = 1'b0;
                case (funct3)
                    3'b000: alu_control = bit_funct7 ? 4'b0001 : 4'b0000;
                    3'b111: alu_control = 4'b0010;
                    3'b110: alu_control = 4'b0011;
                    3'b100: alu_control = 4'b0100;
                    3'b001: alu_control = 4'b0101;
                    3'b101: alu_control = bit_funct7 ? 4'b0111 : 4'b0110;
                    3'b010: alu_control = 4'b1000;
                    3'b011: alu_control = 4'b1001;
                    default: alu_control = 4'b0000;
                endcase
            end
            
            TIPO_I: begin
                reg_write = 1'b1;
                alu_src = 1'b1;
                case (funct3)
                    3'b000: alu_control = 4'b0000;
                    3'b111: alu_control = 4'b0010;
                    3'b110: alu_control = 4'b0011;
                    3'b100: alu_control = 4'b0100;
                    3'b001: alu_control = 4'b0101;
                    3'b101: alu_control = bit_funct7 ? 4'b0111 : 4'b0110;
                    3'b010: alu_control = 4'b1000;
                    3'b011: alu_control = 4'b1001;
                    default: alu_control = 4'b0000;
                endcase
            end
            
            CARGA: begin
                reg_write = 1'b1;
                alu_src = 1'b1;
                mem_read = 1'b1;
                mem_to_reg = 1'b1;
                alu_control = 4'b0000;
            end
            
            STORE: begin
                reg_write = 1'b0;
                alu_src = 1'b1;
                mem_write = 1'b1;
                alu_control = 4'b0000;
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