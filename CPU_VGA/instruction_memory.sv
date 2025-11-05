module instruction_memory(
	input  logic [31:0] address,
	output logic [31:0] inst
);

	reg [7:0] mem[31:0];
	initial begin
		$readmemh("program_memory.hex", mem);
	end

	assign inst = {mem[address], mem[address+1], mem[address+2], mem[address+3]};

endmodule
