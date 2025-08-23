`timescale 1ns / 1ps

module tb_display_controller;

    // 1. Declarar las señales
    reg  [9:0] test_binary_input;
    reg        test_negate_button;
    wire [9:0] test_led_outputs;
    wire [6:0] segments_d2, segments_d1, segments_d0;

    // 2. Instanciar el DUT
    top_hex_display_controller dut (
        .binary_input(test_binary_input),
        .negate_button(test_negate_button),
        .led_outputs(test_led_outputs),
        // <<-- CAMBIO: Se elimina la conexión a segments_d3 -->>
        .segments_d2(segments_d2),
        .segments_d1(segments_d1),
        .segments_d0(segments_d0)
    );

    // 3. Bloque de estímulos
    initial begin
        $display("Iniciando simulación del controlador de display HEXADECIMAL...");
                $monitor("Tiempo=%0t | Switches: %h | Negar: %b | Valor a mostrar: %h",
                 $time, test_binary_input, test_negate_button, dut.display_value);

        // -- Casos de prueba --

        // Prueba 1: Número simple positivo y luego negativo
        test_binary_input = 10'h00A; // 10 en decimal
        test_negate_button = 1'b0;
        #10;
        test_negate_button = 1'b1; // Debería mostrar 3F6 (complemento a 2 de A)
        #10;

        // Prueba 2: Un número más grande
        test_binary_input = 10'h078; // 120 en decimal
        test_negate_button = 1'b0;
        #10;
        test_negate_button = 1'b1; // Debería mostrar 388 (complemento a 2 de 78)
        #10;
        
        // Prueba 3: Valor cero
        test_binary_input = 10'h000;
        test_negate_button = 1'b0;
        #10;
        test_negate_button = 1'b1; // Debería seguir mostrando 0
        #10;
        
        // Prueba 4: Valor máximo
        test_binary_input = 10'h3FF; // 1023 en decimal
        test_negate_button = 1'b0;
        #10;
        test_negate_button = 1'b1; // Debería mostrar 1
        #10;

        $display("Simulación finalizada.");
        $finish;
    end

endmodule