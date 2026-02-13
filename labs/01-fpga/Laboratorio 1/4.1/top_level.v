module top_level (
    input [9:0] SW,
    output [9:0] LEDR
);
    // Cada switch controla directamente su LED correspondiente
    assign LEDR = SW;
endmodule
