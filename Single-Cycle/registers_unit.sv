module registers_unit (
    input  logic        clk,
    input  logic        rst,      

    // Direcciones de los registros
    input  logic [4:0]  rs1,
    input  logic [4:0]  rs2,
    input  logic [4:0]  rd,

    // Señales de control y datos
    input  logic        ru_wr,     // Señal de escritura
    input  logic [31:0] data_wr,   // Dato a escribir

    // Salidas
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data
);

    // Banco de registros (32 x 32 bits)
    logic [31:0] registers [0:31];
    integer i;

   
    always_ff @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i++) begin
                registers[i] <= 32'b0;
            end
            registers[2] <= 32'h0000_0024; 
        end else begin
            // Ignorar escrituras a x0
            if (ru_wr && (rd != 5'd0)) begin
                registers[rd] <= data_wr;
            end
           
            registers[0] <= 32'b0;
        end
    end

    // Inicialización para simulación (opcional): asegura que x2 arranque con 0x24
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 32'b0;
        end
        registers[2] = 32'h0000_0024;
    end

    // Lectura asíncrona
    assign rs1_data = (rs1 == 5'd0) ? 32'b0 : registers[rs1];
    assign rs2_data = (rs2 == 5'd0) ? 32'b0 : registers[rs2];

endmodule
