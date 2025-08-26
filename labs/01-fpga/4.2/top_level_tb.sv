`timescale 1ns/1ps

module top_level_tb;

    logic [3:0] SW;
    logic [6:0] HEX0;

    // Instancia del DUT
    top_level dut (
        .SW(SW),
        .HEX0(HEX0)
    );

    initial begin
        $display("Testbench - HEX Display");

        // Probar todos los valores de 0 a F
        for (int i = 0; i < 16; i++) begin
            SW = i;
            #10;
            $display("SW = %h, HEX0 = %b", SW, HEX0);
        end

        $stop;
    end

endmodule
