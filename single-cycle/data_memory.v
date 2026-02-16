module data_memory (
    input  wire        clk,
    input  wire        mem_write,
    input  wire        mem_read,
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    output reg  [31:0] read_data
);

	// 256 palabras de 32 bits = 1 KB
	reg [31:0] mem [0:255];

	// Escritura instrucciones - S
	always @(posedge clk) begin
	  if (mem_write)
			mem[addr[9:2]] <= write_data;
	end

	// Lectura instrucciones - L
	always @(*) begin
	  if (mem_read)
			read_data = mem[addr[9:2]];
	  else
			read_data = 32'b0;
	end
endmodule