module data_memory (
    // =====================
    // Control and Data Signals
    // =====================
    input  logic         clk,           // Clock signal
    input  logic         mem_read,      // Memory read enable
    input  logic         mem_write,     // Memory write enable
    input  logic [2:0]   funct3,        // Instruction function (defines load/store type)
    input  logic [31:0]  addr,          // Memory address
    input  logic [31:0]  write_data,    // Data to be written into memory
    output logic [31:0]  read_data,     // Data read from memory

    // =====================
    // Debug Interface
    // =====================
    output logic [7:0]   mem_debug [0:127]  // Memory debug output
);

    // =====================
    // Internal Memory Arrays
    // =====================
    logic [7:0]  mem [0:127];          // 128 bytes of memory (data memory)
    logic [31:0] init_mem [0:31];      // Temporary 32-word memory for initialization

    // =====================
    // 1. Memory Initialization
    // =====================
    // Load memory content from a hex file and unpack words into bytes.
    initial begin
        $readmemh("memory.hex", init_mem);
        for (int i = 0; i < 32; i++) begin
            mem[i*4 + 0] = init_mem[i][7:0];    // Least significant byte (LSB)
            mem[i*4 + 1] = init_mem[i][15:8];
            mem[i*4 + 2] = init_mem[i][23:16];
            mem[i*4 + 3] = init_mem[i][31:24];  // Most significant byte (MSB)
        end
    end

    // =====================
    // 2. Write Operations
    // =====================
    // Perform memory writes on the positive clock edge if enabled.
    always_ff @(posedge clk) begin
        if (mem_write) begin
            unique case (funct3)
                3'b000: mem[addr] <= write_data[7:0]; // SB - Store Byte
                3'b001: begin                         // SH - Store Halfword
                    mem[addr]   <= write_data[7:0];
                    mem[addr+1] <= write_data[15:8];
                end
                3'b010: begin                         // SW - Store Word
                    mem[addr]   <= write_data[7:0];
                    mem[addr+1] <= write_data[15:8];
                    mem[addr+2] <= write_data[23:16];
                    mem[addr+3] <= write_data[31:24];
                end
                default: ; // No write
            endcase
        end
    end

    // =====================
    // 3. Read Operations
    // =====================
    // Combinational read logic for signed and unsigned loads.
    always_comb begin
        if (mem_read) begin
            unique case (funct3)
                // --- Signed Loads ---
                3'b000: read_data = {{24{mem[addr][7]}}, mem[addr]};                     // LB - Load Byte (signed)
                3'b001: read_data = {{16{mem[addr+1][7]}}, mem[addr+1], mem[addr]};     // LH - Load Halfword (signed)
                3'b010: read_data = {mem[addr+3], mem[addr+2], mem[addr+1], mem[addr]}; // LW - Load Word

                // --- Unsigned Loads ---
                3'b100: read_data = {24'b0, mem[addr]};                                 // LBU - Load Byte (unsigned)
                3'b101: read_data = {16'b0, mem[addr+1], mem[addr]};                    // LHU - Load Halfword (unsigned)

                default: read_data = 32'b0;
            endcase
        end else begin
            read_data = 32'b0;
        end
    end

    // =====================
    // 4. Debug Output
    // =====================
    assign mem_debug = mem;

endmodule
