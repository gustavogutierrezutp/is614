module clock_divider (
    input wire clk_in,   // Reloj de entrada (50 MHz)
    output wire clk_out   // Reloj de salida (25 MHz)
);

    // El bit "toggle" para dividir la frecuencia a la mitad
    reg toggle = 0;

    always @(posedge clk_in) begin
        toggle <= ~toggle;  // Cambiar el estado en cada flanco positivo de clk_in
    end

    // El reloj de salida es simplemente el valor de 'toggle'
    assign clk_out = toggle;

endmodule
