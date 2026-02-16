`timescale 1ns/1ps   // Escala de tiempo: unidad = 1ns, precisión = 1ps

module top_level_tb;

    // Declaración de señales internas que conectarán con el DUT
    logic [3:0] SW;     // Entradas simuladas (representan los switches)
    logic [6:0] HEX0;   // Salida del display de 7 segmentos

    // Instancia del diseño a probar (DUT = Device Under Test)
    top_level dut (
        .SW(SW),
        .HEX0(HEX0)
    );

    // Bloque inicial: se ejecuta una sola vez al arrancar la simulación
    initial begin
        $display("==== INICIO DE SIMULACION HEX DISPLAY ====");

        // Recorremos los 16 valores posibles de un número de 4 bits
        for (int valor = 0; valor < 16; valor++) begin
            SW = valor;         // Asignamos valor al switch
            #10;                // Esperamos 10ns para que se propague
            $display("Tiempo = %0t | SW = %h | HEX0 = %b", 
                      $time, SW, HEX0);
        end

        $display("==== FIN DE SIMULACION ====");
        $stop;  // Finalizamos la simulación
    end

endmodule