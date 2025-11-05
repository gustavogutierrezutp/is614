module mux_ALUA (
	input [31:0]I0, 
	input [31:0]I1,
   input S,
   output [31:0]Y
);

	assign Y = S ? I1 : I0;

endmodule