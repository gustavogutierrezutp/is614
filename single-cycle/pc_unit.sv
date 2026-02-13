// pc_unit.sv


module pc_unit (
    input  logic        clk,
    input  logic        rst_n,    // Reset activo-bajo (n = not)
    output logic [31:0] pc_addr
);

    // Lógica de reset asíncrona
    // (Esta es la sintaxis moderna de SystemVerilog para el "always @(posedge clk or negedge rst_n)" del profesor)
    
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin // Si el reset se activa (es 0)
            pc_addr <= 32'b0;
        end else begin
            pc_addr <= pc_addr + 4; // Avanza en cada pulso de reloj
        end
    end

endmodule