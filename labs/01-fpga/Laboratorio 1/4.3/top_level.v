
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
    
    wire [3:0] digit0 = SW % 10;
    wire [3:0] digit1 = (SW / 10) % 10;
    wire [3:0] digit2 = (SW / 100) % 10;
    wire [3:0] digit3 = (SW / 1000) % 10;
    
    seven_segment_decoder dec0 (.binary_in(digit0), .segments_out(HEX0));
    seven_segment_decoder dec1 (.binary_in(digit1), .segments_out(HEX1));
    seven_segment_decoder dec2 (.binary_in(digit2), .segments_out(HEX2));
    seven_segment_decoder dec3 (.binary_in(digit3), .segments_out(HEX3));
    
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
            default: segments_out = 7'b1111111;
        endcase
    end
endmodule