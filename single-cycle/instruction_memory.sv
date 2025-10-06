module instruction_memory #(
    parameter MEM_DEPTH = 256,               // cantidad de instrucciones
    parameter INIT_FILE = "instructions.hex" // archivo con las instrucciones
)(
    input  logic [31:0] addr,    // dirección (viene del PC)
    output logic [31:0] instr    // instrucción leída
);

    // Memoria de 32 bits de ancho
    logic [31:0] mem [0:MEM_DEPTH-1];

    // Inicializa el contenido de la memoria desde un archivo HEX
    initial begin
        $display("Loading instructions from %s ...", INIT_FILE);
        $readmemb(INIT_FILE, mem);
    end

    // Se asume que addr está alineado a 4 bytes
    assign instr = mem[addr[31:2]];  // se ignoran los 2 LSB (división por 4)
endmodule
