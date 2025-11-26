module branch_unit (
    input  wire [31:0] rs1_data,
    input  wire [31:0] rs2_data,
    input  wire [2:0]  branch_type,
    input  wire        branch,
    output reg         branch_taken
);

    wire signed [31:0] signed_rs1 = rs1_data;
    wire signed [31:0] signed_rs2 = rs2_data;

    always @(*) begin
        if (branch) begin
            case (branch_type)
                3'b000: branch_taken = (rs1_data == rs2_data);                    // BEQ
                3'b001: branch_taken = (rs1_data != rs2_data);                    // BNE
                3'b100: branch_taken = (signed_rs1 < signed_rs2);                 // BLT
                3'b101: branch_taken = (signed_rs1 >= signed_rs2);                // BGE
                3'b110: branch_taken = (rs1_data < rs2_data);                     // BLTU
                3'b111: branch_taken = (rs1_data >= rs2_data);                    // BGEU
                default: branch_taken = 1'b0;
            endcase
        end else begin
            branch_taken = 1'b0;
        end
    end

endmodule
