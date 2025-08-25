`timescale 1ns/1ps

module tb_top_level;

  // Señales de prueba
  logic [9:0] SW;
  logic [6:0] HEX0, HEX1, HEX2;

  // Instancia del DUT
  top_level dut (
		.SW(SW),
		.HEX0(HEX0),
		.HEX1(HEX1),
		.HEX2(HEX2)
	);

  // Bloque inicial: estímulos de prueba
  initial begin
		// Probar algunos valores representativos
		SW = 10'b0000000000; #10;  // 0
		SW = 10'b0000001111; #10;  // 15 decimal -> 00F
		SW = 10'b0000111111; #10;  // 63 decimal -> 03F
		SW = 10'b1111111111; #10;  // 1023 decimal -> 3FF

		$finish;
  end

endmodule

