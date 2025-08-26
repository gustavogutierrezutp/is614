module top_level (
    input [3:0] SW,
    output [6:0] HEX0
);
    hex_decoder dec0(.bin(SW), .HEX0(HEX0));
endmodule
