`timescale 1ns/1ps

module tb_top_level;
    reg [9:0] SW;
    wire [9:0] LEDR;
    
    top_level dut (.SW(SW), .LEDR(LEDR));
    
    initial begin
        $display("Ejercicio 4.1 - Reflejo de LEDs");
        $display("SW         | LEDR       | Result");
        
        SW = 10'b0000000000; #10;
        $display("%10b | %10b | %s", SW, LEDR, (LEDR == SW) ? "PASS" : "FAIL");
        
        SW = 10'b0000000001; #10;
        $display("%10b | %10b | %s", SW, LEDR, (LEDR == SW) ? "PASS" : "FAIL");
        
        SW = 10'b1000000000; #10;
        $display("%10b | %10b | %s", SW, LEDR, (LEDR == SW) ? "PASS" : "FAIL");
        
        SW = 10'b0101010101; #10;
        $display("%10b | %10b | %s", SW, LEDR, (LEDR == SW) ? "PASS" : "FAIL");
        
        SW = 10'b1111111111; #10;
        $display("%10b | %10b | %s", SW, LEDR, (LEDR == SW) ? "PASS" : "FAIL");
        
        $finish;
    end
endmodule
