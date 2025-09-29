`timescale 1ns/1ps

module tb_display;

    reg [9:0] SW;        // switches simulados
	 reg [1:0] KEY;
    wire [6:0] HEX0, HEX1, HEX2;

    // Instancia del DUT (Device Under Test)
    Ejercicio uut (
        .SW(SW),
		  .KEY(KEY),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2)
    );

     initial begin

        // Caso 1: Número original (KEY[0]=1, KEY[1]=1)
        SW  = 10'b0000001101; // = 13 decimal
        KEY = 2'b11;          // sin transformación
        #10;

        // Caso 2: Complemento a 1 (activar KEY[0])
        KEY = 2'b10;  // KEY[0]=0 → complemento a 1
        #10;

        // Caso 3: Complemento a 2 (activar KEY[1])
        KEY = 2'b01;  // KEY[1]=0 → complemento a 2
        #10;

        // Caso 4: Otro valor en SW
        SW  = 10'b1111111111; // 1023 decimal
        KEY = 2'b11;          // número original
        #10;

        KEY = 2'b10;          // complemento a 1
        #10;

        KEY = 2'b01;          // complemento a 2
        #10;

        // Finaliza simulación
        $finish;
    end

endmodule
