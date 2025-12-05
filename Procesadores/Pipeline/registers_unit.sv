module registers_unit(
  input clk,
  input rst_n,              
  input [4:0] rs1,
  input [4:0] rs2,
  input [4:0] rd,
  input [31:0] DataWr,
  input         RUWr,
  output [31:0] RU1,
  output [31:0] RU2,
  output [31:0] registers [0:31]
);

  integer i;

  // Reset asíncrono y escritura secuencial
  always @(negedge rst_n or negedge clk) begin
    if (!rst_n) begin
      for (i = 0; i < 32; i = i + 1) begin
        registers[i] <= 32'd0;
      end
    end else if (RUWr & (rd > 5'b00000)) begin
      registers[rd] <= DataWr;
    end
  end

  assign RU1 = registers[rs1];
  assign RU2 = registers[rs2];

endmodule
