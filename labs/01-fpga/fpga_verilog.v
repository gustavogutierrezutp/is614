module fpga_verilog (
    input  [9:0] SW,      // Entradas: 10 switches físicos
    input        KEY0,    // Botón que cambia el modo: 1 = sin signo, 0 = con signo
    output [9:0] LEDR,    // Salida: eco de los switches en los LEDs
    output [6:0] HEX0,    // Display 7 segmentos -> unidades
    output [6:0] HEX1,    // Display 7 segmentos -> decenas
    output [6:0] HEX2,    // Display 7 segmentos -> centenas
    output [6:0] HEX3     // Display 7 segmentos -> muestra el signo o el modo
);

    // Encender los LEDs igual que los switches (para ver el valor binario directo)
    assign LEDR = SW;   

    // Interpretar el valor de los switches como con signo y sin signo
    wire signed [9:0] signed_val   = SW;   // con signo (2's complement)
    wire        [9:0] unsigned_val = SW;   // sin signo (decimal normal)

    // Según el botón KEY0, se escoge si tomar el número con signo o sin signo
    wire signed [10:0] val = (KEY0) ? unsigned_val : signed_val;

    // Si el número es negativo, se toma el valor absoluto para mostrarlo
    wire [10:0] mag = (val < 0) ? -val : val;

    // =======================================================
    // Conversión de binario a BCD (para mostrar en decimal)
    // Usamos el método "double dabble" (shift + add-3)
    // =======================================================
    reg [3:0] dig0, dig1, dig2; // dígitos: unidades, decenas, centenas
    reg [13:0] shift;           
    integer i;

    always @(*) begin
        // Inicializamos los dígitos en 0
        dig0 = 0; dig1 = 0; dig2 = 0;
        shift = {4'b0000, mag}; // concatenamos espacio para los dígitos + el número binario

        // Algoritmo de shift-add-3 (repetimos tantas veces como bits tenga el número)
        for (i=0; i<10; i=i+1) begin   // como es de 10 bits, hacemos 10 corrimientos
            if (dig0 >= 5) dig0 = dig0 + 3;
            if (dig1 >= 5) dig1 = dig1 + 3;
            if (dig2 >= 5) dig2 = dig2 + 3;
            {dig2, dig1, dig0, shift} = {dig2, dig1, dig0, shift} << 1;
        end
    end

    // =======================================================
    // Conversor de dígito (0–F) a 7 segmentos
    // =======================================================
    function [6:0] seg7;
        input [3:0] bcd;
        case (bcd)
            4'h0: seg7 = 7'b1000000;
            4'h1: seg7 = 7'b1111001;
            4'h2: seg7 = 7'b0100100;
            4'h3: seg7 = 7'b0110000;
            4'h4: seg7 = 7'b0011001;
            4'h5: seg7 = 7'b0010010;
            4'h6: seg7 = 7'b0000010;
            4'h7: seg7 = 7'b1111000;
            4'h8: seg7 = 7'b0000000;
            4'h9: seg7 = 7'b0010000;
            4'hA: seg7 = 7'b0001000;
            4'hB: seg7 = 7'b0000011;
            4'hC: seg7 = 7'b1000110;
            4'hD: seg7 = 7'b0100001;
            4'hE: seg7 = 7'b0000110;
            4'hF: seg7 = 7'b0001110;
            default: seg7 = 7'b1111111; // apagado
        endcase
    endfunction

    // Conectar los displays con los dígitos ya convertidos
    assign HEX0 = seg7(dig0); // unidades
    assign HEX1 = seg7(dig1); // decenas
    assign HEX2 = seg7(dig2); // centenas

    // HEX3 muestra si es negativo o el modo de operación
    assign HEX3 = (val < 0) ? 7'b0111111 :  // "-" (solo segmento G encendido)
                  (KEY0)   ? 7'b1000001 :  // "U" para unsigned
                             7'b0010010 ;  // "S" (o parecido a un "5") para signed

endmodule
