module top_level (
    input [9:0] SW,
    output [9:0] LEDR,
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    output [6:0] HEX4,
    output [6:0] HEX5
);
    assign LEDR = SW;
    
    seven_segment_decoder decoder (
        .binary_in(SW[3:0]), 
        .segments_out(HEX0)
    );
    
    assign HEX1 = 7'b1111111;
    assign HEX2 = 7'b1111111;
    assign HEX3 = 7'b1111111;
    assign HEX4 = 7'b1111111;
    assign HEX5 = 7'b1111111;
endmodule

module seven_segment_decoder (
    input [3:0] binary_in,
    output reg [6:0] segments_out
);
    always @(*) begin
        case (binary_in)
            4'h0: segments_out = 7'b1000000;
            4'h1: segments_out = 7'b1111001;
            4'h2: segments_out = 7'b0100100;
            4'h3: segments_out = 7'b0110000;
            4'h4: segments_out = 7'b0011001;
            4'h5: segments_out = 7'b0010010;
            4'h6: segments_out = 7'b0000010;
            4'h7: segments_out = 7'b1111000;
            4'h8: segments_out = 7'b0000000;
            4'h9: segments_out = 7'b0010000;
            4'hA: segments_out = 7'b0001000;
            4'hB: segments_out = 7'b0000011;
            4'hC: segments_out = 7'b1000110;
            4'hD: segments_out = 7'b0100001;
            4'hE: segments_out = 7'b0000110;
            4'hF: segments_out = 7'b0001110;
            default: segments_out = 7'b1111111;
        endcase
    end
endmodule