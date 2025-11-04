module immediate_generator(
    input wire [31:0] instruction,
    output reg [31:0] immediate
);

    localparam TIPO_I = 7'b0010011;
    localparam CARGA  = 7'b0000011;
    localparam STORE  = 7'b0100011;
    
    wire [6:0] opcode = instruction[6:0];
    
    always @(*) begin
        case (opcode)
            TIPO_I, CARGA: begin
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            end
            
            STORE: begin
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end
            
            default: begin
                immediate = 32'b0;
            end
        endcase
    end
    
endmodule