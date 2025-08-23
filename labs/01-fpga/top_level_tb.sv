`timescale 1ns/1ps

module top_level_tb;

    // Entradas y salidas
    logic [9:0] SW;
    logic       KEY0;
    logic [9:0] LED;
    logic [6:0] HEX0, HEX1, HEX2, HEX3;

    // Instancia del DUT
    top_level dut (
        .SW(SW),
        .KEY0(KEY0),
        .LED(LED),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3)
    );

    // Tarea para imprimir resultados solo en binario
    task print_result(input string mode);
        $display("[%s] SW=%b => HEX3=%b HEX2=%b HEX1=%b HEX0=%b",
                  mode, SW,
                  HEX3,
                  HEX2,
                  HEX1,
                  HEX0);
    endtask

    initial begin
        KEY0 = 0;

        SW = 10'b0000000000; #10; print_result("A2");   // 0
        SW = 10'b0000001010; #10; print_result("A2");   // 10
        SW = 10'b1000000000; #10; print_result("A2");   // -512
        SW = 10'b1111111111; #10; print_result("A2");   // -1
        SW = 10'b0011111111; #10; print_result("A2");   // 255

        KEY0 = 1;
        SW = 10'b1000000000; #10; print_result("UNSIGNED"); // 512
        SW = 10'b1111111111; #10; print_result("UNSIGNED"); // 1023
        SW = 10'b0000000000; #10; print_result("UNSIGNED"); // 0

        $finish;
    end

endmodule
