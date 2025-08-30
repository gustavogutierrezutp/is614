module top_level (                            // Declaración del módulo principal llamado "top_level"
    input  logic [9:0] SW,       // Entrada de 10 switches que representan el valor binario
    input  logic       KEY0,     // Entrada de un botón/tecla: selecciona modo con signo o sin signo
    output logic [9:0] LEDR,     // Salida hacia 10 LEDs que reflejan directamente el estado de los switches
    output logic [6:0] HEX0, HEX1, HEX2, HEX3 // Salida hacia 4 displays de 7 segmentos
);

    // -------------------------------
    // Señales internas
    // -------------------------------
    logic signed [10:0] signed_value;   // Registro para almacenar el valor de los switches interpretado con signo (2's complemento)
    logic        [9:0] unsigned_value;  // Registro para almacenar el valor de los switches interpretado sin signo
    logic signed [11:0] number;         // Registro final que contendrá el valor que se mostrará (con o sin signo)

    // -------------------------------
    // Reflejo directo de switches en LEDs
    // -------------------------------
    assign LEDR = SW;                   // Copia directamente el valor de los switches en los LEDs (reflejo visual)

    // -------------------------------
    // Selección de modo (con signo o sin signo)
    // -------------------------------
    always_comb begin                   // Bloque combinacional que se recalcula en todo momento
        unsigned_value = SW;            // Guarda los switches como número sin signo
        signed_value   = SW;            // Guarda los switches como número con signo (interpreta bit más significativo como signo)

        if (KEY0)                       // Si KEY0 está en 1 → usar valor sin signo
            number = unsigned_value;    // Asigna "number" con el valor sin signo
        else                            // Si KEY0 está en 0 → usar valor con signo
            number = signed_value;      // Asigna "number" con el valor con signo
    end

    // -------------------------------
    // Conversión decimal a 7 segmentos
    // -------------------------------
    task automatic to7seg(input int digit, output logic [6:0] seg); // Tarea que recibe un dígito decimal y entrega su codificación en 7 segmentos
        case (digit)                   // Según el valor del dígito, selecciona el patrón de segmentos
            0: seg = 7'b1000000;       // Representación del número "0"
            1: seg = 7'b1111001;       // Representación del número "1"
            2: seg = 7'b0100100;       // Representación del número "2"
            3: seg = 7'b0110000;       // Representación del número "3"
            4: seg = 7'b0011001;       // Representación del número "4"
            5: seg = 7'b0010010;       // Representación del número "5"
            6: seg = 7'b0000010;       // Representación del número "6"
            7: seg = 7'b1111000;       // Representación del número "7"
            8: seg = 7'b0000000;       // Representación del número "8"
            9: seg = 7'b0010000;       // Representación del número "9"
            default: seg = 7'b1111111; // Apaga el display si el valor no es válido
        endcase
    endtask

    // -------------------------------
    // Separación de dígitos y despliegue
    // -------------------------------
    always_comb begin                   // Bloque combinacional para descomponer el número en dígitos y mostrarlos
        int abs_val;                    // Variable temporal para almacenar valor absoluto
        logic [3:0] d0, d1, d2, d3;     // Variables para los dígitos decimales individuales (0–9)

        // valor absoluto para separar dígitos
        if (number < 0)                 // Si el número es negativo
            abs_val = -number;          // Convierte a valor positivo (valor absoluto)
        else
            abs_val = number;           // Si es positivo lo deja igual

        // extracción de dígitos decimales
        d0 = abs_val % 10;              // Dígito de las unidades
        d1 = (abs_val / 10) % 10;       // Dígito de las decenas
        d2 = (abs_val / 100) % 10;      // Dígito de las centenas
        d3 = (abs_val / 1000) % 10;     // Dígito de los millares

        // asignación a displays
        to7seg(d0, HEX0);               // Muestra las unidades en HEX0
        to7seg(d1, HEX1);               // Muestra las decenas en HEX1
        to7seg(d2, HEX2);               // Muestra las centenas en HEX2

        if (number < 0)                 // Si el número es negativo
            HEX3 = 7'b0111111;          // Muestra un "-" en el display más a la izquierda
        else
            to7seg(d3, HEX3);           // Si es positivo, muestra los millares en HEX3
    end

endmodule                                // Fin del módulo
