`timescale 1ns/1ps   // Escala de tiempo: 1 ns de simulación = 1 paso, precisión en ps

module tb_top_level;

    // Señales de prueba
    reg  [3:0] SW;       // Entradas simuladas (switches)
    wire [6:0] HEX0;     // Salida del módulo (display 7 segmentos)

    // Instanciamos el módulo bajo prueba (UUT = Unit Under Test)
    top_level uut (
        .SW(SW),
        .HEX0(HEX0)
    );

    // Bloque inicial de estimulación
    initial begin
        // Encabezado para ver en la consola
        $display("Tiempo | SW (bin) | SW (hex) | HEX0 (7 segmentos activo-bajo)");

        // Monitor en tiempo real: imprime cada vez que cambia algo
        $monitor("%4t   |   %b   |   %h   |   %b", $time, SW, SW, HEX0);

        // Recorremos todos los valores posibles de SW (0 a 15)
        SW = 4'b0000; #10;   // Esperamos 10 ns
        SW = 4'b0001; #10;
        SW = 4'b0010; #10;
        SW = 4'b0011; #10;
        SW = 4'b0100; #10;
        SW = 4'b0101; #10;
        SW = 4'b0110; #10;
        SW = 4'b0111; #10;
        SW = 4'b1000; #10;
        SW = 4'b1001; #10;
        SW = 4'b1010; #10;
        SW = 4'b1011; #10;
        SW = 4'b1100; #10;
        SW = 4'b1101; #10;
        SW = 4'b1110; #10;
        SW = 4'b1111; #10;

        // Terminamos la simulación
        $stop;
    end

endmodule