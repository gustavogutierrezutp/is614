module instruction_memory(
  input  [31:0] address,
  output [31:0] instruction
);
  reg [31:0] memory[0:31];  
  
  initial begin
    // Leer archivo de instrucciones en formato hexadecimal
    $readmemh("instrucciones.txt", memory);
  end

  assign instruction = memory[address[31:2]];
  
endmodule