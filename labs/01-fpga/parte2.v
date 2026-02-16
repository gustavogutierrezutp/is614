
module parte2(
	input [3:0] switchesO,
	input [3:0] switches_1O,
	input [1:0] switches_2O,
	input boton,
	output [6:0] segmentos,
	output [6:0] segmentos_1, 
	output [6:0] segmentos_2,
	output [9:0] leds,
	output [6:0] segmentosAdicional1,
	output [6:0] segmentosAdicional2,
	output [6:0] segmentosAdicional3
	
);

	

wire[9:0]original = {switches_2O, switches_1O, switchesO};//se juntan para poder sumarle el bit

assign leds = original;//encender los leds

wire[11:0]complementoA2 = ~original + 1'b1;//se le aplica el complemento A2

wire[11:0]final	= (boton == 1'b1)? complementoA2 : original;
//si el boton esta apretado se deja como final el del complementoA2 y si no pues el original


wire [3:0] switches = final[3:0];
wire [3:0] switches_1 = final[7:4];
wire [3:0] switches_2 = final[11:8];
//se reasignan los valores de los switches en 2 paquetes de 4 y uno de 2 y ya gg well done



assign segmentosAdicional1 = (boton == 1'b1)? 7'b0001110 : 7'b1000000;
assign segmentosAdicional2 = (boton == 1'b1)? 7'b0001110 : 7'b1000000;
assign segmentosAdicional3 = (boton == 1'b1)? 7'b0001110 : 7'b1000000;
//si se aplica el complemento a2 entonces los otros 3 leds quedan en f y si no en 0


//primer display
assign segmentos  =  (switches == 4'b0000)? 7'b1000000://0
							(switches == 4'b0001)? 7'b1111001://1
							(switches == 4'b0010)? 7'b0100100://2
							(switches == 4'b0011)? 7'b0110000://3
							(switches == 4'b0100)? 7'b0011001://4
							(switches == 4'b0101)? 7'b0010010://5
							(switches == 4'b0110)? 7'b0000010://6
							(switches == 4'b0111)? 7'b1111000://7
							(switches == 4'b1000)? 7'b0000000://8
							(switches == 4'b1001)? 7'b0010000://9
							(switches == 4'b1010)? 7'b0001000://A
							(switches == 4'b1011)? 7'b0000011://B
							(switches == 4'b1100)? 7'b1000110://C
							(switches == 4'b1101)? 7'b0100001://D
							(switches == 4'b1110)? 7'b0000110://E
							(switches == 4'b1111)? 7'b0001110://F
							                       7'b1111111;//todo apagado, no se usa basicamente nunca
	
//segundo display	
assign segmentos_1  =   (switches_1 == 4'b0000)? 7'b1000000://0
								(switches_1 == 4'b0001)? 7'b1111001://1
								(switches_1 == 4'b0010)? 7'b0100100://2
								(switches_1 == 4'b0011)? 7'b0110000://3
								(switches_1 == 4'b0100)? 7'b0011001://4
								(switches_1 == 4'b0101)? 7'b0010010://5
								(switches_1 == 4'b0110)? 7'b0000010://6
								(switches_1 == 4'b0111)? 7'b1111000://7
								(switches_1 == 4'b1000)? 7'b0000000://8
								(switches_1 == 4'b1001)? 7'b0010000://9
								(switches_1 == 4'b1010)? 7'b0001000://A
								(switches_1 == 4'b1011)? 7'b0000011://B
								(switches_1 == 4'b1100)? 7'b1000110://C
								(switches_1 == 4'b1101)? 7'b0100001://D
								(switches_1 == 4'b1110)? 7'b0000110://E
								(switches_1 == 4'b1111)? 7'b0001110://F
							                            7'b1111111;//todo apagado, no se usa basicamente nunca
	
//tercer display	
assign segmentos_2  =   (switches_2 == 4'b0000)? 7'b1000000://0
								(switches_2 == 4'b0001)? 7'b1111001://1
								(switches_2 == 4'b0010)? 7'b0100100://2
								(switches_2 == 4'b0011)? 7'b0110000://3
								(switches_2 == 4'b0100)? 7'b0011001://4
								(switches_2 == 4'b0101)? 7'b0010010://5
								(switches_2 == 4'b0110)? 7'b0000010://6
								(switches_2 == 4'b0111)? 7'b1111000://7
								(switches_2 == 4'b1000)? 7'b0000000://8
								(switches_2 == 4'b1001)? 7'b0010000://9
								(switches_2 == 4'b1010)? 7'b0001000://A
								(switches_2 == 4'b1011)? 7'b0000011://B
								(switches_2 == 4'b1100)? 7'b1000110://C
								(switches_2 == 4'b1101)? 7'b0100001://D
								(switches_2 == 4'b1110)? 7'b0000110://E
								(switches_2 == 4'b1111)? 7'b0001110://F
							                            7'b1111111;//todo apagado, no se usa basicamente nunca

endmodule