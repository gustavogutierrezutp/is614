// Memoria de Instrucciones
module imem (
    input  wire [31:0] addr,    // dirección del PC
    output wire [31:0] instr    // instrucción leída
);

    // 4 KB de memoria = 1024 instrucciones de 32 bits
    reg [31:0] mem [0:1023];

    initial begin
        $readmemh("program.hex", mem);
    end

    assign instr = mem[addr[11:2]];  
    // addr[11:2] porque las instrucciones están alineadas a 4 bytes

endmodule
