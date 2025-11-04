module display_mux(
    input wire [1:0] switches,
    input wire [31:0] pc,
    input wire [31:0] immediate,
    input wire [31:0] alu_result,
    input wire [31:0] sr1,
    output reg [31:0] display_value
);
    always @(*) begin
        case (switches)
            2'b00:   display_value = pc;
            2'b01:   display_value = immediate;
            2'b10:   display_value = alu_result;
            2'b11:   display_value = sr1;
            default: display_value = 32'b0;
        endcase
    end
endmodule