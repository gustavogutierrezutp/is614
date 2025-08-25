module top_level (
	input  logic [9:0] SW,        // 10 switches
	output logic [6:0] HEX0,      // dígito menos significativo
	output logic [6:0] HEX1,      // dígito intermedio
	output logic [6:0] HEX2       // dígito más significativo (solo 2 bits útiles)
);

	// Agrupamos los switches en un vector de 12 bits (relleno con 0 arriba)
	logic [11:0] value;
	assign value = {2'b00, SW};   // 2 ceros + 10 bits de switches
	
	// Instancias de los tres dígitos hexadecimales
	hex_digit d0 ( .value(value[3:0]),   .seg(HEX0) );
	hex_digit d1 ( .value(value[7:4]),   .seg(HEX1) );
	hex_digit d2 ( .value(value[11:8]),  .seg(HEX2) );

endmodule

// Modulo que recibe los 4 bits y devuelve los 6 bits por cada segmento del display a mostrar
module hex_digit (
	 input  logic [3:0] value,
	 output logic [6:0] seg   // activa en bajo
);

	always_comb begin
		case (value)
			4'h0: seg = 7'b1000000;
			4'h1: seg = 7'b1111001;
			4'h2: seg = 7'b0100100;
			4'h3: seg = 7'b0110000;
			4'h4: seg = 7'b0011001;
			4'h5: seg = 7'b0010010;
			4'h6: seg = 7'b0000010;
			4'h7: seg = 7'b1111000;
			4'h8: seg = 7'b0000000;
			4'h9: seg = 7'b0010000;
			4'hA: seg = 7'b0001000;
			4'hB: seg = 7'b0000011;
			4'hC: seg = 7'b1000110;
			4'hD: seg = 7'b0100001;
			4'hE: seg = 7'b0000110;
			4'hF: seg = 7'b0001110;
			default: seg = 7'b1111111; // apagado
		endcase
	end
endmodule