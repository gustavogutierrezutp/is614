// top_level.sv
module top_level(
  input wire clk,
  input wire rst_n,
  output wire [6:0] display,
  output wire [9:0] leds
);

  logic clk_slow;
  logic [31:0] pc;

  // ==== NUEVO: divisor de reloj ====
  clock_divider #(50_000_000) clk_div_inst (
    .clk_in(clk),
    .rst_n(rst_n),
    .clk_out(clk_slow)
  );

  // ==== Contador de PC (avanza cada tick del reloj lento) ====
  always @(posedge clk_slow or negedge rst_n) begin
    if (!rst_n)
      pc <= 32'b0;
    else
      pc <= pc + 4;
  end

  // ==== Display ====
  hex7seg display0(
    .val(pc[3:0]),
    .display(display)
  );

  // ==== LEDs estáticos por ahora ====
  assign leds = 10'b1010101010;

endmodule
