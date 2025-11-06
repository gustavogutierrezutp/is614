module ascii_memory (
    input wire clk,
    input wire [9:0] addr,
    output reg [7:0] char_data
);

    reg [7:0] memory [0:1023];  // Memoria de caracteres, ajusta el tamaño según sea necesario

    initial begin
        $readmemh("ascii_text.hex", memory); // Carga el archivo .hex con caracteres ASCII
    end

    always @(posedge clk) begin
        char_data <= memory[addr];
    end

endmodule
