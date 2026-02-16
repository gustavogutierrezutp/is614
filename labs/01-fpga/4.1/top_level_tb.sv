`timescale 1ns/1ps

module tb_top_level;

    // Señales para simular los switches y LEDs
    reg  [9:0] SW;       // entradas (reg en testbench)
    wire [9:0] LEDR;     // salidas (wire)

    // Instancia del módulo bajo prueba (UUT = Unit Under Test)
    top_level uut (
        .SW(SW),
        .LEDR(LEDR)
    );

    // Estímulos de prueba
    initial begin
        // Monitor para ver la simulación en la consola
        $monitor("Tiempo=%0t | SW=%b | LEDR=%b", $time, SW, LEDR);

        // Caso 1: todos apagados
        SW = 10'b0000000000;
        #10;

        // Caso 2: enciendo solo el switch 0
        SW = 10'b0000000001;
        #10;

        // Caso 3: enciendo switch 3
        SW = 10'b0000001000;
        #10;

        // Caso 4: todos encendidos
        SW = 10'b1111111111;
        #10;

        // Caso 5: valor intermedio
        SW = 10'b1010101010;
        #10;

        // Fin de simulación
        $stop;
    end

endmodule
