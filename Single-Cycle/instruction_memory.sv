
module instruction_memory(

    input  logic [31:0] address,        
    output logic [31:0] instruction 
	 
);

    // Memoria ROM de 32 palabras de 32 bits
    logic [31:0] mem [0:31];

    initial begin

        $readmemh("C:/Users/santi/OneDrive/Escritorio/Datos/Programacion/Assembler/program.hex", mem);
		  
    end
	 
    assign instruction = mem[address[31:2]];

endmodule
