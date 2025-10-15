// Este modulo controla el valor actual del program counter y su incremento
module pc_reg(
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] next_pc,
    output reg  [31:0] pc
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pc <= 32'b0; // reset -> dirección 0
        else
            pc <= next_pc; // actualiza el PC
    end
endmodule
