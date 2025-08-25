`timescale 1ns/1ps

module tb_top_level;

  // Señales de prueba
  logic [9:0] switch;   // entrada simulada
  logic [9:0] led;      // salida observada

  // Instancia del DUT
  top_level uut (
    .led(led),
    .switch(switch)
  );

  // Bloque inicial: estímulos de prueba
  initial begin
		// Caso 1: todos en 0
		switch = 10'b0000000000;
		#10;

		// Caso 2: uno en 1 (bit 0)
		switch = 10'b0000000001;
		#10;

		// Caso 3: uno en 1 (bit 9)
		switch = 10'b1000000000;
		#10;

		// Caso 4: todos en 1
		switch = 10'b1111111111;
		#10;

		// Caso 5: prueba con un patrón intermedio
		switch = 10'b1010101010;
		#10 $finish;
	end

endmodule

