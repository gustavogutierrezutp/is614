// Memoria de Datos
module data_mem (
    input  logic clk, // Señal de reloj
    input  logic mem_read, // Señal de control: lectura
    input  logic mem_write, // Señal de control: escritura
    input  logic [31:0] addr, // Direccion de memoria
    input  logic [31:0] write_data, // Dato a escribir (store)
    output logic [31:0] read_data // Dato leido (load)
);

    logic [31:0] memory [0:1023];

    // Inicialización opcional (para simulación o depuracion)
    //initial begin
    //    integer i;
    //    for (i = 0; i < 1024; i++) begin
    //        memory[i] = 32'b0;
    //    end
    //end

    // Escritura en memoria (sincronica con el flanco positivo del reloj)
    always_ff @(posedge clk) begin
        if (mem_write) begin
            memory[addr[11:2]] <= write_data;
        end
    end

    // Lectura de memoria (combinacional)
    always_comb begin
        if (mem_read)
            read_data = memory[addr[11:2]];
        else
            read_data = 32'b0;
    end

endmodule
