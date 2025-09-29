`timescale 1ns/1ps

module tb_top_level;
    reg [9:0] SW;
    reg [3:0] KEY;
    wire [9:0] LEDR;
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    
    top_level dut (
        .SW(SW),
        .KEY(KEY),
        .LEDR(LEDR),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5)
    );
    
    initial begin
        $display("Ejercicio 4.4 - Números Negativos");
        $display("SW   | KEY0 | Mode     | Signo");
        
        // Modo sin signo (KEY0 no presionado)
        KEY = 4'b1111;
        SW = 10'd513; #10;
        $display("%4d | %1b    | Unsigned | %s", SW, KEY[0], 
                 (HEX4 == 7'b1111111) ? "No" : "Si");
        
        SW = 10'b1000000001; #10; // MSB=1 pero modo sin signo
        $display("%4d | %1b    | Unsigned | %s", SW, KEY[0],
                 (HEX4 == 7'b1111111) ? "No" : "Si");
        
        // Modo con signo (KEY0 presionado)
        KEY = 4'b1110;
        SW = 10'b0000000001; #10; // +1
        $display("%4d | %1b    | Signed   | %s", SW, KEY[0],
                 (HEX4 == 7'b1111111) ? "No" : "Si");
        
        SW = 10'b1000000001; #10; // -511 en complemento a 2
        $display("%4d | %1b    | Signed   | %s", SW, KEY[0],
                 (HEX4 == 7'b0111111) ? "Si" : "No");
        
        SW = 10'b1111111111; #10; // -1 en complemento a 2
        $display("%4d | %1b    | Signed   | %s", SW, KEY[0],
                 (HEX4 == 7'b0111111) ? "Si" : "No");
        
        $finish;
    end
endmodule