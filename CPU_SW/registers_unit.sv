module registers_unit (
    input  wire        clk,
    input  wire        rstn,        // Reset activo en bajo
    input  wire [4:0]  rs1,         // Dirección de lectura 1
    input  wire [4:0]  rs2,         // Dirección de lectura 2
    input  wire [4:0]  rd,          // Dirección de escritura
    input  wire        ru_wr,       // Habilita escritura (RegWrite)
    input  wire [31:0] data_wr,     // Dato a escribir
    output logic [31:0] rs1_data,   // Dato leído del registro rs1
    output logic [31:0] rs2_data    // Dato leído del registro rs2
);
    logic [31:0] registers [0:31];
    integer i;
    
    // Bloque secuencial: escritura e inicialización
    always_ff @(posedge clk) begin
        if (!rstn) begin
            // Inicializar todos los registros en 0, excepto x2
            for (i = 0; i < 32; i = i + 1) begin
                if (i == 2)
                    registers[i] <= 32'h00000024;   // x2 = 0x24
                else
                    registers[i] <= 32'h00000000;
            end
        end 
        else if (ru_wr && (rd != 5'b00000)) begin
            // Escritura si RegWrite está activo y no es x0
            // Proteger x2 de escrituras accidentales (OPCIONAL)
            if (rd != 5'b00010)  // Si quieres que x2 sea read-only
                registers[rd] <= data_wr;
            // Si quieres que x2 sea escribible, usa:
            // registers[rd] <= data_wr;
        end
    end
    
    // Bloque combinacional: lectura
    always_comb begin
        // x0 siempre es 0
        rs1_data = (rs1 == 5'b00000) ? 32'h00000000 : registers[rs1];
        rs2_data = (rs2 == 5'b00000) ? 32'h00000000 : registers[rs2];
    end
endmodule