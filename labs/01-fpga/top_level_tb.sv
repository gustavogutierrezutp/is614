`timescale 1ns/1ps

module top_level_tb;

    // Entradas y salidas
    logic [9:0] SW;
    logic       KEY0;
    logic [9:0] LED;
    logic [6:0] HEX0, HEX1, HEX2;

    // Instancia del DUT
    top_level dut (
        .SW(SW),
        .KEY0(KEY0),
        .LED(LED),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2)
    );

    // Tarea para imprimir resultados
    task print_result(input int value, input string mode);
        $display("[%s] SW = %4d (%b) => HEX2=%b HEX1=%b HEX0=%b",
                  mode, value, SW, HEX2, HEX1, HEX0);
    endtask

    initial begin
        // ======================
        // PRUEBAS EN COMPLEMENTO A2 (KEY0=0)
        // ======================
        KEY0 = 0;

        // Caso 1: 0
		SW = 10'b0000000000; #10;
	    print_result(0, "A2");
 
		// Caso 2: 10
		SW = 10'b0000001010; #10;
		print_result(10, "A2");

		// Caso 3: -512 (1000000000 en A2)
		SW = 10'b1000000000; #10;
		print_result(-512, "A2");

		// Caso 4: -1 (1111111111 en A2)
		SW = 10'b1111111111; #10;
		print_result(-1, "A2");

		// Caso 5: 255
		SW = 10'b0011111111; #10;
		print_result(255, "A2");

		// Ahora en unsigned
		KEY0 = 1;

		// Caso 6: 512
		SW = 10'b1000000000; #10;
		print_result(512, "UNSIGNED");

		// Caso 7: 1023
		SW = 10'b1111111111; #10;
		print_result(1023, "UNSIGNED");


        $finish;
    end

endmodule
