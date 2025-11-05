module inst_mem(
	input wire [31:0] addr,
	output reg [31:0] instruction
);



reg [31:0] Memory [0:63];

initial begin
$readmemh("program.hex", Memory);
end

always @(*) begin
instruction = Memory[addr[7:2]];
end


endmodule