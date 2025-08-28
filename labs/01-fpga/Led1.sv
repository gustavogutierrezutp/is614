module Led1(
    input  [9:0] SW, 
    input        KEY0,
    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
	 output [0:9] leds
);
	
	assign leds = SW;
    reg [3:0]  sw0_in, sw1_in, sw2_in, sw3_in;
    reg [15:0] result;

    decoderHEX d0 (.SW(sw0_in), .HEX(HEX0));
    decoderHEX d1 (.SW(sw1_in), .HEX(HEX1));
    decoderHEX d2 (.SW(sw2_in), .HEX(HEX2));
    decoderHEX d3 (.SW(sw3_in), .HEX(HEX3));

    always @(*) begin
        if (KEY0) begin
            result = (~{6'b000000, SW}) + 16'd1;
        end else begin
            result = {6'b000000, SW};
        end
        sw0_in = result[3:0];
        sw1_in = result[7:4];
        sw2_in = result[11:8];
        sw3_in = result[15:12];
    end
endmodule
