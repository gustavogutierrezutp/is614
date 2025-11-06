// Módulo para sumador + 4
module sum4(
    input wire [31:0] Asum,   // Entrada de 32 bits
    output wire [31:0] Bsum   // Salida de 32 bits
);

    assign Bsum = Asum + 32'd4; // Sumar 4 a Asum

endmodule