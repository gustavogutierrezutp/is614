module program_counter (
	input clk,
	input rst_n,
	output [31:0] pc_out
);


	sum_unit sum_inst(
		.A(pc_reg),
		.B(32'd4),
		.S(next_pc_reg)
	);


	reg [31:0] pc_reg;
	wire [31:0] next_pc_reg;


	always @(posedge clk or negedge rst_n) begin
			if (!rst_n)
				pc_reg <= 32'b0; // Reiniciar a 0
			else begin
				pc_reg <= next_pc_reg; // Incrementar usando el sumador
			end
		end
		
	assign pc_out = pc_reg;
	
endmodule