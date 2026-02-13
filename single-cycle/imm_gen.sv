module imm_gen (
    input  logic [31:0] instruction,
    input  logic [6:0]  opcode,
    output logic [31:0] imm_out
);

    localparam OP_I_TYPE   = 7'b0010011;
    localparam OP_LOAD     = 7'b0000011;
    localparam OP_STORE    = 7'b0100011;
    localparam OP_JALR     = 7'b1100111;

    logic [31:0] imm_i, imm_s;

    assign imm_i = {{20{instruction[31]}}, instruction[31:20]};
    
    assign imm_s = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
    
    always_comb begin
        case (opcode)
            OP_I_TYPE: imm_out = imm_i;
            OP_LOAD:   imm_out = imm_i;
            OP_JALR:   imm_out = imm_i;
            OP_STORE:  imm_out = imm_s;
            default:   imm_out = 32'hxxxxxxxx;
        endcase
    end

endmodule