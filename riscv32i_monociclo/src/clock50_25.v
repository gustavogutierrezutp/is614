module clock50_25(clock50, reset, clock25);
  input clock50;
  input reset;
  output clock25;

  reg [1:0] state;
  always @(posedge clock50)
    if (reset) state <= 0;
    else state <= state + 2'b1;

  assign clock25 = (state == 2'b0 || state == 2'b10) ? 1'b1 : 1'b0;
endmodule