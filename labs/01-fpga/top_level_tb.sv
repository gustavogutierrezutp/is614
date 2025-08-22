`timescale 1ns/1ps

module top_level_tb;

    // Entradas
    reg  [9:0] SW;
    reg        KEY0;

    // Salidas
    wire [6:0] HEX0, HEX1, HEX2, HEX3;

    // Instanciar el DUT (Device Under Test)
    top_level dut (
        .SW(SW),
        .KEY0(KEY0),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3)
    );

    // Procedimiento de prueba
    initial begin
        $dumpfile("top_level_tb.vcd");
        $dumpvars(0, top_level_tb);

        // Caso 1: unsigned, valor pequeño
        SW   = 10'b0000001010; // decimal 10
        KEY0 = 1;              // unsigned
        #10;
        $display("Unsigned 10 -> HEX: %b %b %b %b", HEX3, HEX2, HEX1, HEX0);

        // Caso 2: signed positivo
        SW   = 10'b0000001010; // decimal 10
        KEY0 = 0;              // signed
        #10;
        $display("Signed +10 -> HEX: %b %b %b %b", HEX3, HEX2, HEX1, HEX0);

        // Caso 3: signed negativo
        SW   = 10'b1111110110; // -10 en 2C (10 bits)
        KEY0 = 0;              // signed
        #10;
        $display("Signed -10 -> HEX: %b %b %b %b", HEX3, HEX2, HEX1, HEX0);

        // Caso 4: unsigned max (1023)
        SW   = 10'b1111111111; // 1023
        KEY0 = 1;              // unsigned
        #10;
        $display("Unsigned 1023 -> HEX: %b %b %b %b", HEX3, HEX2, HEX1, HEX0);

        // Caso 5: signed min (-512)
        SW   = 10'b1000000000; // -512
        KEY0 = 0;              // signed
        #10;
        $display("Signed -512 -> HEX: %b %b %b %b", HEX3, HEX2, HEX1, HEX0);

        $finish;
    end

endmodule
