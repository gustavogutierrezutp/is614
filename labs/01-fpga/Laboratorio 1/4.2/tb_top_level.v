`timescale 1ns/1ps

module tb_top_level;
    reg [9:0] SW;
    wire [9:0] LEDR;
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    integer i;
    
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
        $display("Ejercicio 4.2 - Display Hexadecimal");
        $display("SW[3:0] | Hex | HEX0");
        
        for (i = 0; i < 16; i = i + 1) begin
            SW = {6'b000000, i[3:0]};
            #10;
            $display("  %4b  |  %X  | %7b", SW[3:0], i, HEX0);
        end
        
        $finish;
    end
endmodule