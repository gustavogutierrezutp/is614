module data_memory (
    input        clk,            // reloj
    input [31:0] address,        // dirección (byte address)
    input [31:0] DatamW,         // dato a escribir
	 input [31:0] DMWR,
    input  [2:0] DMCTRL,         // control de tipo de acceso (funct3)
    input        mem_write,      // señal de escritura
    output reg [31:0] Datard     // dato leído
);

// ===============================================================
// Parámetros de memoria
// ===============================================================
parameter MEM_SIZE = 50;         
reg [31:0] memory [0:MEM_SIZE-1];

// ===============================================================
// Inicialización desde archivo HEX externo
// ===============================================================
initial begin
    $readmemh("C:/Users/tomas/Documents/GitHub/Lab-1/Assembler/program_data.hex", memory);
end

// ===============================================================
// Direccionamiento
// ===============================================================
wire [9:0] word_addr  = address[11:2];   // dirección por palabra
wire [1:0] byte_offset = address[1:0];   // desplazamiento de byte

// ===============================================================
// LECTURA ASÍNCRONA
// ===============================================================
always @(*) begin
    case (DMCTRL)

        // LB: carga byte con signo
        3'b000: begin
            case (byte_offset)
                2'b00: Datard = {{24{memory[word_addr][7]}},  memory[word_addr][7:0]};
                2'b01: Datard = {{24{memory[word_addr][15]}}, memory[word_addr][15:8]};
                2'b10: Datard = {{24{memory[word_addr][23]}}, memory[word_addr][23:16]};
                2'b11: Datard = {{24{memory[word_addr][31]}}, memory[word_addr][31:24]};
            endcase
        end

        // LH: carga half con signo
        3'b001: begin
            case (byte_offset[1])
                1'b0: Datard = {{16{memory[word_addr][15]}}, memory[word_addr][15:0]};
                1'b1: Datard = {{16{memory[word_addr][31]}}, memory[word_addr][31:16]};
            endcase
        end

        // LW: carga palabra completa
        3'b010: begin
            Datard = memory[word_addr];
        end

        // LBU: carga byte SIN signo
        3'b100: begin
            case (byte_offset)
                2'b00: Datard = {24'b0, memory[word_addr][7:0]};
                2'b01: Datard = {24'b0, memory[word_addr][15:8]};
                2'b10: Datard = {24'b0, memory[word_addr][23:16]};
                2'b11: Datard = {24'b0, memory[word_addr][31:24]};
            endcase
        end

        // LHU: carga half SIN signo
        3'b101: begin
            case (byte_offset[1])
                1'b0: Datard = {16'b0, memory[word_addr][15:0]};
                1'b1: Datard = {16'b0, memory[word_addr][31:16]};
            endcase
        end

        default: Datard = 32'h00000000;
    endcase
end

// ===============================================================
// ESCRITURA SINCRÓNICA
// ===============================================================
always @(posedge clk) begin
    if (mem_write) begin
        case (DMCTRL)

            // SB: store byte
            3'b000: begin
                case (byte_offset)
                    2'b00: memory[word_addr][7:0]   <= DatamW[7:0];
                    2'b01: memory[word_addr][15:8]  <= DatamW[7:0];
                    2'b10: memory[word_addr][23:16] <= DatamW[7:0];
                    2'b11: memory[word_addr][31:24] <= DatamW[7:0];
                endcase
            end

            // SH: store half
            3'b001: begin
                case (byte_offset[1])
                    1'b0: memory[word_addr][15:0]  <= DatamW[15:0];
                    1'b1: memory[word_addr][31:16] <= DatamW[15:0];
                endcase
            end

            // SW: store word
            3'b010: begin
                memory[word_addr] <= DatamW;
            end

            default: ;
        endcase
    end
end

endmodule