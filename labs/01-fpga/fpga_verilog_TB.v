`timescale 1ns/1ps

module fpga_verilog_TB;

    // Entradas
    reg  [9:0] SW;
    reg        KEY0;

    // Salidas
    wire [9:0] LEDR;
    wire [6:0] HEX0, HEX1, HEX2, HEX3;

    // Instancia del DUT (Device Under Test)
    fpga_verilog dut (
        .SW(SW),
        .KEY0(KEY0),
        .LEDR(LEDR),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3)
    );

    // Procedimiento de prueba
    initial begin
        $display("Tiempo | KEY0 | SW(bin)   | LEDR(bin) | HEX3 HEX2 HEX1 HEX0");
        $monitor("%4dns | %b    | %b | %b | %b %b %b %b",
                 $time, KEY0, SW, LEDR, HEX3, HEX2, HEX1, HEX0);

        // Caso 1: Modo con signo (KEY0=0)
        KEY0 = 0;
        SW   = 10'b0000000111; #10;   //  +7
        SW   = 10'b1111111001; #10;   //  -7 en complemento a 2
        SW   = 10'b0111111111; #10;   //  +511

        // Caso 2: Modo sin signo (KEY0=1)
        KEY0 = 1;
        SW   = 10'b0000000111; #10;   //  7
        SW   = 10'b1111111001; #10;   //  1001 decimal ( = 1001 )
        SW   = 10'b1111111111; #10;   //  1023

        $finish;
    end

endmodule
