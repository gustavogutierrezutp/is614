`timescale 1ns/1ps

module tb_top_level;
    reg [3:0] SW;
    wire [6:0] HEX0;
    
    top_level uut(
        .SW(SW),
        .HEX0(HEX0)
    );
    
    initial begin
        SW = 4'h0; #10;
        SW = 4'h1; #10;
        SW = 4'hA; #10;
        SW = 4'hF; #10;
        $stop;
    end
endmodule
