`timescale 1ns/1ps

module tb_top_level;

  // Señales de prueba
  logic [3:0] sw;
  logic [6:0] HEX0;

  // Instancia del DUT
  top_level dut (
    .sw(sw),
    .HEX0(HEX0)
  );

  // Bloque inicial: estímulos de prueba
  initial begin
    integer i;
    for (i = 0; i < 16; i++) begin
      sw = i[3:0];
      #10;
    end
    $finish;
  end

endmodule

