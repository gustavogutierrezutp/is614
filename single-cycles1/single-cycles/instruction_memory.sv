module instruction_memory(
    input wire [31:0] pc,
    output wire [31:0] instruction
);

    reg [31:0] mem_inst [0:255];
    
    initial begin
        integer i;
        for (i = 0; i < 256; i = i + 1)
            mem_inst[i] = 32'b0;
        
        $readmemb("../program.bin", mem_inst);
    end
    
    assign instruction = mem_inst[pc[9:2]];
    
endmodule