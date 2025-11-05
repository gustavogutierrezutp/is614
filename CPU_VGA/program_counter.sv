module program_counter(
    input wire clk,                // Entrada del reloj
	 input wire reset,              // reset es activo-alto (1)
    input wire [31:0] NextPC,     // Entrada de 32 bits (siguiente valor de PC)
    output reg [31:0] Pc = 0       // Salida del PC, inicializado en 0
);
	
    reg [31:0] pc_case;

	always @* begin
		case(reset)
		1'b0: pc_case = NextPC;
		1'b1: pc_case = 32'b0; // Cuando reset=1, pc_case es 0
	    endcase
	end

    always @(posedge clk or posedge reset) begin 
        if (reset) begin
            Pc <= 32'b0; 
        end else begin
            Pc <= pc_case;
        end
    end
	 
endmodule