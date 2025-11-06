module fixed_text_rom (
    input wire [11:0] address,  // Dirección para seleccionar el texto fijo
    output reg [7:0] data      // Código ASCII del carácter
);
    reg [7:0] fixed [0:4095];
	 
	 initial begin
        $readmemh("fixed_ascii_romF_3.hex", fixed);
    end
	 
	 always @* begin
		data = fixed[address];
	end
endmodule
