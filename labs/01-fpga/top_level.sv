module top_level (
    input  logic [9:0] SW,
    input  logic KEY0,
    output logic [9:0] LEDR,
    output logic [6:0] HEX0,
    output logic [6:0] HEX1,
    output logic [6:0] HEX2,
    output logic [6:0] HEX3
);

    assign LEDR = SW;   // Reflejar switches en LEDs

    logic [9:0] num;
    assign num = SW;

    logic [15:0] val;

    // KEY0 = 0 (presionado) -> binario normal 
	 // KEY0 = 1 (no presionado) -> binario con complemento a 2
    assign val = (KEY0 == 1'b0) ? {6'b0, num} : {{6{~num[9]}}, (~num + 10'b1)};

    // dividimos en los 4 displays 
	 logic [3:0] hex0; 
	 logic [3:0] hex1; 
	 logic [3:0] hex2; 
	 logic [3:0] hex3;

    assign hex0 = val[3:0];
    assign hex1 = val[7:4];
    assign hex2 = val[11:8];
    assign hex3 = val[15:12];

    // Decodificadores para cada display
    hex7seg disp0 (.hex_in(hex0), .seg(HEX0));
    hex7seg disp1 (.hex_in(hex1), .seg(HEX1));
    hex7seg disp2 (.hex_in(hex2), .seg(HEX2));
    hex7seg disp3 (.hex_in(hex3), .seg(HEX3));

endmodule


// Conversor hexadecimal -> display 7 segmentos
module hex7seg (
    input  logic [3:0] hex_in,
    output logic [6:0] seg
);
    always_comb begin
        case (hex_in)
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

