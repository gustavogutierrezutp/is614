`timescale 1ns/1ps

module tb_top_level;
    reg [9:0] SW;
    reg KEY0;
    wire [6:0] HEX0, HEX1, HEX2;

    top_level uut(
        .SW(SW),
        .KEY0(KEY0),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2)
    );

    initial begin
        // Comprobar modo unsigned
        KEY0 = 1;
        SW = 10'b0000000011; #10;
        SW = 10'b1111111111; #10;
        
        // Comprobar modo signed
        KEY0 = 0;
        SW = 10'b1111111111; #10;
        SW = 10'b1000000000; #10;
        $stop;
    end
endmodule
