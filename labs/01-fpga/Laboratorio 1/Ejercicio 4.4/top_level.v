module hex_decoder(
    input [3:0] bin,        
    output reg [6:0] HEX    
);

always @(*) begin
    case (bin)
        4'h0 : HEX = 7'b1000000; // 0
        4'h1 : HEX = 7'b1111001; // 1
        4'h2 : HEX = 7'b0100100; // 2
        4'h3 : HEX = 7'b0110000; // 3
        4'h4 : HEX = 7'b0011001; // 4
        4'h5 : HEX = 7'b0010010; // 5
        4'h6 : HEX = 7'b0000010; // 6
        4'h7 : HEX = 7'b1111000; // 7
        4'h8 : HEX = 7'b0000000; // 8
        4'h9 : HEX = 7'b0010000; // 9
        4'hA : HEX = 7'b0001000; // A
        4'hB : HEX = 7'b0000011; // b
        4'hC : HEX = 7'b1000110; // C
        4'hD : HEX = 7'b0100001; // d
        4'hE : HEX = 7'b0000110; // E
        4'hF : HEX = 7'b0001110; // F
        default: HEX = 7'b1111111; 
    endcase
end

endmodule


module top_level (
    input [9:0] SW,
    input KEY0,
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2
);

    wire signed [9:0] num_signed = SW;
    wire [9:0] num_unsigned = SW;
    wire mode = KEY0;
    wire [9:0] display_num = mode ? num_unsigned : num_signed;

    hex_decoder dec0(.bin(display_num[3:0]), .HEX(HEX0));
    hex_decoder dec1(.bin(display_num[7:4]), .HEX(HEX1));
    hex_decoder dec2(.bin({2'b00, display_num[9:8]}), .HEX(HEX2));

endmodule
