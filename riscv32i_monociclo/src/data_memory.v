module data_memory(
  input wire DMWr,                      // Señal de control para escribir en la memoria
  input wire [2:0] DMCtrl,              // Señal de control para definir el tipo de acceso (byte, half word, word)
  input wire [31:0] Address,            // Dirección de memoria donde se leerá/escribirá
  input wire signed [31:0] DataWr,      // Dato a escribir en la memoria
  output reg signed [31:0] DataRd       // Dato leído desde la memoria
);

  // Definición del tamaño de la memoria
  parameter memory_size = 2**7;        // Tamaño de la memoria 
  reg [7:0] memory [memory_size - 1: 0]; // Memoria organizada en bloques de 8 bits

  // Escritura en la memoria
  // Este bloque se activa cada vez que hay un cambio en las señales del módulo
  always @(*) begin 
    if (DMWr == 1'b1) begin             // Si la señal de escritura está habilitada
      case (DMCtrl)
        // Escritura de un byte
        3'b000: begin 
          memory[Address] <= DataWr[7:0]; // Se escribe un byte en la dirección especificada
        end
        
        // Escritura de media palabra (half word)
        3'b001: begin 
          memory[Address] <= DataWr[7:0];       // Se escribe el primer byte en la dirección
          memory[Address+1] <= DataWr[15:8];    // Se escribe el segundo byte en la dirección + 1
        end
        
        // Escritura de una palabra completa (word)
        3'b010: begin
          memory[Address]     <= DataWr[7:0];   // Escribir el byte menos significativo (bits 0-7)
          memory[Address + 1] <= DataWr[15:8];  // Escribir el siguiente byte (bits 8-15)
          memory[Address + 2] <= DataWr[23:16]; // Escribir el siguiente byte (bits 16-23)
          memory[Address + 3] <= DataWr[31:24]; // Escribir el byte más significativo (bits 24-31)
        end
      endcase
    end    
  end

  // Lectura desde la memoria
  // Este bloque se activa para leer los datos de memoria basados en el tipo de acceso definido por DMCtrl
  always @(*) begin
    case (DMCtrl)
      // Lectura de un byte
      3'b000: begin
        DataRd <= {{24{memory[Address][7]}}, memory[Address]}; // Lectura de un byte y extensión del signo
      end
      
      // Lectura de media palabra (half word)
      3'b001: begin
        DataRd <= {{16{memory[Address+1][7]}}, memory[Address+1], memory[Address]}; // Lectura de dos bytes y extensión del signo
      end
      
      // Lectura de una palabra completa (word)
      3'b010: begin
        DataRd <= {memory[Address+3], memory[Address+2], memory[Address+1], memory[Address]}; // Lectura de 4 bytes en secuencia
      end
      
      // Lectura de un byte sin signo (unsigned byte)
      3'b100: begin
        DataRd <= {24'b0, memory[Address]}; // Lectura de un byte y extensión con ceros
      end
      
      // Lectura de media palabra sin signo (unsigned half word)
      3'b101: begin
        DataRd <= {16'b0, memory[Address+1], memory[Address]}; // Lectura de dos bytes y extensión con ceros
      end
      
      // Si no se reconoce el DMCtrl, el valor de lectura es indeterminado
      default: DataRd <= 32'bx;
    endcase
  end
  
endmodule

