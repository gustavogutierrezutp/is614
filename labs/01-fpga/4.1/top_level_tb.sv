`timescale 1ns/1ps

module top_level_tb;

    logic [9:0] SW;
    logic [9:0] LEDR;

    // Instancia del DUT
    top_level dut (
        .SW(SW),
        .LEDR(LEDR)
    );

    initial begin
        $display("Testbench - LED Reflection");
        
        // Caso 1: Todos en 0
        SW = 10'b0000000000;
        #10;
        $display("SW = %b, LEDR = %b", SW, LEDR);

        // Caso 2: Un solo switch encendido
        SW = 10'b0000000001;
        #10;
        $display("SW = %b, LEDR = %b", SW, LEDR);

        // Caso 3: Alternados
        SW = 10'b1010101010;
        #10;
        $display("SW = %b, LEDR = %b", SW, LEDR);

        // Caso 4: Todos encendidos
        SW = 10'b1111111111;
        #10;
        $display("SW = %b, LEDR = %b", SW, LEDR);

        $stop;
    end

endmodule