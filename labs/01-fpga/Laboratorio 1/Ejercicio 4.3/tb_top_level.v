`timescale 1ns/1ps

module tb_top_level;

    // Declaración de señales para testbench
    reg [9:0] SW;             // Entrada de switches
    wire [6:0] HEX0, HEX1, HEX2; // Salidas de los displays de 7 segmentos

    // Instancia del módulo a probar
    top_level uut (
        .SW(SW),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2)
    );

    initial begin
        // Inicialización
        SW = 10'b0000000000;
        #10;

        // Prueba diferentes valores para SW y espera 10 unidades de tiempo entre cambios
        SW = 10'b0000000001;  // 1 decimal
        #10;

        SW = 10'b0000001111;  // 15 decimal (0xF)
        #10;

        SW = 10'b0011001100;  // 204 decimal (0xCC)
        #10;

        SW = 10'b1111111111;  // 1023 decimal (0x3FF)
        #10;

        SW = 10'b0101010101;  // patrón alterno
        #10;

        $stop;  // detener simulación
    end

endmodule
