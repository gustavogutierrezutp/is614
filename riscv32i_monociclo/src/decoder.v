module decoder(
	input [31:0] inst,
	output [6:0] opcode,
	output [2:0] func3,
	output [6:0] func7
	);
	
	assign opcode = inst[6:0];
	assign func3 = inst[14:12];
	assign func7 = inst[31:25];
	
endmodule