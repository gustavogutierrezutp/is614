// Módulo para la memoria de instrucciones
module instruction_memory(
    input wire [31:0] Address,           // Dirección de 32 bits
    output reg [31:0] Instruction         // Instrucción de salida de 32 bits
);
	 
	 reg [7:0] Matriz [31:0];

    // Inicialización de la memoria con el contenido de Instructions.txt
    initial begin 
        $readmemh("instructions_hex.hex", Matriz); // Leer las instrucciones desde el archivo
    end
  
    //Sacamos la intruccion completa de 8 en 8 bits para sacar los 32 bits
    always @* begin
        Instruction <= {Matriz[Address], Matriz[Address+1], Matriz[Address+2], Matriz[Address+3]}; 
    end
  
endmodule
