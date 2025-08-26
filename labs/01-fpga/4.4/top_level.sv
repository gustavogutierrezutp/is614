module top_level (
    input  logic [9:0] SW,        // Interruptores de entrada
    input  logic       KEY0,      // Selector de modo: 1 = sin signo, 0 = con signo
    output logic [9:0] LEDR,      // Reflejo directo de los switches
    output logic [6:0] HEX0, HEX1, HEX2, HEX3 // Displays de 7 segmentos
);

    // Reflejar los interruptores en los LEDs
    assign LEDR = SW;

    // Variables intermedias
    logic [9:0] valor_unsigned;       // Valor sin signo
    logic signed [10:0] valor_signed; // Valor con signo (2's complemento)
    logic signed [11:0] valor_final;  // Valor que se mostrará

    // Determinar si usamos valor con signo o sin signo
    always_comb begin
        valor_unsigned = SW;
        valor_signed   = SW;

        if (KEY0)
            valor_final = valor_unsigned; // modo sin signo
        else
            valor_final = valor_signed;   // modo con signo
    end

    // Tarea para convertir un dígito decimal a 7 segmentos
    task automatic decimal_to_7seg(input int digito, output logic [6:0] seg);
        case (digito)
            0: seg = 7'b1000000;
            1: seg = 7'b1111001;
            2: seg = 7'b0100100;
            3: seg = 7'b0110000;
            4: seg = 7'b0011001;
            5: seg = 7'b0010010;
            6: seg = 7'b0000010;
            7: seg = 7'b1111000;
            8: seg = 7'b0000000;
            9: seg = 7'b0010000;
            default: seg = 7'b1111111; // Apagado si el dígito es inválido
        endcase
    endtask

    // Separar los dígitos y actualizar los displays
    always_comb begin
        int valor_abs;
        logic [3:0] dig0, dig1, dig2, dig3;

        // Tomar valor absoluto para separar dígitos
        valor_abs = (valor_final < 0) ? -valor_final : valor_final;

        // Separar en unidades, decenas, centenas y millares
        dig0 = valor_abs % 10;
        dig1 = (valor_abs / 10) % 10;
        dig2 = (valor_abs / 100) % 10;
        dig3 = (valor_abs / 1000) % 10;

        // Asignar a displays
        decimal_to_7seg(dig0, HEX0);
        decimal_to_7seg(dig1, HEX1);
        decimal_to_7seg(dig2, HEX2);

        // Mostrar signo si es negativo
        if (valor_final < 0)
            HEX3 = 7'b0111111; // "-" solo segmento g encendido
        else
            decimal_to_7seg(dig3, HEX3);
    end

endmodule