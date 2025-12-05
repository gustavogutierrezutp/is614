module IFID(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        stall,
    input  logic        flush,
    
    // Entradas desde IF
    input  logic [31:0] pc_in,
    input  logic [31:0] pc_plus_4_in,
    input  logic [31:0] instruction_in,
    
    // Salidas hacia ID
    output logic [31:0] pc_out,
    output logic [31:0] pc_plus_4_out,
    output logic [31:0] instruction_out
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_out <= 32'b0;
            pc_plus_4_out <= 32'b0;
            instruction_out <= 32'b0; 
        end
        else if (flush) begin
            pc_out <= 32'b0;
            pc_plus_4_out <= 32'b0;
            instruction_out <= 32'b0;  // NOP
        end
        else if (!stall) begin
            pc_out <= pc_in;
            pc_plus_4_out <= pc_plus_4_in;
            instruction_out <= instruction_in;
        end
        // Si stall=1, mantiene valores
    end

endmodule