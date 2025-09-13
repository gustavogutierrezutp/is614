`timescale 1ns/1ps

module top_level_tb;
	////////////////////////////////////////////////////////////////////////////////
	// DATOS NECESARIOS DEL TB PARA LLAMAR EL MODULO TOP_LEVEL Y ASÍ, PODER TESTEAR:
	logic [9:0] SW;
	logic KEY0;
	logic [9:0] LEDR;
	logic [6:0] HEX0, HEX1, HEX2, HEX3;
	
	top_level dut (
		.SW(SW),
		.KEY0(KEY0),
		.LEDR(LEDR),
		.HEX0(HEX0),
		.HEX1(HEX1),
		.HEX2(HEX2),
		.HEX3(HEX3)
	);
	////////////////////////////////////////////////////////////////////////////////
	initial begin
	// Tener presente que modelsim muestra por HEX el binario de encendido y apago de
	// los LEDs y no el valor HEX que desea mostrar.
	// Casos de prueba:
	SW = 10'b0000000000;
	KEY0 = 0; #10; // Hex: 0000 ; Dec: 0
	KEY0 = 1; #10; // Hex: 0000 ; Dec: 0

	SW = 10'b0000000001;
	KEY0 = 0; #10; // Hex: 0001 ; Dec: 1
	KEY0 = 1; #10; // Hex: 0001 ; Dec: 1

	SW = 10'b0111111111;
	KEY0 = 0; #10; // Hex: 01FF ; Dec: 511
	KEY0 = 1; #10; // Hex: 01FF ; Dec: 511

	SW = 10'b1000000000;
	KEY0 = 0; #10; // Hex: 0200 ; Dec: 512
	KEY0 = 1; #10; // Hex: FE00 ; Dec: -512

	SW = 10'b1000000001;
	KEY0 = 0; #10; // Hex: 0201 ; Dec: 513
	KEY0 = 1; #10; // Hex: FE01 ; Dec: -511

	SW = 10'b1111111110;
	KEY0 = 0; #10; // Hex: 03FE ; Dec: 1022
	KEY0 = 1; #10; // Hex: FFFE ; Dec: -2

	SW = 10'b1111111111;
	KEY0 = 0; #10; // Hex: 03FF ; Dec: 1023
	KEY0 = 1; #10; // Hex: FFFF ; Dec: -1
	
	$stop; // Dentiene la prueba.
	end
endmodule