// top_level.sv
module top_level(
  input wire clk,
  input wire rst_n,
  output wire [6:0] display,
  output wire [9:0] leds
);

  logic clk_slow;
  logic [31:0] pc, next_pc, instr;

  // ==== Divisor de reloj (de la Fase 1) ====
  clock_divider #(50_000_000) clk_div_inst (
    .clk_in(clk),
    .rst_n(rst_n),
    .clk_out(clk_slow)
  );

  // ==== PC Register ====
  pc_reg pc_inst (
    .clk(clk_slow),
    .rst_n(rst_n),
    .next_pc(next_pc),
    .pc(pc)
  );

  assign next_pc = pc + 4;

  // ==== Instruction Memory ====
  imem imem_inst (
    .addr(pc),
    .instr(instr)
  );

  // ==== Display PC (solo para debug) ====
  hex7seg display0(
    .val(pc[3:0]),
    .display(display)
  );

  // ==== LEDs muestran parte de la instrucción ====
  assign leds = instr[9:0];   // para ver cambios visuales

endmodule
