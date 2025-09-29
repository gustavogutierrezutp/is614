module top_level (
	input  logic [9:0] SW,        // switches
	input  logic       KEY0,      // botón
	output logic [6:0] HEX0,      // displays
	output logic [6:0] HEX1,
	output logic [6:0] HEX2
	);

	// Representación interna
	logic signed [9:0] signed_val;   // signed
	logic unsigned [9:0] unsigned_val; // unsigned
	logic signed [11:0] display_val; // extendido a 12 bits para mostrar en HEX

	assign signed_val   = SW;        // interpreta como signed
	assign unsigned_val = SW;        // interpreta como unsigned
	
	always_comb begin
	if (KEY0) 
	  display_val = signed_val;    // KEY0 no presionado → signed
	else 
	  display_val = unsigned_val;  // KEY0 presionado → unsigned
	end
	
	// Dividir en dígitos hexadecimales (12 bits -> 3 dígitos)
	hex_digit d0 ( .value(display_val[3:0]),   .seg(HEX0) );
	hex_digit d1 ( .value(display_val[7:4]),   .seg(HEX1) );
	hex_digit d2 ( .value(display_val[11:8]),  .seg(HEX2) );

endmodule

// Modulo que recibe los 4 bits y devuelve los 6 bits por cada segmento del display a mostrar
module hex_digit (
	input  logic [3:0] value,
	output logic [6:0] seg   // activa en bajo
);

	always_comb begin
		case (value)
			4'h0: seg = 7'b1000000; // 0
			4'h1: seg = 7'b1111001; // 1
			4'h2: seg = 7'b0100100; // 2
			4'h3: seg = 7'b0110000; // 3
			4'h4: seg = 7'b0011001; // 4
			4'h5: seg = 7'b0010010; // 5
			4'h6: seg = 7'b0000010; // 6
			4'h7: seg = 7'b1111000; // 7
			4'h8: seg = 7'b0000000; // 8
			4'h9: seg = 7'b0010000; // 9
			4'hA: seg = 7'b0001000; // A
			4'hB: seg = 7'b0000011; // b
			4'hC: seg = 7'b1000110; // C
			4'hD: seg = 7'b0100001; // d
			4'hE: seg = 7'b0000110; // E
			4'hF: seg = 7'b0001110; // F
			default: seg = 7'b1111111; // apagado
		endcase
	end
endmodule