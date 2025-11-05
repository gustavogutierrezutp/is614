module pc (
    input  logic        clk,
    input  logic        rst,        // reset activo en alto (más común en RISC-V)
    input  logic [31:0] next_pc,    // dirección siguiente
    output logic [31:0] pc_out      // dirección actual
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            pc_out <= 32'b0;         // PC se reinicia a 0
        else
            pc_out <= next_pc;       // Actualiza PC
    end

endmodule
