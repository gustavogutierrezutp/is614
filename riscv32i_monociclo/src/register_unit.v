module register_unit(
  input wire CLK,               // Entrada de reloj
  input wire reset,
  input wire [4:0] rs1,        // Registro fuente 1 (5 bits)
  input wire [4:0] rs2,        // Registro fuente 2 (5 bits)
  input wire [4:0] rd,         // Registro destino (5 bits)
  input wire [31:0] DataWr,    // Datos a escribir (32 bits)
  input wire RuWr,             // Señal de habilitación de escritura
  output wire [31:0] Rus1,     // Salida del registro fuente 1 (32 bits)
  output wire [31:0] Rus2,      // Salida del registro fuente 2 (32 bits)
  output reg [31:0] x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, 
  x29, x30, x31

);

  reg [31:0] Ru [31:0];        // Conjunto de 32 registros, cada uno de 32 bits

  // Inicialización de los registros con valores de un archivo
  initial begin
    $readmemb("registros.txt", Ru);  // Cargar valores iniciales desde un archivo
	 /*x0 = 32'b0;
	 x1 = 32'b0;
	 x2 = 32'b0;
	 x3 = 32'b0;
	 x4 = 32'b0;
	 x5 = 32'b0;
	 x6 = 32'b0;
	 x7 = 32'b0;
	 x8 = 32'b0;
	 x9 = 32'b0;
	 x10 = 32'b0;
	 x11 = 32'b0;
	 x12 = 32'b0;
	 x13 = 32'b0;
	 x14 = 32'b0;
	 x15 = 32'b0;
	 x16 = 32'b0;
	 x17 = 32'b0;
	 x18 = 32'b0;
	 x19 = 32'b0;
	 x20 = 32'b0;
	 x21 = 32'b0;
	 x22 = 32'b0;
	 x23 = 32'b0;
	 x24 = 32'b0;
	 x25 = 32'b0;
	 x26 = 32'b0;
	 x27 = 32'b0;
	 x28 = 32'b0;
	 x29 = 32'b0;
	 x30 = 32'b0;
	 x31 = 32'b0;*/
  end

  // Asignación combinacional de los registros a las salidas
  assign Rus1 = Ru[rs1];       // Leer el registro rs1
  assign Rus2 = Ru[rs2];       // Leer el registro rs2
integer i;
 // Bloque secuencial para manejar escritura y reinicio
  always @(posedge CLK or posedge reset) begin
    if (reset) begin
      // Reiniciar todos los registros a 0 en el reset
      
      for (i = 0; i < 32; i = i + 1) begin
        Ru[i] <= 32'b0;
      end
		 
    end else if (RuWr && rd != 5'b0) begin
      // Escribir en el registro destino
      Ru[rd] <= DataWr;
		/*case (rd)
			 5'b00001: x1 = DataWr;   // Asignar DataWr a x1
			 5'b00010: x2 = DataWr;   // Asignar DataWr a x2
			 5'b00011: x3 = DataWr;   // Asignar DataWr a x3
			 5'b00100: x4 = DataWr;   // Asignar DataWr a x4
			 5'b00101: x5 = DataWr;   // Asignar DataWr a x5
			 5'b00110: x6 = DataWr;   // Asignar DataWr a x6
			 5'b00111: x7 = DataWr;   // Asignar DataWr a x7
			 5'b01000: x8 = DataWr;   // Asignar DataWr a x8
			 5'b01001: x9 = DataWr;   // Asignar DataWr a x9
			 5'b01010: x10 = DataWr;  // Asignar DataWr a x10
			 5'b01011: x11 = DataWr;  // Asignar DataWr a x11
			 5'b01100: x12 = DataWr;  // Asignar DataWr a x12
			 5'b01101: x13 = DataWr;  // Asignar DataWr a x13
			 5'b01110: x14 = DataWr;  // Asignar DataWr a x14
			 5'b01111: x15 = DataWr;  // Asignar DataWr a x15
			 5'b10000: x16 = DataWr;  // Asignar DataWr a x16
			 5'b10001: x17 = DataWr;  // Asignar DataWr a x17
			 5'b10010: x18 = DataWr;  // Asignar DataWr a x18
			 5'b10011: x19 = DataWr;  // Asignar DataWr a x19
			 5'b10100: x20 = DataWr;  // Asignar DataWr a x20
			 5'b10101: x21 = DataWr;  // Asignar DataWr a x21
			 5'b10110: x22 = DataWr;  // Asignar DataWr a x22
			 5'b10111: x23 = DataWr;  // Asignar DataWr a x23
			 5'b11000: x24 = DataWr;  // Asignar DataWr a x24
			 5'b11001: x25 = DataWr;  // Asignar DataWr a x25
			 5'b11010: x26 = DataWr;  // Asignar DataWr a x26
			 5'b11011: x27 = DataWr;  // Asignar DataWr a x27
			 5'b11100: x28 = DataWr;  // Asignar DataWr a x28
			 5'b11101: x29 = DataWr;  // Asignar DataWr a x29
			 5'b11110: x30 = DataWr;  // Asignar DataWr a x30
			 5'b11111: x31 = DataWr;  // Asignar DataWr a x31
			 default: ;               // Caso por defecto (no hace nada)
		endcase*/
    end
  end
  
  always @* begin
  
   x0 = Ru[0];
   x1 = Ru[1];
   x2 = Ru[2];
	 x3 = Ru[3];
		  x4 = Ru[4];
		  x5 = Ru[5];
		  x6 = Ru[6];
		  x7 = Ru[7];
		  x8 = Ru[8];
		  x9 = Ru[9];
		  x10 = Ru[10];
		  x11 = Ru[11];
		  x12 = Ru[12];
		  x13 = Ru[13];
		  x14 = Ru[14];
		  x15 = Ru[15];
		  x16 = Ru[16];
		  x17 = Ru[17];
		  x18 = Ru[18];
		  x19 = Ru[19];
		  x20 = Ru[20];
		  x21 = Ru[21];
		  x22 = Ru[22];
		  x23 = Ru[23];
		  x24 = Ru[24];
		  x25 = Ru[25];
		  x26 = Ru[26];
		  x27 = Ru[27];
		  x28 = Ru[28];
		  x29 = Ru[29];
		  x30 = Ru[30];
		  x31 = Ru[31];
	end

endmodule


