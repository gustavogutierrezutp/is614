// Program Counter
module pc (
    input  logic clk, // Señal de reloj
    input  logic reset, // Reinicio del PC
    input  logic [31:0] pc_next, // Próxima dirección de instrucción
    output logic [31:0] pc // Dirección actual
);
    // Logica del Program Counter
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'h00000000; // Reinicia PC a 0
        else
            pc <= pc_next; // Actualiza PC con la nueva dirección
    end

endmodule
