`timescale 1ns/1ps

module tb_top_level;

  // Señales de prueba
  logic [9:0] SW;
  logic KEY0;
  logic [6:0] HEX0, HEX1, HEX2;

  // Instancia del DUT
  top_level dut (
		.SW(SW),
		.KEY0(KEY0),
		.HEX0(HEX0),
		.HEX1(HEX1), 
		.HEX2(HEX2)
	);

  // Bloque inicial: estímulos de prueba
	initial begin
		// Caso 1: unsigned, Dec: 1023 -> HEX: 3FF
		KEY0 = 0; SW = 10'b1111111111; #10;
		$display("Unsigned: SW=%b => muestra 3FF", SW);

		// Caso 2: signed, Dec: -1 -> HEX: FFF
		KEY0 = 1; SW = 10'b1111111111; #10;
		$display("Signed: SW=%b => muestra FFF (=-1)", SW);

		// Caso 3: signed negativo grande, Dec: -512, HEX: 200
		KEY0 = 1; SW = 10'b1000000000; #10;
		$display("Signed: SW=%b => muestra 200 (=-512)", SW);
		
		// Caso 4: unsigned pequeño, Dec: 1 -> HEX: 001
		KEY0 = 0; SW = 10'b0000000001; #10;
		$display("Unsigned: SW=%b => muestra 001", SW);

		// Caso 5: signed pequeño positivo, Dec: 1 -> HEX: 001
		KEY0 = 1; SW = 10'b0000000001; #10;
		$display("Signed: SW=%b => muestra 001 (+1)", SW);

		// Caso 6: signed pequeño negativo, Dec: -3 -> HEX: FFD
		KEY0 = 1; SW = 10'b1111111101; #10;
		$display("Signed: SW=%b => muestra FFD (=-3)", SW);

		$finish;
	end

endmodule

