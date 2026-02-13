// =============================================================================
// EJERCICIO 4.1: LED Reflection
 =============================================================================

module Prueba(
    // Entradas
    input [9:0] SW,      // 10 interruptores deslizantes
    
    // Salidas
    output [9:0] LEDR    // 10 LEDs rojos
);

// Solución: Conectar directamente cada switch con su LED correspondiente
// SW0 -> LEDR0, SW1 -> LEDR1, ..., SW9 -> LEDR9
assign LEDR = SW;

endmodule

/*



// =============================================================================
// EJERCICIO 4.2: Hexadecimal display on seven-segment display =============================================================================

module Prueba(
    // Entradas
    input [9:0] SW,      // 10 interruptores (solo usamos SW[3:0])
    
    // Salidas
    output [9:0] LEDR,   // LEDs para mostrar estado de switches
    output [6:0] HEX0    // Display de 7 segmentos
);

// Mantener funcionalidad del ejercicio anterior
assign LEDR = SW;

// Función para convertir 4 bits a display de 7 segmentos (activo bajo)
function [6:0] hex_to_7seg;
    input [3:0] hex_value;
    begin
        case (hex_value)
            4'h0: hex_to_7seg = 7'b1000000; // Muestra "0"
            4'h1: hex_to_7seg = 7'b1111001; // Muestra "1"
            4'h2: hex_to_7seg = 7'b0100100; // Muestra "2"
            4'h3: hex_to_7seg = 7'b0110000; // Muestra "3"
            4'h4: hex_to_7seg = 7'b0011001; // Muestra "4"
            4'h5: hex_to_7seg = 7'b0010010; // Muestra "5"
            4'h6: hex_to_7seg = 7'b0000010; // Muestra "6"
            4'h7: hex_to_7seg = 7'b1111000; // Muestra "7"
            4'h8: hex_to_7seg = 7'b0000000; // Muestra "8"
            4'h9: hex_to_7seg = 7'b0010000; // Muestra "9"
            4'hA: hex_to_7seg = 7'b0001000; // Muestra "A"
            4'hB: hex_to_7seg = 7'b0000011; // Muestra "b"
            4'hC: hex_to_7seg = 7'b1000110; // Muestra "C"
            4'hD: hex_to_7seg = 7'b0100001; // Muestra "d"
            4'hE: hex_to_7seg = 7'b0000110; // Muestra "E"
            4'hF: hex_to_7seg = 7'b0001110; // Muestra "F"
            default: hex_to_7seg = 7'b1111111; // Apagado
        endcase
    end
endfunction

// Asignar la conversión de los primeros 4 switches al display HEX0
assign HEX0 = hex_to_7seg(SW[3:0]);

endmodule

/*
// =============================================================================
// EJERCICIO 4.3: Bigger numbers, still positive  =============================================================================

module Prueba(
    // Entradas
    input [9:0] SW,      // Los 10 interruptores
    
    // Salidas
    output [9:0] LEDR,   // LEDs para mostrar estado de switches
    output [6:0] HEX0,   // Display menos significativo
    output [6:0] HEX1,   // Segundo display
    output [6:0] HEX2,   // Tercer display
    output [6:0] HEX3,   // Display más significativo
    output [6:0] HEX4,   // Display adicional (no usado en este ejercicio)
    output [6:0] HEX5    // Display adicional (no usado en este ejercicio)
);

// Mantener funcionalidad de LEDs
assign LEDR = SW;

// Función para convertir 4 bits a display de 7 segmentos (activo bajo)
function [6:0] hex_to_7seg;
    input [3:0] hex_value;
    begin
        case (hex_value)
            4'h0: hex_to_7seg = 7'b1000000; // "0"
            4'h1: hex_to_7seg = 7'b1111001; // "1"
            4'h2: hex_to_7seg = 7'b0100100; // "2"
            4'h3: hex_to_7seg = 7'b0110000; // "3"
            4'h4: hex_to_7seg = 7'b0011001; // "4"
            4'h5: hex_to_7seg = 7'b0010010; // "5"
            4'h6: hex_to_7seg = 7'b0000010; // "6"
            4'h7: hex_to_7seg = 7'b1111000; // "7"
            4'h8: hex_to_7seg = 7'b0000000; // "8"
            4'h9: hex_to_7seg = 7'b0010000; // "9"
            4'hA: hex_to_7seg = 7'b0001000; // "A"
            4'hB: hex_to_7seg = 7'b0000011; // "b"
            4'hC: hex_to_7seg = 7'b1000110; // "C"
            4'hD: hex_to_7seg = 7'b0100001; // "d"
            4'hE: hex_to_7seg = 7'b0000110; // "E"
            4'hF: hex_to_7seg = 7'b0001110; // "F"
            default: hex_to_7seg = 7'b1111111; // Apagado
        endcase
    end
endfunction

// Asignación de displays para mostrar número completo de 10 bits
// HEX0: bits 3-0 (dígito menos significativo)
assign HEX0 = hex_to_7seg(SW[3:0]);

// HEX1: bits 7-4 (segundo dígito)
assign HEX1 = hex_to_7seg(SW[7:4]);

// HEX2: bits 9-8 (dígito más significativo, solo 2 bits usados)
// Rellenamos con ceros los bits superiores
assign HEX2 = hex_to_7seg({2'b00, SW[9:8]});

// HEX3: No se usa para números de 10 bits, se mantiene apagado
assign HEX3 = 7'b1111111; // Apagado

// HEX4 y HEX5: No se usan
assign HEX4 = 7'b1111111; // Apagado
assign HEX5 = 7'b1111111; // Apagado

endmodule

/*

// =============================================================================
// EJERCICIO 4.4: Negative numbers =============================================================================

module top_level(
    // Entradas
    input [9:0] SW,      // 10 interruptores
    input [3:0] KEY,     // Botones (KEY0 para toggle)
    input CLOCK_50,      // Clock para debounce
    
    // Salidas
    output [9:0] LEDR,   // LEDs para mostrar estado
    output [6:0] HEX0,   // Display menos significativo
    output [6:0] HEX1,   // Segundo display
    output [6:0] HEX2,   // Tercer display
    output [6:0] HEX3,   // Cuarto display
    output [6:0] HEX4,   // Quinto display (signo negativo)
    output [6:0] HEX5    // Indicador de modo (S/U)
);

// Mantener funcionalidad de LEDs
assign LEDR = SW;

// Variables internas
reg signed_mode = 0;        // 0 = unsigned, 1 = signed
reg key0_prev = 1;          // Estado anterior de KEY0
reg [1:0] key0_sync = 2'b11; // Sincronizador para debounce

// Sincronización y debounce simple de KEY0
always @(posedge CLOCK_50) begin
    key0_sync <= {key0_sync[0], KEY[0]};
end

// Detección de flanco para toggle de modo
always @(posedge CLOCK_50) begin
    key0_prev <= key0_sync[1];
    if (key0_prev && !key0_sync[1]) begin // Flanco descendente
        signed_mode <= ~signed_mode;
    end
end

// Función para convertir 4 bits a display de 7 segmentos
function [6:0] hex_to_7seg;
    input [3:0] hex_value;
    begin
        case (hex_value)
            4'h0: hex_to_7seg = 7'b1000000; // "0"
            4'h1: hex_to_7seg = 7'b1111001; // "1"
            4'h2: hex_to_7seg = 7'b0100100; // "2"
            4'h3: hex_to_7seg = 7'b0110000; // "3"
            4'h4: hex_to_7seg = 7'b0011001; // "4"
            4'h5: hex_to_7seg = 7'b0010010; // "5"
            4'h6: hex_to_7seg = 7'b0000010; // "6"
            4'h7: hex_to_7seg = 7'b1111000; // "7"
            4'h8: hex_to_7seg = 7'b0000000; // "8"
            4'h9: hex_to_7seg = 7'b0010000; // "9"
            4'hA: hex_to_7seg = 7'b0001000; // "A"
            4'hB: hex_to_7seg = 7'b0000011; // "b"
            4'hC: hex_to_7seg = 7'b1000110; // "C"
            4'hD: hex_to_7seg = 7'b0100001; // "d"
            4'hE: hex_to_7seg = 7'b0000110; // "E"
            4'hF: hex_to_7seg = 7'b0001110; // "F"
            default: hex_to_7seg = 7'b1111111; // Apagado
        endcase
    end
endfunction

// Lógica para determinar el número a mostrar
wire is_negative;
wire [9:0] display_value;
wire [9:0] magnitude;

// Detectar si es negativo (solo en modo signed)
assign is_negative = signed_mode && SW[9];

// Calcular magnitud (complemento a 2 si es negativo)
assign magnitude = SW[9] ? (~SW + 1) : SW;

// Seleccionar qué mostrar según el modo
assign display_value = (signed_mode && is_negative) ? magnitude : SW;

// Asignación de displays
assign HEX0 = hex_to_7seg(display_value[3:0]);   // Dígito menos significativo
assign HEX1 = hex_to_7seg(display_value[7:4]);   // Segundo dígito
assign HEX2 = hex_to_7seg({2'b00, display_value[9:8]}); // Dígito más significativo

// HEX3: Mostrar dígito adicional si es necesario (para números grandes)
assign HEX3 = 7'b1111111; // Apagado por ahora

// HEX4: Indicador de signo negativo
assign HEX4 = (signed_mode && is_negative) ? 7'b0111111 : 7'b1111111; // "-" o apagado

// HEX5: Indicador de modo (S = signed, U = unsigned)
assign HEX5 = signed_mode ? 7'b0010010 : 7'b1000001; // "S" o "U"

endmodule

/*