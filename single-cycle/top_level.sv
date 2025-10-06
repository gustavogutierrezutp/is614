module top_level(
  input wire clk,
  input wire rst_n,
  output wire [6:0] display,
  output wire [9:0] leds
);

  logic [31:0] pc;
  logic [31:0] instr;

  // This block will change when you implement branching.
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      pc <= 32'b0;
    else
      pc <= pc + 4;
  end


  hex7seg display0(
    .val(pc[3:0]),
    .display(display)
  );

  assign leds = instr[9:0]; // Para mostrar los 10 bits menos significativos de la instrucción leida
endmodule 
