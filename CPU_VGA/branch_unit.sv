module branch_unit(
    input  wire [31:0] ru_X1,  
    input  wire [31:0] ru_X2,
    input  wire [4:0]  BrOp,    
    output reg         branch_taken
);
    // Codificación de operaciones de salto
    localparam BEQ  = 5'b01000;
    localparam BNE  = 5'b01001;
    localparam BLT  = 5'b01100;
    localparam BGE  = 5'b01101;
    localparam BLTU = 5'b01110;
    localparam BGEU = 5'b01111;

    wire is_equal       = (ru_X1 == ru_X2);
    wire is_not_equal   = (ru_X1 != ru_X2);
    wire is_lt_signed   = ($signed(ru_X1) <  $signed(ru_X2));
    wire is_ge_signed   = ($signed(ru_X1) >= $signed(ru_X2));
    wire is_lt_unsigned = (ru_X1 <  ru_X2);
    wire is_ge_unsigned = (ru_X1 >= ru_X2);

    always @(*) begin
        case (BrOp)
            BEQ:  branch_taken = is_equal;
            BNE:  branch_taken = is_not_equal;
            BLT:  branch_taken = is_lt_signed;
            BGE:  branch_taken = is_ge_signed;
            BLTU: branch_taken = is_lt_unsigned;
            BGEU: branch_taken = is_ge_unsigned;
            default: branch_taken = 1'b0;
        endcase
    end
endmodule