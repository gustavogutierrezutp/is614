// Programa sencillo: Los switches controlan los LEDs
module top_level (
    input  [9:0] SW,    // 10 switches de entrada
    output [9:0] LEDR   // 10 LEDs de salida
);

    // Asignación directa: cada switch controla un LED
    assign LEDR = SW;

endmodule
