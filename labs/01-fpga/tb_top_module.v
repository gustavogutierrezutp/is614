`timescale 1ns/1ps

module tb_top_module;

// Entradas
reg [9:0] SW;
reg [3:0] KEY;

// Salidas
wire [9:0] LEDR;
wire [6:0] HEX0;
wire [6:0] HEX1;
wire [6:0] HEX2;

// Instancia del módulo principal
top_module uut (
    .SW(SW),
    .KEY(KEY),
    .LEDR(LEDR),
    .HEX0(HEX0),
    .HEX1(HEX1),
    .HEX2(HEX2)
);

initial begin
    $display("=== INICIO DE SIMULACIÓN ===");

    // Estado inicial:
    // KEY0 = 0 (presionado, activo-bajo) => MODO UNSIGNED
    // Complemento a 2 DESACTIVADO por defecto
    SW  = 10'b0000000000;
    KEY = 4'b1110;  // KEY0 = 0, las demás KEY en 1 (sin presionar)

    #10;
    $display("Default: UNSIGNED (complemento desactivado), KEY0=0");

    // Caso 4.1: Reflejo en LEDs
    $display("Caso 4.1: Reflejo de LEDs con SW");
    SW = 10'b0000000001; #10;
    SW = 10'b0000001010; #10; // SW[3:0]=1010 (10 dec) -> HEX0 = A
    SW = 10'b0000001111; #10; // SW[3:0]=1111 (15 dec) -> HEX0 = F

    // Caso 4.3 (a partir del 4.2): usar 10 bits, modo UNSIGNED
    $display("Caso 4.3: Numero grande en UNSIGNED (por defecto)");
    SW = 10'b1111111111; #10; // 1023 dec -> 3FF en hexadecimal

    // Caso 4.4: Cambiar a SIGNED soltando KEY0 (KEY0=1)
    $display("Caso 4.4: Cambiar a SIGNED (complemento activado) soltando KEY0");
    KEY[0] = 1'b1; #10; // ahora interpretacion signed (two's complement)

    // Alternar un par de veces entre modos
    $display("Alternando entre SIGNED y UNSIGNED...");
    KEY[0] = 1'b0; #20; // UNSIGNED
    KEY[0] = 1'b1; #20; // SIGNED
    KEY[0] = 1'b0; #20; // UNSIGNED

    // Prueba de valor negativo en SIGNED (bit 9 = 1)
    $display("Prueba con valor negativo en SIGNED");
    KEY[0] = 1'b1;           // SIGNED
    SW     = 10'b1000000000; // bit de signo = 1
    #20;

    $display("=== FIN DE SIMULACIÓN ===");
    $stop;
end

endmodule
