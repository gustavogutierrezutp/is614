module parte2TB;
    wire [6:0] segmentos;
    wire [6:0] segmentos_1;
    wire [6:0] segmentos_2;
    wire [9:0] leds;
	 wire [6:0] segmentosAdicional1;
	 wire [6:0] segmentosAdicional2;
	 wire [6:0] segmentosAdicional3;

    reg [3:0] switchesO;
    reg [3:0] switches_1O;
    reg [1:0] switches_2O;
    reg boton;

    parte2 u0(
        .switchesO(switchesO),
        .switches_1O(switches_1O),
        .switches_2O(switches_2O),
        .boton(boton),
        .segmentos(segmentos),
        .segmentos_1(segmentos_1),
        .segmentos_2(segmentos_2),
        .leds(leds),
		  .segmentosAdicional1(segmentosAdicional1),
		  .segmentosAdicional2(segmentosAdicional2),
		  .segmentosAdicional3(segmentosAdicional3)
    );

    integer i;

    initial begin
        // -------------------------
        // Caso 1: boton = 0
        // -------------------------
        boton = 0;

        for (i = 0; i < 1024; i = i + 1) begin
            {switches_2O, switches_1O, switchesO} = i[9:0];
            #10;
        end

        // -------------------------
        // Caso 2: boton = 1
        // -------------------------
        boton = 1;

        for (i = 0; i < 1024; i = i + 1) begin
            {switches_2O, switches_1O, switchesO} = i[9:0];
            #10;
        end

        $stop; // detener simulación
    end
endmodule
