module top_level(
    input wire clk,   
	 input wire clk_fpga,
    output wire [7:0] VGA_R,     // Salida color rojo (8 bits)
    output wire [7:0] VGA_G,     // Salida color verde (8 bits)
    output wire [7:0] VGA_B,     // Salida color azul (8 bits)
    output wire VGA_CLK,         // Reloj VGA
    output wire VGA_SYNC_N,      // Sincronización VGA (siempre en bajo)
    output wire VGA_BLANK_N,     // Señal de blanking
    output wire VGA_HS,          // Sincronización horizontal
    output wire VGA_VS           // Sincronización vertical
);

    // Señales del procesador
    wire [31:0] nextpc, pc, bsum, instruction, mux3a1;
    wire [31:0] rus1, rus2, immext, mux2a1alua, mux2a1alub;
    wire [31:0] alures, datamemory;
    wire [4:0] brop;
    wire [3:0] aluop;
    wire [2:0] immsrc, dmctrl;
    wire [1:0] rudataWrsrc;
    wire aluasrc, alubsrc, ruwr, nextpcsrc, dmwr, clk_vga;

    // VGA: Señales adicionales
    wire [9:0] pixel_x, pixel_y;     // Coordenadas actuales del pixel
    wire video_on;                   // Indica si estamos en la región visible
    wire [7:0] char_code;            // Código ASCII del carácter
    wire [3:0] row;                  // Fila del patrón del carácter
    wire [7:0] char_line;            // Línea del patrón del carácter (salida ROM)

    // División del reloj: 50 MHz a 25 MHz para VGA
    clock_divider clkdiv (
        .clk_in(clk_fpga),                // Entrada: reloj del sistema (50 MHz)
        .clk_out(clk_vga)            // Salida: reloj VGA (25 MHz)
    );

    // Asignar el reloj VGA a la salida correspondiente
    assign VGA_CLK = clk_vga;

    // Sincronización VGA
    vga_sync vga_sync_inst (
        .clk(clk_vga),               // Reloj VGA (25 MHz)
        .hsync(VGA_HS),              // Sincronización horizontal
        .vsync(VGA_VS),              // Sincronización vertical
        .video_on(video_on),         // Región visible
        .pixel_x(pixel_x),           // Coordenada X del pixel
        .pixel_y(pixel_y)            // Coordenada Y del pixel
    );

    // ROM de caracteres
    char_rom char_rom_inst (
        .char_code(char_code),       // Código ASCII del carácter
        .row(row),                   // Fila específica del patrón
        .char_line(char_line)        // Línea del patrón del carácter (salida)
    );

    // Generación de píxeles VGA
    pixel_gen pixel_gen_inst (
        .pixel_x(pixel_x),           // Coordenada X del pixel
        .pixel_y(pixel_y),           // Coordenada Y del pixel
        .video_on(video_on),         // Región visible
        .char_line(char_line),       // Línea del carácter
        .pc_value(pc),               // *** Añadimos el valor del PC ***
        .VGA_R(VGA_R),               // Salida: rojo
        .VGA_G(VGA_G),               // Salida: verde
        .VGA_B(VGA_B)                // Salida: azul
    );

    // Procesador: Componentes internos
    pc program_counter (
        .clk(clk),                   // Reloj
        .NextPC(nextpc),             // Siguiente PC
        .Pc(pc)                      // PC actual
    );

    sum4 sum (
        .Asum(pc),                   // Valor del PC actual
        .Bsum(bsum)                  // Resultado PC + 4
    );

    instruction_memory instructionmemory (
        .Address(pc),                // Dirección de instrucción
        .Instruction(instruction)    // Instrucción recuperada
    );

    control_unit controlunit (
        .OpCode(instruction[6:0]),
        .Funct3(instruction[14:12]),
        .Funct7(instruction[31:25]),
        .ImmSrc(immsrc),
        .ALUASrc(aluasrc),
        .ALUBSrc(alubsrc),
        .ALUOp(aluop),
        .DMWr(dmwr),
        .DMCtrl(dmctrl),
        .RUDataWrSrc(rudataWrsrc),
        .RUWr(ruwr),
        .BrOp(brop)
    );

    register_unit unidadderegistros (
        .CLK(clk),
        .rs1(instruction[19:15]),
        .rs2(instruction[24:20]),
        .rd(instruction[11:7]),
        .DataWr(mux3a1),
        .RuWr(ruwr),
        .Rus1(rus1),
        .Rus2(rus2)
    );

    imm_generator immgen (
        .Inst(instruction),
        .ImmSrc(immsrc),
        .ImmExt(immext)
    );

    branch_unit branchunit (
        .A(rus1),
        .B(rus2),
        .BrOp(brop),
        .NextPCSrc(nextpcsrc)
    );

    mux_2 mux_2_1_alu_a (
        .A(rus1),
        .B(pc),
        .select(aluasrc),
        .Out(mux2a1alua)
    );

    mux_2 mux_2_1_alu_b (
        .A(rus2),
        .B(immext),
        .select(alubsrc),
        .Out(mux2a1alub)
    );

    alu alu (
        .A(mux2a1alua),
        .B(mux2a1alub),
        .ALUOp(aluop),
        .ALURes(alures)
    );

    mux_2 mux2a1nextpc (
        .A(bsum),
        .B(alures),
        .select(nextpcsrc),
        .Out(nextpc)
    );

    data_memory datamemory_1 (
        .DMWr(dmwr),
        .DMCtrl(dmctrl),
        .Address(alures),
        .DataWr(rus2),
        .DataRd(datamemory)
    );

    mux_3 mux3a1_1 (
        .A(bsum),
        .B(datamemory),
        .C(alures),
        .select(rudataWrsrc),
        .Out(mux3a1)
    );

    // Señales VGA adicionales
    assign VGA_SYNC_N = 0;          // Sincronización en bajo
    assign VGA_BLANK_N = video_on;  // Señal de blanking

endmodule

