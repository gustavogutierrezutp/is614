module top_level (
    input  logic [9:0] SW,
    output logic [9:0] LEDR,
    output logic [6:0] HEX0, HEX1, HEX2, HEX3
);

    // Reflejo directo de switches en LEDs
    assign LEDR = SW;

    // Expandir a 16 bits (por comodidad)
    logic [15:0] value;
    assign value = SW;

    // Conversión a 7 segmentos (activos en bajo)
    function automatic [6:0] to7seg(input logic [3:0] nibble);
        case (nibble)
            4'h0: to7seg = 7'b1000000;
            4'h1: to7seg = 7'b1111001;
            4'h2: to7seg = 7'b0100100;
            4'h3: to7seg = 7'b0110000;
            4'h4: to7seg = 7'b0011001;
            4'h5: to7seg = 7'b0010010;
            4'h6: to7seg = 7'b0000010;
            4'h7: to7seg = 7'b1111000;
            4'h8: to7seg = 7'b0000000;
            4'h9: to7seg = 7'b0010000;
            4'hA: to7seg = 7'b0001000;
            4'hB: to7seg = 7'b0000011;
            4'hC: to7seg = 7'b1000110;
            4'hD: to7seg = 7'b0100001;
            4'hE: to7seg = 7'b0000110;
            4'hF: to7seg = 7'b0001110;
            default: to7seg = 7'b1111111;
        endcase
    endfunction

    always_comb begin
        HEX0 = to7seg(value[3:0]);   // dígito menos significativo
        HEX1 = to7seg(value[7:4]);   // siguiente nibble
        HEX2 = to7seg(value[9:8]);   // solo 2 bits, igual se muestra
        HEX3 = 7'b1111111;           // apagado
    end
endmodule
