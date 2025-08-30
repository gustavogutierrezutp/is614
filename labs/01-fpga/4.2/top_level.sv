module top_level (
    input  [3:0] SW,         // Interruptores SW0 a SW3
    output reg [6:0] HEX0    // Display de 7 segmentos (activo bajo)
);

    always @(*) begin
        case (SW)
            4'h0: HEX0 = 7'b1000000; // 0
            4'h1: HEX0 = 7'b1111001; // 1
            4'h2: HEX0 = 7'b0100100; // 2
            4'h3: HEX0 = 7'b0110000; // 3
            4'h4: HEX0 = 7'b0011001; // 4
            4'h5: HEX0 = 7'b0010010; // 5
            4'h6: HEX0 = 7'b0000010; // 6
            4'h7: HEX0 = 7'b1111000; // 7
            4'h8: HEX0 = 7'b0000000; // 8
            4'h9: HEX0 = 7'b0010000; // 9
            4'hA: HEX0 = 7'b0001000; // A
            4'hB: HEX0 = 7'b0000011; // b
            4'hC: HEX0 = 7'b1000110; // C
            4'hD: HEX0 = 7'b0100001; // d
            4'hE: HEX0 = 7'b0000110; // E
            4'hF: HEX0 = 7'b0001110; // F
            default: HEX0 = 7'b1111111; // Apagar todo
        endcase
    end

endmodule
