`timescale 1ns/1ps

module top_level_tb;

    // Entradas
    logic [9:0] SW;
    logic       KEY0;

    // Salidas
    logic [9:0] LEDR;
    logic [6:0] HEX0, HEX1, HEX2, HEX3;

  
    top_level dut (
        .SW(SW),
        .KEY0(KEY0),
        .LEDR(LEDR),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3)
    );
  
    initial begin

        // binario normal (KEY0 = 0)
        KEY0 = 0;
        SW = 10'b0000000000; #10;  //0000
        SW = 10'b0000001010; #10;  //000A
        SW = 10'b1111111111; #10;  //03FF

        // complemento a 2 (KEY0 = 1)
        KEY0 = 1;
        SW = 10'b0000000001; #10; //FFFF
        SW = 10'b0000001010; #10; //FFF6
        SW = 10'b1111111111; #10  //0001

        $stop;
    end

endmodule
