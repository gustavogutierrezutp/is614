module top_level(
  input wire clk,
  input wire rst_n,
  output wire [9:0] leds
);

  assign leds = 10'b1010101010;
endmodule 