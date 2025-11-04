module display_selector (
    input  logic [2:0]  sel,
    input  logic [31:0] pc_in,
    input  logic [31:0] instr_in,
    input  logic [31:0] wdata_in,
    input  logic [31:0] rs1_in,
    input  logic [31:0] rs2_in,
    input  logic [31:0] imm_in,
    input  logic [31:0] alu_in,
    input  logic [31:0] mem_in,
    output logic [31:0] data_out
);

    always_comb begin
        case (sel)
            3'b000: data_out = pc_in;
            3'b001: data_out = instr_in;
            3'b010: data_out = wdata_in;
            3'b011: data_out = rs1_in;
            3'b100: data_out = rs2_in;
            3'b101: data_out = imm_in;
            3'b110: data_out = alu_in;
            3'b111: data_out = mem_in;
            default: data_out = 32'hDEADBEEF;
        endcase
    end

endmodule