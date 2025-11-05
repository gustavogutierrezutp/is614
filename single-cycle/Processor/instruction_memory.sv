module instruction_memory (
    // CPU instruction port
    input  logic [31:0] addr,
    output logic [31:0] instr,

    // Debug port (VGA)
    input  logic [6:0]  debug_addr,  // 7 bits to address 128 entries
    output logic [31:0] debug_data
);

    // Internal memory: 128 words of 32 bits
    logic [31:0] memory [0:127];

    //Initial memory load from file
    initial begin
       $readmemb("program.bin", memory);
    end

    // Instruction read (combinational)
    always_comb begin
        instr = memory[addr[8:2]];
    end

    // Debug read (combinational)
    assign debug_data = memory[debug_addr];

    // The assignment "assign memory_debug = memory;" has been removed.

endmodule
