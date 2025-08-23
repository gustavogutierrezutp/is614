
// Trabajo hecho por:
// Santiago Jaramillo Duque
// Tomas Marin Ariza

module top_level (

    // Entradas
    input  logic SW0, SW1, SW2, SW3, SW4, SW5, SW6, SW7, SW8, SW9,
    input  logic KEY0,

    // Salidas LEDs
    output logic LEDR0, LEDR1, LEDR2, LEDR3, LEDR4, 
                 LEDR5, LEDR6, LEDR7, LEDR8, LEDR9,
	 
    // Salidas displays de 7 segmentos (HEX0–HEX3)
    output logic HEX0_a, HEX0_b, HEX0_c, HEX0_d, HEX0_e, HEX0_f, HEX0_g,
    output logic HEX1_a, HEX1_b, HEX1_c, HEX1_d, HEX1_e, HEX1_f, HEX1_g,
    output logic HEX2_a, HEX2_b, HEX2_c, HEX2_d, HEX2_e, HEX2_f, HEX2_g,
    output logic HEX3_a, HEX3_b, HEX3_c, HEX3_d, HEX3_e, HEX3_f, HEX3_g
);

    // asignar leds a los switches.
	 
    assign {LEDR9,LEDR8,LEDR7,LEDR6,LEDR5,LEDR4,LEDR3,LEDR2,LEDR1,LEDR0} =
           {SW9, SW8, SW7, SW6, SW5, SW4, SW3, SW2, SW1, SW0};


    // Tomar el numero de los switches y decidir si van a ser con signo o no gracias a KEY0
  
    logic [9:0] switches;
    assign switches = {SW9,SW8,SW7,SW6,SW5,SW4,SW3,SW2,SW1,SW0};

    logic signed [9:0] signed_val;
    logic [9:0] unsigned_val;
    logic signed [10:0] value; // valor final

    assign signed_val   = switches;
    assign unsigned_val = switches;

    always_comb begin
        if (KEY0)
            value = unsigned_val; // unsigned
        else
            value = signed_val;   // signed (2’s complement)
    end
	 
	 
    // Convertir el valor a hexadecimal
   
    logic [3:0] digit0, digit1, digit2;
    logic negative;

    always_comb begin
        negative = 0;
        digit0   = 0;
        digit1   = 0;
        digit2   = 0;

        if (value < 0) begin
            negative = 1;
            digit0 = (-value)       % 16;
            digit1 = ((-value)>>4)  % 16;
            digit2 = ((-value)>>8)  % 16;
        end else begin
            digit0 = value        % 16;
            digit1 = (value >> 4) % 16;
            digit2 = (value >> 8) % 16;
        end
    end
		
   
    // Decodificador 7 segmentos
    // Active-low
  
    function automatic [6:0] hex_decoder(input [3:0] num);
        case(num)
            4'h0: hex_decoder = 7'b1000000;
            4'h1: hex_decoder = 7'b1111001;
            4'h2: hex_decoder = 7'b0100100;
            4'h3: hex_decoder = 7'b0110000;
            4'h4: hex_decoder = 7'b0011001;
            4'h5: hex_decoder = 7'b0010010;
            4'h6: hex_decoder = 7'b0000010;
            4'h7: hex_decoder = 7'b1111000;
            4'h8: hex_decoder = 7'b0000000;
            4'h9: hex_decoder = 7'b0010000;
            4'hA: hex_decoder = 7'b0001000;
            4'hB: hex_decoder = 7'b0000011;
            4'hC: hex_decoder = 7'b1000110;
            4'hD: hex_decoder = 7'b0100001;
            4'hE: hex_decoder = 7'b0000110;
            4'hF: hex_decoder = 7'b0001110;
            default: hex_decoder = 7'b1111111; // apagado porque es Active-low
        endcase
    endfunction

    // Signo negativo (solo segmento g encendido)
    function automatic [6:0] minus_decoder();
        minus_decoder = 7'b0111111;
    endfunction


    // Asignar displays

    logic [6:0] d0, d1, d2, d3;

    always_comb begin
        d0 = hex_decoder(digit0);
        d1 = hex_decoder(digit1);
        d2 = hex_decoder(digit2);
        d3 = (negative) ? minus_decoder() : 7'b1111111; // signo o apagado
    end

    // Conexión a pines
	 
    assign {HEX0_a,HEX0_b,HEX0_c,HEX0_d,HEX0_e,HEX0_f,HEX0_g} = d0;
    assign {HEX1_a,HEX1_b,HEX1_c,HEX1_d,HEX1_e,HEX1_f,HEX1_g} = d1;
    assign {HEX2_a,HEX2_b,HEX2_c,HEX2_d,HEX2_e,HEX2_f,HEX2_g} = d2;
    assign {HEX3_a,HEX3_b,HEX3_c,HEX3_d,HEX3_e,HEX3_f,HEX3_g} = d3;

endmodule
