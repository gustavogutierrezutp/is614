// ============================================================
// color.sv — Módulo de Renderizado en VGA 1280x800
// Muestra en pantalla el estado interno del procesador RISC-V
// (señales internas, registros, memoria y estado del programa)
// ============================================================

module color (
    input  logic        clock,      // Reloj principal
    input  logic        rst,        // Reset global

    // ========================================================
    // ENTRADA DE 27 SEÑALES INTERNAS DEL CPU
    // (PC, instrucciones, decodificación, ALU, branch, memoria…)
    // ========================================================
    input  logic [31:0] next_pc_value,
    input  logic [31:0] address_value,
    input  logic [31:0] instr_value,
    input  logic [4:0]  rs1_idx,
    input  logic [4:0]  rs2_idx,
    input  logic [4:0]  rd_idx,
    input  logic [31:0] data_wr_value,
    input  logic        ru_wr_value,
    input  logic [2:0]  immsrc_value,
    input  logic [6:0]  opcode_value,
    input  logic [2:0]  funct3_value,
    input  logic [6:0]  funct7_value,
    input  logic [31:0] imm_value,
    input  logic [31:0] alu_a_value,
    input  logic [31:0] alu_b_value,
    input  logic [31:0] alu_res_value,
    input  logic [3:0]  alu_op_value,
    input  logic        alu_asrc_value,
    input  logic        alu_bsrc_value,
    input  logic [2:0]  br_op_value,
    input  logic        branch_value,
    input  logic [31:0] dm_wr_value,
    input  logic [2:0]  dm_ctrl_value,
    input  logic [31:0] data_rd_value,
    input  logic [1:0]  ru_wr_src_value,

    input  logic [31:0] branch_a_value, // Valor RS1 para branch
    input  logic [31:0] branch_b_value, // Valor RS2 para branch

    // ========================================================
    // ESTADO COMPLETO DEL CPU
    // ========================================================
    input  logic [31:0] register_values [0:31],   // Registros x0–x31
    input  logic [31:0] memory_values   [0:31],   // Memoria simulada 32 palabras
    input  logic        program_ended,            // Señal END

    // ========================================================
    // SALIDA VGA 1280x800
    // ========================================================
    output logic [7:0]  vga_red,
    output logic [7:0]  vga_green,
    output logic [7:0]  vga_blue,
    output logic        vga_hsync,
    output logic        vga_vsync,
    output logic        vga_clock
);


    // ========================================================
    // GENERACIÓN DE SEÑALES VGA
    // ========================================================
    logic [10:0] x;              // Coordenada X del pixel actual
    logic [9:0]  y;              // Coordenada Y del pixel actual
    logic        videoOn;        // Señal: pixel válido
    logic        vgaclk;         // Reloj VGA 1280x800

    // Generador del reloj VGA
    clock1280x800 vgaclock (
        .clock50(clock),
        .reset(rst),
        .vgaclk(vgaclk)
    );
    assign vga_clock = vgaclk;

    // Controlador VGA
    vga_controller_1280x800 ctrl (
        .clk(vgaclk),
        .reset(rst),
        .video_on(videoOn),
        .hsync(vga_hsync),
        .vsync(vga_vsync),
        .hcount(x),
        .vcount(y)
    );


    // ========================================================
    // Agrupación de señales del CPU para mostrarlas como texto
    // ========================================================
    localparam int NSIGNALS = 27;
    logic [31:0] signal_values [0:NSIGNALS-1];

    // Cargamos cada señal en un arreglo ordenado para iterar en pantalla
    always_comb begin
        signal_values[0]  = next_pc_value;
        signal_values[1]  = address_value;
        signal_values[2]  = instr_value;
        signal_values[3]  = {27'd0, rs1_idx};
        signal_values[4]  = {27'd0, rs2_idx};
        signal_values[5]  = {27'd0, rd_idx};
        signal_values[6]  = data_wr_value;
        signal_values[7]  = {31'd0, ru_wr_value};
        signal_values[8]  = {29'd0, immsrc_value};
        signal_values[9]  = {25'd0, opcode_value};
        signal_values[10] = {29'd0, funct3_value};
        signal_values[11] = {25'd0, funct7_value};
        signal_values[12] = imm_value;
        signal_values[13] = alu_a_value;
        signal_values[14] = alu_b_value;
        signal_values[15] = alu_res_value;
        signal_values[16] = {28'd0, alu_op_value};
        signal_values[17] = {31'd0, alu_asrc_value};
        signal_values[18] = {31'd0, alu_bsrc_value};
        signal_values[19] = {29'd0, br_op_value};
        signal_values[20] = {31'd0, branch_value};
        signal_values[21] = dm_wr_value;
        signal_values[22] = {29'd0, dm_ctrl_value};
        signal_values[23] = data_rd_value;
        signal_values[24] = {30'd0, ru_wr_src_value};
        signal_values[25] = branch_a_value;
        signal_values[26] = branch_b_value;
    end


    // ========================================================
    // Conversión nibble → ASCII HEX (0–F)
    // ========================================================
    function automatic logic [7:0] hex_to_ascii(input logic [3:0] n);
        return (n < 10) ? (8'd48 + n) : (8'd55 + n);   // 0–9 / A–F
    endfunction


    // ========================================================
    // Posicionamiento del texto en la pantalla
    // ========================================================
    localparam int CHAR_W = 8;          // Ancho del caracter
    localparam int TOP_Y  = 140;        // Offset vertical del panel
    localparam int LEFT_X = 200;        // Columna señales
    localparam int REG_X  = 600;        // Columna registros
    localparam int MEM_X  = 1000;       // Columna memoria

    localparam int NAME_LEN = 12;       // Largo del nombre "NEXT_PC:  "
    localparam int VALUE_X  = LEFT_X + (CHAR_W * NAME_LEN) + CHAR_W;


    // ========================================================
    // Lista de nombres de señales a mostrar
    // ========================================================
    localparam logic [NAME_LEN*8-1:0] signal_names [0:NSIGNALS-1] = '{
        "NEXT_PC:    ", "ADDRESS:    ", "INSTRUCT:   ", "RS1:        ", "RS2:        ",
        "RD:         ", "DATAWR:     ", "RUWR:       ", "IMMSRC:     ", "OPCODE:     ",
        "FUNCT3:     ", "FUNCT7:     ", "IMM:        ", "A:          ", "B:          ",
        "ALURESULT:  ", "ALUOP:      ", "ALUASRC:    ", "ALUBSRC:    ", "BROP:       ",
        "BRANCH:     ", "DMWR:       ", "DMCTRL:     ", "DATARD:     ", "RUWRSRC:    ",
        "BRANCH_A:   ", "BRANCH_B:   "
    };


    // ========================================================
    // Selección del caracter actual a dibujar dependiendo
    // de la columna activa (señales, registros o memoria)
    // ========================================================
    logic [7:0] char_code_next;  // Código ASCII del caracter actual
    logic [3:0] row_idx;         // Fila del caracter (fuente 8x16)
    logic [2:0] bit_idx_next;    // Pixel vertical dentro del caracter
    logic       text_on_next;    // Señal: estamos dibujando texto?

    always_comb begin
        int line_idx, char_pos_x, val_offset, reg_digit;
        logic [3:0] nibble_val;
        logic [7:0] mem_addr_byte;

        // Valores por defecto
        char_code_next = 8'h20;      // Espacio
        text_on_next   = 0;

        row_idx     = y[3:0];
        bit_idx_next = x[2:0];

        // Número de línea dentro del panel
        line_idx = (y - TOP_Y) >> 4;

        // ----------------------------------------------------
        // COLUMNA 1: SEÑALES DEL CPU
        // ----------------------------------------------------
        if (x >= LEFT_X && x < (LEFT_X + 300) && y >= TOP_Y) begin

            if (line_idx >= 0 && line_idx < NSIGNALS) begin
                text_on_next = 1;

                char_pos_x = (x - LEFT_X) >> 3;

                // Parte izquierda → nombre de la señal
                if (x < VALUE_X) begin
                    if (char_pos_x < NAME_LEN)
                        char_code_next =
                            signal_names[line_idx][8*(NAME_LEN-1-char_pos_x) +: 8];
                end

                // Parte derecha → valor en HEX
                else begin
                    val_offset = (x - VALUE_X) >> 3;

                    if (val_offset < 8) begin
                        nibble_val =
                            signal_values[line_idx][(7 - val_offset)*4 +: 4];

                        char_code_next = hex_to_ascii(nibble_val);
                    end
                end
            end
        end

        // ----------------------------------------------------
        // COLUMNA 2: REGISTROS x0–x31
        // ----------------------------------------------------
        else if (x >= REG_X && x < (REG_X + 300) && y >= TOP_Y) begin

            if (line_idx < 32) begin
                text_on_next = 1;

                char_pos_x = (x - REG_X) >> 3;

                case (char_pos_x)
                    0: char_code_next = "x"; // letra x
                    1: char_code_next = (line_idx >= 10) ?
                                        (8'd48 + (line_idx/10)) : 8'd48;
                    2: char_code_next = 8'd48 + (line_idx % 10);
                    3: char_code_next = ":";
                    4: char_code_next = " ";
                    default: begin
                        reg_digit = char_pos_x - 5;
                        if (reg_digit < 8) begin
                            nibble_val =
                                register_values[line_idx][(7-reg_digit)*4 +: 4];
                            char_code_next = hex_to_ascii(nibble_val);
                        end
                    end
                endcase
            end
        end

        // ----------------------------------------------------
        // COLUMNA 3: MEMORIA (32 palabras)
        // ----------------------------------------------------
        else if (x >= MEM_X && x < (MEM_X + 300) && y >= TOP_Y) begin

            if (line_idx < 32) begin
                text_on_next = 1;

                char_pos_x = (x - MEM_X) >> 3;

                // Dirección mostrada como MEMXY:
                mem_addr_byte = line_idx[5:0] << 2;

                case (char_pos_x)
                    0: char_code_next = "M";
                    1: char_code_next = "E";
                    2: char_code_next = "M";
                    3: char_code_next = hex_to_ascii(mem_addr_byte[7:4]);
                    4: char_code_next = hex_to_ascii(mem_addr_byte[3:0]);
                    5: char_code_next = ":";
                    6: char_code_next = " ";

                    // Luego → 32 bits HEX
                    default: begin
                        reg_digit = char_pos_x - 7;
                        if (reg_digit < 8) begin
                            nibble_val =
                                memory_values[line_idx][(7-reg_digit)*4 +: 4];
                            char_code_next = hex_to_ascii(nibble_val);
                        end
                    end
                endcase
            end
        end

        // ----------------------------------------------------
        // Mensaje FINAL “END” si el programa terminó
        // ----------------------------------------------------
        else if (program_ended && y >= 80 && y < 96) begin
            if (x >= 600 && x < 608) begin text_on_next = 1; char_code_next = "E"; end
            else if (x >= 608 && x < 616) begin text_on_next = 1; char_code_next = "N"; end
            else if (x >= 616 && x < 624) begin text_on_next = 1; char_code_next = "D"; end
        end
    end


    // ========================================================
    // Fuente (ROM ASCII 8x16)
    // ========================================================
    logic [10:0] font_addr;
    logic [7:0]  font_data;

    assign font_addr = {char_code_next, row_idx};

    font_rom font_inst (
        .clk(vgaclk),
        .addr(font_addr),
        .data(font_data)
    );


    // ========================================================
    // PIPELINE de un ciclo para sincronizar el texto
    // con el pixel actual
    // ========================================================
    logic [2:0] bit_idx_reg;
    logic       text_on_reg;
    logic       video_on_reg;

    always_ff @(posedge vgaclk) begin
        if (rst) begin
            bit_idx_reg  <= 0;
            text_on_reg  <= 0;
            video_on_reg <= 0;

            vga_red   <= 0;
            vga_green <= 0;
            vga_blue  <= 0;

        end else begin
            bit_idx_reg  <= bit_idx_next;
            text_on_reg  <= text_on_next;
            video_on_reg <= videoOn;

            // Si estamos en video activo + zona de texto + bit=1 → color blanco
            if (video_on_reg && text_on_reg && font_data[7 - bit_idx_reg]) begin
                vga_red   <= 8'hFF;
                vga_green <= 8'hFF;
                vga_blue  <= 8'hFF;
            end
            else begin
                vga_red   <= 8'h00;
                vga_green <= 8'h00;
                vga_blue  <= 8'h00;
            end
        end
    end

endmodule
