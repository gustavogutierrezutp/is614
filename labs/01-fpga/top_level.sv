module top_level (
	output logic [9:0] led,     // vector de 10 LEDs
	input  logic [9:0] switch   // vector de 10 switches
);
	
	assign led = switch;

endmodule
