// Banco de Registros
module reg_file (
    input  logic clk, // Reloj
    input  logic reset, // Reset global
    input  logic reg_write, // Habilitación de escritura
    input  logic [4:0]  rs1, // Índice del registro fuente 1
    input  logic [4:0]  rs2, // Índice del registro fuente 2
    input  logic [4:0]  rd, // Índice del registro destino
    input  logic [31:0] write_data, // Dato a escribir en rd
    output logic [31:0] read_data1, // Salida registro fuente 1
    output logic [31:0] read_data2 // Salida registro fuente 2
);

    // Declaración del banco de registros
    logic [31:0] registers [31:0];

    // Lectura combinacional (dos puertos)
    assign read_data1 = (rs1 == 5'd0) ? 32'b0 : registers[rs1];
    assign read_data2 = (rs2 == 5'd0) ? 32'b0 : registers[rs2];
-
    // Escritura secuencial (un puerto)
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Inicializa todos los registros en 0
            integer i;
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0;
        end else begin
            // Escribe en el registro destino si está habilitado
            if (reg_write && (rd != 5'd0))
                registers[rd] <= write_data;
        end
    end

endmodule
