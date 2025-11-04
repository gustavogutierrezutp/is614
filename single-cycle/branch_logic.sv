// branch_logic.sv
// Compara rs1 y rs2 para decidir si se debe tomar un salto.
module branch_logic (
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    input  logic [2:0]  funct3,     // Indica el tipo de salto
    
    output logic        branch_taken
);

    // Definiciones de funct3 para B-Type
    localparam BEQ  = 3'b000;
    localparam BNE  = 3'b001;
    localparam BLT  = 3'b100;
    localparam BGE  = 3'b101;
    localparam BLTU = 3'b110;
    localparam BGEU = 3'b111;

    always_comb begin
        branch_taken = 1'b0; // Por defecto, no saltar
        case (funct3)
            BEQ:  if (rs1_data == rs2_data) branch_taken = 1'b1;
            BNE:  if (rs1_data != rs2_data) branch_taken = 1'b1;
            BLT:  if ($signed(rs1_data) < $signed(rs2_data)) branch_taken = 1'b1;
            BGE:  if ($signed(rs1_data) >= $signed(rs2_data)) branch_taken = 1'b1;
            BLTU: if (rs1_data < rs2_data) branch_taken = 1'b1;
            BGEU: if (rs1_data >= rs2_data) branch_taken = 1'b1;
            default: ;
        endcase
    end

endmodule