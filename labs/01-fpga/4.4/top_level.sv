module top_level (
    input  logic [9:0] SW,       // Interruptores
    input  logic       KEY0,     // Selector de modo
    output logic [9:0] LEDR,     // Reflejo
    output logic [6:0] HEX0, HEX1, HEX2, HEX3
);

    assign LEDR = SW; // reflejo en LEDs

    // Variable de valor interpretado
    logic signed [10:0] signed_value;  
    logic [9:0] unsigned_value;
    logic [11:0] number;  // valor final en decimal

    always_comb begin
        unsigned_value = SW;  // modo sin signo
        signed_value   = SW;  // modo con signo (2's complemento)

        if (KEY0) begin
            number = unsigned_value;   // sin signo
        end else begin
            number = signed_value;     // con signo
        end
    end

    // Conversión decimal a 7 segmentos
    task automatic to7seg(input int digit, output logic [6:0] seg);
        case (digit)
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
            default: seg = 7'b1111111;
        endcase
    endtask

    always_comb begin
        int abs_val;
        logic [3:0] d0, d1, d2, d3;

        // valor absoluto para separar dígitos
        if (number < 0)
            abs_val = -number;
        else
            abs_val = number;

        // Extraer dígitos decimales
        d0 = abs_val % 10;
        d1 = (abs_val / 10) % 10;
        d2 = (abs_val / 100) % 10;
        d3 = (abs_val / 1000) % 10;

        // Mostrar en displays
        to7seg(d0, HEX0);
        to7seg(d1, HEX1);
        to7seg(d2, HEX2);

        if (number < 0)
            HEX3 = 7'b0111111;  // signo "-" (solo segmento g encendido)
        else
            to7seg(d3, HEX3);
    end
endmodule
