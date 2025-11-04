module instruction_memory(
    input wire [31:0] pc,
    output wire [31:0] instruction
);
    reg [31:0] imem [0:255];
    
    initial begin
        integer i;
        for (i = 0; i < 256; i = i + 1)
            imem[i] = 32'b0;
        
        $readmemb("../salida_binario.txt", imem);
    end
    
    assign instruction = imem[pc[9:2]];
endmodule