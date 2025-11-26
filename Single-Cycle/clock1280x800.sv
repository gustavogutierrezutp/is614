/*
 * Módulo: clock1280x800
 * Descripción:
 *   Este módulo se encarga de generar la señal de reloj específica (Pixel Clock)
 *   necesaria para manejar una resolución VGA de 1280x800.
 */

module clock1280x800 (

    input  logic clock50,   // Reloj base de entrada de la FPGA (50 MHz)
    input  logic reset,     // Señal de reset del sistema
    output logic vgaclk     // Reloj de píxel generado para el controlador VGA
	 
);

    // Señal interna para capturar la salida de reset del PLL
    logic unused_reset;

    // -------------------------------------------------------------------------
    // Instancia del IP de PLL 
    // -------------------------------------------------------------------------
    
    vgaClock clk_pll_inst (
        .ref_clk_clk        (clock50),      // Conexión del reloj de referencia (Input)
        .ref_reset_reset    (reset),        // Conexión del reset de referencia (Input)
        .reset_source_reset (unused_reset), // Salida de reset del IP (No usada)
        .vga_clk_clk        (vgaclk)        // Salida del reloj estabilizado (Output)
    );

endmodule