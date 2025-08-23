
`timescale 1ns/1ps

module top_level_tb;

    // Entradas 
    logic SW0, SW1, SW2, SW3, SW4, SW5, SW6, SW7, SW8, SW9;
    logic KEY0;

    // Salidas 
    logic LEDR0, LEDR1, LEDR2, LEDR3, LEDR4,
          LEDR5, LEDR6, LEDR7, LEDR8, LEDR9;
    logic HEX0_a, HEX0_b, HEX0_c, HEX0_d, HEX0_e, HEX0_f, HEX0_g;
    logic HEX1_a, HEX1_b, HEX1_c, HEX1_d, HEX1_e, HEX1_f, HEX1_g;
    logic HEX2_a, HEX2_b, HEX2_c, HEX2_d, HEX2_e, HEX2_f, HEX2_g;
    logic HEX3_a, HEX3_b, HEX3_c, HEX3_d, HEX3_e, HEX3_f, HEX3_g;

    // Instancia del DUT
    top_level dut (
        .SW0(SW0), .SW1(SW1), .SW2(SW2), .SW3(SW3), .SW4(SW4),
        .SW5(SW5), .SW6(SW6), .SW7(SW7), .SW8(SW8), .SW9(SW9),
        .KEY0(KEY0),
        .LEDR0(LEDR0), .LEDR1(LEDR1), .LEDR2(LEDR2), .LEDR3(LEDR3), .LEDR4(LEDR4),
        .LEDR5(LEDR5), .LEDR6(LEDR6), .LEDR7(LEDR7), .LEDR8(LEDR8), .LEDR9(LEDR9),
        .HEX0_a(HEX0_a), .HEX0_b(HEX0_b), .HEX0_c(HEX0_c), .HEX0_d(HEX0_d),
        .HEX0_e(HEX0_e), .HEX0_f(HEX0_f), .HEX0_g(HEX0_g),
        .HEX1_a(HEX1_a), .HEX1_b(HEX1_b), .HEX1_c(HEX1_c), .HEX1_d(HEX1_d),
        .HEX1_e(HEX1_e), .HEX1_f(HEX1_f), .HEX1_g(HEX1_g),
        .HEX2_a(HEX2_a), .HEX2_b(HEX2_b), .HEX2_c(HEX2_c), .HEX2_d(HEX2_d),
        .HEX2_e(HEX2_e), .HEX2_f(HEX2_f), .HEX2_g(HEX2_g),
        .HEX3_a(HEX3_a), .HEX3_b(HEX3_b), .HEX3_c(HEX3_c), .HEX3_d(HEX3_d),
        .HEX3_e(HEX3_e), .HEX3_f(HEX3_f), .HEX3_g(HEX3_g)
    );

    // Tarea para aplicar un valor binario a los switches
    task set_switches(input [9:0] val);
        begin
            {SW9,SW8,SW7,SW6,SW5,SW4,SW3,SW2,SW1,SW0} = val;
        end
    endtask

    initial begin
	 
        // Inicialización
        {SW9,SW8,SW7,SW6,SW5,SW4,SW3,SW2,SW1,SW0} = 10'd0;
        KEY0 = 1;  // Iniciamos en unsigned

        // Caso 1: número pequeño positivo (unsigned)
        #10 set_switches(10'd25); KEY0 = 1;
        #10;

        // Caso 2: número grande (unsigned)
        #10 set_switches(10'd512); KEY0 = 1;
        #10;

        // Caso 3: número positivo en modo signed
        #10 set_switches(10'd100); KEY0 = 0;
        #10;

        // Caso 4: número negativo en modo signed (ejemplo: 10'b1111111000 = -8 en 10 bits)
        #10 set_switches(10'b1111111000); KEY0 = 0;
        #10;

        // Caso 5: valor máximo positivo (signed)
        #10 set_switches(10'b0111111111); KEY0 = 0;
        #10;

        // Caso 6: valor mínimo negativo (signed = -512)
        #10 set_switches(10'b1000000000); KEY0 = 0;
        #10;

        #50 $finish;
    end


    initial begin
        $monitor("t=%0t | SW=%b | KEY0=%b | LEDR=%b | HEX0=%b HEX1=%b HEX2=%b HEX3=%b",
                  $time,
                  {SW9,SW8,SW7,SW6,SW5,SW4,SW3,SW2,SW1,SW0},
                  KEY0,
                  {LEDR9,LEDR8,LEDR7,LEDR6,LEDR5,LEDR4,LEDR3,LEDR2,LEDR1,LEDR0},
                  {HEX0_a,HEX0_b,HEX0_c,HEX0_d,HEX0_e,HEX0_f,HEX0_g},
                  {HEX1_a,HEX1_b,HEX1_c,HEX1_d,HEX1_e,HEX1_f,HEX1_g},
                  {HEX2_a,HEX2_b,HEX2_c,HEX2_d,HEX2_e,HEX2_f,HEX2_g},
                  {HEX3_a,HEX3_b,HEX3_c,HEX3_d,HEX3_e,HEX3_f,HEX3_g}
        );
    end

endmodule
