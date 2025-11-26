/*
 * ============================================================
 * Módulo: vga_controller_1280x800
 * ============================================================
 */

module vga_controller_1280x800 (

    input  logic        clk,      // Reloj de píxel (Pixel Clock) específico para esta resolución
    input  logic        reset,    // Reset del sistema
    output logic        hsync,    // Señal de Sincronización Horizontal
    output logic        vsync,    // Señal de Sincronización Vertical
    output logic [10:0] hcount,   // Contador de Píxeles (Coordenada X)
    output logic [9:0]  vcount,   // Contador de Líneas (Coordenada Y)
    output logic        video_on  // 1: Área visible (dibujar), 0: Área de borrado (negro)
	 
);

    // ============================================================
    // Parámetros de Temporización VGA (1280x800 @ 60Hz)
    // ============================================================
    
    // Parámetros Horizontales (Total = 1440 clocks)
    localparam int H_VISIBLE = 1280; // Píxeles visibles por línea
    localparam int H_FP      = 48;   // Front Porch: Espera antes del pulso sync
    localparam int H_SYNC    = 32;   // Sync Pulse: Pulso de sincronización
    localparam int H_BP      = 80;   // Back Porch: Espera después del pulso sync
    localparam int H_TOTAL   = H_VISIBLE + H_FP + H_SYNC + H_BP;

    // Parámetros Verticales (Total = 831 líneas)
    localparam int V_VISIBLE = 800;  // Líneas visibles por cuadro
    localparam int V_FP      = 3;    // Front Porch vertical
    localparam int V_SYNC    = 6;    // Sync Pulse vertical
    localparam int V_BP      = 22;   // Back Porch vertical
    localparam int V_TOTAL   = V_VISIBLE + V_FP + V_SYNC + V_BP;

    // ============================================================
    // Lógica de Contadores (Escaneo de barrido)
    // ============================================================
    
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            hcount <= 11'd0;
            vcount <= 10'd0;
        end else begin
            // Control Horizontal
            if (hcount == H_TOTAL - 1) begin
                hcount <= 0; 
                
                // Control Vertical (Solo avanza cuando termina una línea horizontal)
                if (vcount == V_TOTAL - 1)
                    vcount <= 0; 
                else
                    vcount <= vcount + 1;
            end else begin
                hcount <= hcount + 1; // Avanzar al siguiente píxel
            end
        end
    end

    // ============================================================
    // Generación de Señales de Salida
    // ============================================================

    assign hsync = (hcount >= H_VISIBLE + H_FP) && 
                   (hcount <  H_VISIBLE + H_FP + H_SYNC);

    assign vsync = (vcount >= V_VISIBLE + V_FP) && 
                   (vcount <  V_VISIBLE + V_FP + V_SYNC);

    assign video_on = (hcount < H_VISIBLE) && (vcount < V_VISIBLE);

endmodule