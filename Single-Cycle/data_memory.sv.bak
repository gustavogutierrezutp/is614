module data_memory (
    input  wire        clk,
    input  wire [31:0] address,   // Dirección de acceso
    input  wire [31:0] DMWR,      // Dato a escribir
    input  wire [2:0]  DMCTRL,    // Tipo de acceso (LB/LH/LW/LBU/LHU/SB/SH/SW)
    input  wire        mem_write, // Habilita escritura
    output reg  [31:0] Datard     // Dato leído
);

    reg [31:0] memory [0:1023];
    
  
    wire [9:0] word_addr  = address[11:2];
    wire [1:0] byte_offset = address[1:0];

    
       
        $display("data_memory: reading init file program_data.hex...");
        $readmemh("C:/Users/tomas/Documents/GitHub/Assembler/Assembler/program_data.hex", memory);
        $display("data_memory: finished reading init file (if present)");
    end

   
    reg [31:0] read_word;

    // --- ESCRITURA Y LECTURA SINCRÓNICA ---
    always @(posedge clk) begin
       
        if (mem_write) begin
            case (DMCTRL)
                // SB: guarda byte
                3'b000: begin
                    case (byte_offset)
                        2'b00: memory[word_addr][7:0]   <= DMWR[7:0];
                        2'b01: memory[word_addr][15:8]  <= DMWR[7:0];
                        2'b10: memory[word_addr][23:16] <= DMWR[7:0];
                        2'b11: memory[word_addr][31:24] <= DMWR[7:0];
                    endcase
                end

                // SH: guarda half
                3'b001: begin
                    case (byte_offset[1])
                        1'b0: memory[word_addr][15:0]  <= DMWR[15:0];
                        1'b1: memory[word_addr][31:16] <= DMWR[15:0];
                    endcase
                end

                // SW: guarda palabra completa
                3'b010: memory[word_addr] <= DMWR;

                // Otros casos no escriben
                default: ;
            endcase
        end

        // Leer palabra sincronizada (se actualiza cada ciclo)
        read_word <= memory[word_addr];
    end

    // --- SALIDA: extracción de bytes/halves desde la palabra leída (combinacional) ---
    always @(*) begin
        case (DMCTRL)
            // LB: carga byte con signo
            3'b000: begin
                case (byte_offset)
                    2'b00: Datard = {{24{read_word[7]}},  read_word[7:0]};
                    2'b01: Datard = {{24{read_word[15]}}, read_word[15:8]};
                    2'b10: Datard = {{24{read_word[23]}}, read_word[23:16]};
                    2'b11: Datard = {{24{read_word[31]}}, read_word[31:24]};
                endcase
            end

            // LH: carga half con signo
            3'b001: begin
                case (byte_offset[1])
                    1'b0: Datard = {{16{read_word[15]}}, read_word[15:0]};
                    1'b1: Datard = {{16{read_word[31]}}, read_word[31:16]};
                endcase
            end

            // LW: carga palabra completa
            3'b010: Datard = read_word;

            // LBU: carga byte sin signo
            3'b100: begin
                case (byte_offset)
                    2'b00: Datard = {24'b0, read_word[7:0]};
                    2'b01: Datard = {24'b0, read_word[15:8]};
                    2'b10: Datard = {24'b0, read_word[23:16]};
                    2'b11: Datard = {24'b0, read_word[31:24]};
                endcase
            end

            // LHU: carga half sin signo
            3'b101: begin
                case (byte_offset[1])
                    1'b0: Datard = {16'b0, read_word[15:0]};
                    1'b1: Datard = {16'b0, read_word[31:16]};
                endcase
            end

            // Valor por defecto
            default: Datard = 32'h00000000;
        endcase
    end

endmodule
