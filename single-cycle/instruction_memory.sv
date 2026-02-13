module instruction_memory (
    input  logic [31:0] addr,
    output logic [31:0] instruction
);
    logic [31:0] rom[127:0];

    initial begin
        $readmemh("ej.hex", rom);
    end
    
    assign instruction = rom[addr[8:2]]; 

endmodule