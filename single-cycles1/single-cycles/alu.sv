module alu(
    input wire [31:0] operand1,
    input wire [31:0] operand2,
    input wire [3:0] alu_control,
    output reg [31:0] alu_result,
    output wire zero_flag
);

    always @(*) begin
        case (alu_control)
            4'b0000: alu_result = operand1 + operand2;
            4'b0001: alu_result = operand1 - operand2;
            4'b0010: alu_result = operand1 & operand2;
            4'b0011: alu_result = operand1 | operand2;
            4'b0100: alu_result = operand1 ^ operand2;
            4'b0101: alu_result = operand1 << operand2[4:0];
            4'b0110: alu_result = operand1 >> operand2[4:0];
            4'b0111: alu_result = $signed(operand1) >>> operand2[4:0];
            4'b1000: alu_result = ($signed(operand1) < $signed(operand2)) ? 32'b1 : 32'b0;
            4'b1001: alu_result = (operand1 < operand2) ? 32'b1 : 32'b0;
            default: alu_result = 32'b0;
        endcase
    end
    
    assign zero_flag = (alu_result == 32'b0);
    
endmodule