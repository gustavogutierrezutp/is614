/////////////////////////////////////////////////////////////////////////////////////
////////////// DIEGO AMAYA ////////////// IS614 ////////////// GP. 101 //////////////  
/////////////////////////////////////////////////////////////////////////////////////
module top_level (
	input  logic [9:0] SW, // Switches.
	input  logic KEY0, // Button "The push-button generates a low logic level or high
							 // logic level when it is pressed or not, respectively"".
	output logic [9:0] LEDR, // LEDs.
	output logic [6:0] HEX0, HEX1, HEX2, HEX3 // Displays de 7 segmentos.
	);

	// Enciende respectivamente los LEDs según el estado de los Switches.
	assign LEDR = SW;
	
	// Número extendido a 16 bits (para mostrar en 4 displays).
	logic [15:0] numero_extendido;
	
	// KEY0 (Presionado) = 0, {6'b0, SW}, concatena 6 ceros a la izquierda de SW.
	// KEY0 (No presionado) = 1, { {6{SW[9]} }, SW}, extrae el valor del primer
	//								  dato de la cadena y concatena 6 veces el mismo valor
	//								  a la izquierda de SW.
	assign numero_extendido = (KEY0) ? { {6{SW[9]} }, SW} : {6'b0, SW};
	
	// Divide el número extendido de 16 bits en los 4 displays (c/u con 4 bits).
	assign HEX0 = display_7s(numero_extendido[3:0]);
	assign HEX1 = display_7s(numero_extendido[7:4]);
	assign HEX2 = display_7s(numero_extendido[11:8]);
	assign HEX3 = display_7s(numero_extendido[15:12]);
	
	// Estado de encendido de los leds de los displays según el hexadecimal.
	function automatic logic [6:0] display_7s(input logic [3:0] tipo);
		case (tipo)
			4'h0: display_7s = 7'b1000000; // 0
			4'h1: display_7s = 7'b1111001; // 1
			4'h2: display_7s = 7'b0100100; // 2
			4'h3: display_7s = 7'b0110000; // 3
			4'h4: display_7s = 7'b0011001; // 4
			4'h5: display_7s = 7'b0010010; // 5
			4'h6: display_7s = 7'b0000010; // 6
			4'h7: display_7s = 7'b1111000; // 7
			4'h8: display_7s = 7'b0000000; // 8
			4'h9: display_7s = 7'b0010000; // 9
			4'hA: display_7s = 7'b0001000; // A
			4'hB: display_7s = 7'b0000011; // b
			4'hC: display_7s = 7'b1000110; // C
			4'hD: display_7s = 7'b0100001; // d
			4'hE: display_7s = 7'b0000110; // E
			4'hF: display_7s = 7'b0001110; // F
			default: display_7s = 7'b1111111; // apagado
		endcase
	endfunction
endmodule
