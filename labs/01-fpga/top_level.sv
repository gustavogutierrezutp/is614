module top_level (
    input  logic [9:0] SW,
    input  logic       KEY0,       // 1 = unsigned, 0 = signed (2C)
    output logic [9:0] LEDR,
    output logic [6:0] HEX0, HEX1, HEX2, HEX3
);

    assign LEDR = SW;

    // Zero-extend para UNSIGNED (0..1023)
    logic [10:0]          u_val;
    // Sign-extend para SIGNED (-512..+511)
    logic signed [10:0]   s_val;
    logic signed [11:0]   value;
    logic [11:0]          abs_value;
    logic [11:0]          hex_value;

    // Conversor HEX → 7 segmentos (igual que antes)
    function automatic logic [6:0] hex_to_7seg(input logic [3:0] h);
        case (h)
            4'h0: hex_to_7seg = 7'b1000000; 4'h1: hex_to_7seg = 7'b1111001;
            4'h2: hex_to_7seg = 7'b0100100; 4'h3: hex_to_7seg = 7'b0110000;
            4'h4: hex_to_7seg = 7'b0011001; 4'h5: hex_to_7seg = 7'b0010010;
            4'h6: hex_to_7seg = 7'b0000010; 4'h7: hex_to_7seg = 7'b1111000;
            4'h8: hex_to_7seg = 7'b0000000; 4'h9: hex_to_7seg = 7'b0010000;
            4'hA: hex_to_7seg = 7'b0001000; 4'hB: hex_to_7seg = 7'b0000011;
            4'hC: hex_to_7seg = 7'b1000110; 4'hD: hex_to_7seg = 7'b0100001;
            4'hE: hex_to_7seg = 7'b0000110; 4'hF: hex_to_7seg = 7'b0001110;
            default: hex_to_7seg = 7'b1111111;
        endcase
    endfunction

    always_comb begin
        u_val = {1'b0, SW};                 // 0 + 10 bits  -> 11 bits
        s_val = $signed({SW[9], SW});       // signo + 10 bits -> 11 bits

        // Selección de interpretación
        value = KEY0 ? $signed(u_val) : s_val;

        // Valor absoluto para mostrar y signo en HEX3
        abs_value = (value < 0) ? -value : value;
        hex_value = abs_value[11:0];

        HEX0 = hex_to_7seg(hex_value[3:0]);
        HEX1 = hex_to_7seg(hex_value[7:4]);
        HEX2 = hex_to_7seg(hex_value[11:8]);
        HEX3 = (value < 0) ? 7'b0111111 : 7'b1111111; // “–” o apagado
    end
endmodule
