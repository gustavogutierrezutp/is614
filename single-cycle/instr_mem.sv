// Memoria de Instrucciones
module instr_mem (
    input  logic [31:0] addr, // Dirección de la instrucción (desde PC)
    output logic [31:0] instr // Instrucción leída
);
    logic [31:0] mem [0:255];

    initial begin
        $readmemh("program.hex", mem);
    end

    always_comb begin
        instr = mem[addr[31:2]];
    end

endmodule
