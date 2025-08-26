`timescale 1ns/1ps

module tb_top_level;
    reg [9:0] SW;
    wire [9:0] LEDR;
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    
    top_level dut (
        .SW(SW),
        .LEDR(LEDR),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5)
    );
    
    initial begin
        $display("Ejercicio 4.3 - Números Grandes");
        $display("SW   | Decimal");
        
        SW = 10'd0; #10;
        $display("%4d | %4d", SW, SW);
        
        SW = 10'd1; #10;
        $display("%4d | %4d", SW, SW);
        
        SW = 10'd42; #10;
        $display("%4d | %4d", SW, SW);
        
        SW = 10'd123; #10;
        $display("%4d | %4d", SW, SW);
        
        SW = 10'd255; #10;
        $display("%4d | %4d", SW, SW);
        
        SW = 10'd512; #10;
        $display("%4d | %4d", SW, SW);
        
        SW = 10'd1023; #10;
        $display("%4d | %4d", SW, SW);
        
        $finish;
    end
endmodule