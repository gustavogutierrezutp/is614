
module registers_unit (

    input  logic        clk,              // Reloj
    input  logic        rst,              // Reset 

    input  logic [4:0]  rs1, rs2, rd,     // Source 1, Source 2, Destination
    input  logic        ru_wr,            // Señal de habilitación de escritura
    input  logic [31:0] data_wr,          // Dato a escribir en rd

    output logic [31:0] rs1_data,         // Dato leído de rs1
    output logic [31:0] rs2_data,         // Dato leído de rs2
    output logic [31:0] debug_registers [0:31] // Puerto de debug para ver todos los registros
	 
);

    logic [31:0] registers [0:31];
    integer i;
     
    // ============================================================
    // Lógica de Escritura y Reset 
    // ============================================================
    
	 always_ff @(posedge clk or posedge rst) begin
	 
        if (rst) begin
           
            for (i = 0; i < 32; i++) begin
				
                if (i == 2)
                    registers[i] <= 32'h24; 
                else
                    registers[i] <= 32'd0;  
            end
				
        end else if (ru_wr && (rd != 5'd0)) begin
        
            registers[rd] <= data_wr;
        end
    end

    // ============================================================
    // Lógica de Lectura 
    // ============================================================
   
    assign rs1_data = (rs1 == 5'd0) ? 32'b0 : registers[rs1];
    assign rs2_data = (rs2 == 5'd0) ? 32'b0 : registers[rs2];

    assign debug_registers = registers;

endmodule