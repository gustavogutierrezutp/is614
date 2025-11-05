module instruction_memory(
    input  logic        clk,
    input  logic [4:0]  address,        
    output logic [31:0] instruction       
);

    // Memoria ROM de 32 palabras de 32 bits (0..31)
    logic [31:0] mem [0:31];
    logic [31:0] instr_reg;

    // Cargar desde archivo .hex
    initial begin
        $readmemh("C:/Users/tomas/Documents/GitHub/Assembler/Assembler/program.hex", mem);
    end

    // Leer ROM de forma síncrona para inferencia de bloques de memoria
    always @(posedge clk) begin
        instr_reg <= mem[address];
    end

    assign instruction = instr_reg;

endmodule
