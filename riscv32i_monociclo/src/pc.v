// Módulo para el Program Counter (PC)
module pc(
    input wire clk,                // Entrada del reloj
	 input reset,
    input wire [31:0] NextPC,     // Entrada de 32 bits (siguiente valor de PC)
    output reg [31:0] Pc = 0       // Salida del PC, inicializado en 0
);
	
	reg [31:0] pc_case;
	
	always @* begin
		case(reset)
		1'b0: pc_case = NextPC;
		1'b1: pc_case = 32'b0;
		endcase
	 end

    // Bloque siempre activado en el flanco positivo del reloj
    always @(posedge clk) begin
        Pc <= pc_case;              // Actualiza Pc con el valor de NextPC
    end
	 
	 
endmodule