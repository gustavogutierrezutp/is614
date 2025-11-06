module bin_to_ascii_5 (
    input wire [4:0] binary_in,   // Entrada binaria de hasta 7 bits
    output reg [39:0] ascii_out   // Salida ASCII (máximo 7 caracteres, 8 bits cada uno)
);

    integer i;
    

    always @* begin
        // Inicializamos la salida a ceros
        ascii_out = 40'b0;

        // Convertir cada bit de la sección especificada a ASCII
        for (i = 0; i < 5; i = i + 1) begin
            // Verificamos que el índice esté dentro del rango de `binary_in`
            if (i < 5) begin
                // Extraemos el bit específico y lo convertimos a ASCII
                if (binary_in[i] == 1'b1)
                    ascii_out[(i * 8) +: 8] = 8'h31; // ASCII de '1'
                else
                    ascii_out[(i * 8) +: 8] = 8'h30; // ASCII de '0'
            end
        end
    end

endmodule
