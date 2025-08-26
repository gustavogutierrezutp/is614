module top_level (
    input  logic [9:0] switch,
    output logic [9:0] led,
    output logic [6:0] hex0,
    output logic [6:0] hex1,
    output logic [6:0] hex2
);

assign led = switch;

function automatic [6:0] hex_to_sevenseg(input logic [3:0] nibble);
	begin
		case (nibble)
			4'h0: hex_to_sevenseg = 7'b1000000; // 0
			4'h1: hex_to_sevenseg = 7'b1111001; // 1
			4'h2: hex_to_sevenseg = 7'b0100100; // 2
			4'h3: hex_to_sevenseg = 7'b0110000; // 3
			4'h4: hex_to_sevenseg = 7'b0011001; // 4
			4'h5: hex_to_sevenseg = 7'b0010010; // 5
			4'h6: hex_to_sevenseg = 7'b0000010; // 6
			4'h7: hex_to_sevenseg = 7'b1111000; // 7
			4'h8: hex_to_sevenseg = 7'b0000000; // 8
			4'h9: hex_to_sevenseg = 7'b0010000; // 9
			4'hA: hex_to_sevenseg = 7'b0001000; // A
			4'hB: hex_to_sevenseg = 7'b0000011; // b
			4'hC: hex_to_sevenseg = 7'b1000110; // C
			4'hD: hex_to_sevenseg = 7'b0100001; // d
			4'hE: hex_to_sevenseg = 7'b0000110; // E
			4'hF: hex_to_sevenseg = 7'b0001110; // F
			default: hex_to_sevenseg = 7'b1111111; // apagado
		endcase
	end
endfunction

always_comb begin
	hex0 = hex_to_sevenseg(switch[3:0]);
	hex1 = hex_to_sevenseg(switch[7:4]);
	hex2 = hex_to_sevenseg({2'b00, switch[9:8]});
end    

endmodule