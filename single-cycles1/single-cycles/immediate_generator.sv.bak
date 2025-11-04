module immediate_generator(
    input wire [31:0] instruction,
    output reg [31:0] immediate
);
    localparam I_TYPE = 7'b0010011;
    localparam LOAD   = 7'b0000011;
    localparam STORE  = 7'b0100011;
    
    wire [6:0] opcode = instruction[6:0];
    
    always @(*) begin
        case (opcode)
            I_TYPE, LOAD: begin
                // Tipo I: imm[11:0]
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            end
            
            STORE: begin
                // Tipo S: imm[11:5] y imm[4:0]
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            
            default: begin
                immediate = 32'b0;
            end
        endcase
    end
endmodule