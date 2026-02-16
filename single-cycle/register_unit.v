module register_unit(
input wire clk, 
input wire reset, 
input wire RUWr,
input wire [4:0] rs1,
input wire [4:0] rs2,
input wire [4:0] rd,
input wire [31:0] datawr,

output wire [31:0] read_data1, 
output wire [31:0] read_data2
);

//32 registros de 32 bits
reg [31:0] register [31:0];
integer i;


assign read_data1 = register [rs1];
assign read_data2 = register [rs2];

always @ (posedge clk) begin

	if (reset) begin
	//Limpia todos los registros
		for (i = 0; i < 32; i = i+1)
			register[i] <= 32'h0;

	end else begin
				if(RUWr && (rd != 5'd0)) begin
				register [rd] <= datawr;
				end
				register[0] <= 32'h0;
	end
end
endmodule