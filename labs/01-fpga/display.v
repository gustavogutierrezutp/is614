module display( 
   input wire [9:0] SWITCHES,       
   input wire BUTTON,               
   output wire [9:0] LEDS,           
   output reg [6:0] HEX_UNIDADES,   
   output reg [6:0] HEX_DECENAS,     
   output reg [6:0] HEX_CENTENAS,    
   output reg [6:0] HEX_MILES       
);

   
   assign LEDS = SWITCHES; 
	

   wire [15:0] valor_original_ext;
   wire [15:0] valor_signed;
   reg  [15:0] valor_final;

   reg [3:0] digito_unidades, digito_decenas, digito_centenas, digito_miles;
	
   assign valor_original_ext = {6'b0, SWITCHES};


   assign valor_signed = {{6{SWITCHES[9]}}, SWITCHES};

   always @(*) begin
      if (BUTTON == 1'b0) 
         valor_final = valor_signed;  
      else 
         valor_final = valor_original_ext; 
   end

   always @(*) begin
      digito_unidades = valor_final[3:0];        
      digito_decenas  = valor_final[7:4];         
      digito_centenas = valor_final[11:8]; 
      digito_miles    = valor_final[15:12];

      HEX_UNIDADES = binario_a_7seg(digito_unidades);
      HEX_DECENAS  = binario_a_7seg(digito_decenas);
      HEX_CENTENAS = binario_a_7seg(digito_centenas);
      HEX_MILES    = binario_a_7seg(digito_miles);
   end

   function [6:0] binario_a_7seg;
      input [3:0] dig;
      begin
         case(dig)
            4'b0000: binario_a_7seg = 7'b1000000; //0
            4'b0001: binario_a_7seg = 7'b1111001; //1
            4'b0010: binario_a_7seg = 7'b0100100; //2
            4'b0011: binario_a_7seg = 7'b0110000; //3
            4'b0100: binario_a_7seg = 7'b0011001; //4
            4'b0101: binario_a_7seg = 7'b0010010; //5
            4'b0110: binario_a_7seg = 7'b0000010; //6
            4'b0111: binario_a_7seg = 7'b1111000; //7
            4'b1000: binario_a_7seg = 7'b0000000; //8
            4'b1001: binario_a_7seg = 7'b0010000; //9
            4'b1010: binario_a_7seg = 7'b0001000; //A
            4'b1011: binario_a_7seg = 7'b0000011; //B
            4'b1100: binario_a_7seg = 7'b1000110; //C
            4'b1101: binario_a_7seg = 7'b0100001; //D
            4'b1110: binario_a_7seg = 7'b0000110; //E
            4'b1111: binario_a_7seg = 7'b0001110; //F
            default: binario_a_7seg = 7'b1111111; // apagado
         endcase
      end
   endfunction

endmodule
