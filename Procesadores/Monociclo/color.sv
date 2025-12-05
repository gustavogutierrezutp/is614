module color(
  input clock,
  input rst_n,
  
  input [31:0] pc_value,
  input [31:0] instruction,
  input [31:0] alu_result,
  input [31:0] reg_data1,
  input [31:0] reg_data2,
  
  input [31:0] imm_value,
  input [31:0] mem_data_out,
  input [31:0] mem_address,
  input [4:0]  alu_op,
  input        reg_write_en,
  input        mem_write_en,
  
  input  AluASrc,
  input  AluBSrc,
  input  [2:0] ImmSrc,
  input  [2:0] DMCtrl,
  input  [31:0] DMOut,
  input  [31:0] RU_DataWr,
  input  [1:0] RUDataWrSrc,
  input  [31:0] AluA,
  input  [31:0] AluB,
  input  [31:0] AluA_mux,
  input  [31:0] AluB_mux,

  input        Branch,
  input  [4:0] BrOp,
  input        PCSrc,
  input  [31:0] pc_plus_4,
  
  input        EBreak,

  input [31:0] registers [0:31],
  input [7:0] memory [0:31],
  input [31:0] instructions [0:31],
  
  output reg [7:0] vga_red,
  output reg [7:0] vga_green,
  output reg [7:0] vga_blue,
  output vga_hsync,
  output vga_vsync,
  output vga_clock
);

  // Señales VGA
  wire [10:0] x;
  wire [9:0]  y;
  wire videoOn;
  wire vgaclk;

  clock1280x800 vgaclock(
    .clock50(clock),
    .reset(rst_n),
    .vgaclk(vgaclk)
  );

  assign vga_clock = vgaclk;

  vga_controller_1280x800 ctrl(
    .clk(vgaclk),
    .reset(rst_n),
    .video_on(videoOn),
    .hsync(vga_hsync),
    .vsync(vga_vsync),
    .hcount(x),
    .vcount(y)
  );


  // Fuente 8x16
  wire [7:0] ascii_code;
  wire [3:0] row_in_char;
  wire [2:0] col_in_char;
  wire pixel_on;

  font_renderer font_inst (
      .clk(vgaclk),
      .ascii_code(ascii_code),
      .row_in_char(row_in_char),
      .col_in_char(col_in_char),
      .pixel_on(pixel_on)
  );


  // Parámetros de layout - 4 COLUMNAS
  parameter CHAR_W = 8;
  parameter CHAR_H = 16;
  parameter LINE_SPACING = 18;
  parameter CHARS_PER_LINE = 20;
  
  // Columna 1: Estado del procesador
  parameter COL1_X = 250;
  parameter COL1_Y = 20;
  
  // Columna 2: Memoria del programa
  parameter COL2_X = 500;
  parameter COL2_Y = 20;
  
  // Columna 3: Registros x0-x31
  parameter COL3_X = 750;
  parameter COL3_Y = 20;
  
  // Columna 4: Memoria
  parameter COL4_X = 1000;
  parameter COL4_Y = 20;
  
  // Mensaje ebreak
  parameter EBREAK_X = 250;
  parameter EBREAK_Y = 440;
  

  // Buffers de texto

  // Columna 1: Estado
  reg [7:0] col1_line [0:22] [0:19];
  
  // Columna 2: Memoria del programa
  reg [7:0] col2_line [0:32] [0:19];
  
  // Columna 3: Registros x16-x31
  reg [7:0] col3_line [0:32] [0:19];
  
  // Columna 4: Memoria 
  reg [7:0] col4_line [0:32] [0:19];
  
  
  // Buffer para mensaje de ebreak
  reg [7:0] ebreak_line [0:27];
  reg ebreak_active;
  
  // Detectar y mantener EBREAK
  always @(posedge vgaclk) begin
    if (!EBreak)
      ebreak_active <= 1'b0;
    else if (EBreak)
      ebreak_active <= 1'b1;
  end
  
  // Inicialización del mensaje
  initial begin
    ebreak_line[0]  = 8'd69;  // E
    ebreak_line[1]  = 8'd76;  // L
    ebreak_line[2]  = 8'd32;  // espacio
    ebreak_line[3]  = 8'd80;  // P
    ebreak_line[4]  = 8'd82;  // R
    ebreak_line[5]  = 8'd79;  // O
    ebreak_line[6]  = 8'd71;  // G
    ebreak_line[7]  = 8'd82;  // R
    ebreak_line[8]  = 8'd65;  // A
    ebreak_line[9]  = 8'd77;  // M
    ebreak_line[10] = 8'd65;  // A
    ebreak_line[11] = 8'd32;  // espacio
    ebreak_line[12] = 8'd72;  // H
    ebreak_line[13] = 8'd65;  // A
    ebreak_line[14] = 8'd32;  // espacio
    ebreak_line[15] = 8'd84;  // T
    ebreak_line[16] = 8'd69;  // E
    ebreak_line[17] = 8'd82;  // R
    ebreak_line[18] = 8'd77;  // M
    ebreak_line[19] = 8'd73;  // I
    ebreak_line[20] = 8'd78;  // N
    ebreak_line[21] = 8'd65;  // A
    ebreak_line[22] = 8'd68;  // D
    ebreak_line[23] = 8'd79;  // O
    for (integer k = 24; k < 28; k = k + 1) ebreak_line[k] = 8'd32;
  end

  
  // Función para convertir nibble a hex ASCII
  function [7:0] nibble_to_hex;
    input [3:0] nibble;
    begin
      nibble_to_hex = (nibble < 10) ? (8'd48 + nibble) : (8'd65 + nibble - 10);
    end
  endfunction
  

  // Función para convertir número decimal a ASCII
  function [7:0] dec_to_ascii_tens;
    input [4:0] num;
    begin
      dec_to_ascii_tens = (num >= 10) ? (8'd48 + num / 10) : 8'd32;
    end
  endfunction
  
  function [7:0] dec_to_ascii_ones;
    input [4:0] num;
    begin
      dec_to_ascii_ones = 8'd48 + (num % 10);
    end
  endfunction

 
  // Señal de actualización
  parameter V_TOTAL = 831;
  reg frame_update;
  always @(posedge vgaclk) begin
    frame_update <= (y == V_TOTAL - 1) && (x == 0);
  end


  // Actualizar buffers de texto
  integer i, j, idx;
  
  always @(posedge vgaclk) begin
    if (frame_update) begin
			// COLUMNA 1: ESTADO DEL PROCESADOR
			// Línea 0: PC
			col1_line[0][0] <= 8'd80;  //P
			col1_line[0][1] <= 8'd67;  //C
			col1_line[0][2] <= 8'd58;  //:
			col1_line[0][3] <= 8'd32;  // espacio
			col1_line[0][4] <= 8'd48;  // 0
			col1_line[0][5] <= 8'd120; // x
			col1_line[0][6] <= nibble_to_hex(pc_value[31:28]);
			col1_line[0][7] <= nibble_to_hex(pc_value[27:24]);
			col1_line[0][8] <= nibble_to_hex(pc_value[23:20]);
			col1_line[0][9] <= nibble_to_hex(pc_value[19:16]);
			col1_line[0][10] <= nibble_to_hex(pc_value[15:12]);
			col1_line[0][11] <= nibble_to_hex(pc_value[11:8]);
			col1_line[0][12] <= nibble_to_hex(pc_value[7:4]);
			col1_line[0][13] <= nibble_to_hex(pc_value[3:0]);
			for (i = 14; i < 20; i = i + 1) col1_line[0][i] <= 8'd32;
			
			// Línea 1: INST
			col1_line[1][0] <= 8'd73;  //I
			col1_line[1][1] <= 8'd78;  //N
			col1_line[1][2] <= 8'd83;  //S
			col1_line[1][3] <= 8'd84;  //T
			col1_line[1][4] <= 8'd58;  //:
			col1_line[1][5] <= 8'd48;  //0
			col1_line[1][6] <= 8'd120; //x
			col1_line[1][7] <= nibble_to_hex(instruction[31:28]);
			col1_line[1][8] <= nibble_to_hex(instruction[27:24]);
			col1_line[1][9] <= nibble_to_hex(instruction[23:20]);
			col1_line[1][10] <= nibble_to_hex(instruction[19:16]);
			col1_line[1][11] <= nibble_to_hex(instruction[15:12]);
			col1_line[1][12] <= nibble_to_hex(instruction[11:8]);
			col1_line[1][13] <= nibble_to_hex(instruction[7:4]);
			col1_line[1][14] <= nibble_to_hex(instruction[3:0]);
			for (i = 15; i < 20; i = i + 1) col1_line[1][i] <= 8'd32;
			
			// Línea 2: Separador
			for (i = 0; i < 18; i = i + 1) col1_line[2][i] <= 8'd45; //-
			for (i = 18; i < 20; i = i + 1) col1_line[2][i] <= 8'd32;
			
			// Línea 3: RS1
			col1_line[3][0] <= 8'd82;  //R
			col1_line[3][1] <= 8'd83;  //S
			col1_line[3][2] <= 8'd49;  //1
			col1_line[3][3] <= 8'd58;  //:
			col1_line[3][4] <= 8'd48;  //0
			col1_line[3][5] <= 8'd120; //x
			col1_line[3][6] <= nibble_to_hex(reg_data1[31:28]);
			col1_line[3][7] <= nibble_to_hex(reg_data1[27:24]);
			col1_line[3][8] <= nibble_to_hex(reg_data1[23:20]);
			col1_line[3][9] <= nibble_to_hex(reg_data1[19:16]);
			col1_line[3][10] <= nibble_to_hex(reg_data1[15:12]);
			col1_line[3][11] <= nibble_to_hex(reg_data1[11:8]);
			col1_line[3][12] <= nibble_to_hex(reg_data1[7:4]);
			col1_line[3][13] <= nibble_to_hex(reg_data1[3:0]);
			for (i = 14; i < 20; i = i + 1) col1_line[3][i] <= 8'd32;
			
			// Línea 4: RS2
			col1_line[4][0] <= 8'd82;  //R 
			col1_line[4][1] <= 8'd83;  //S
			col1_line[4][2] <= 8'd50;  //2
			col1_line[4][3] <= 8'd58;  //:
			col1_line[4][4] <= 8'd48;  //0
			col1_line[4][5] <= 8'd120; //x
			col1_line[4][6] <= nibble_to_hex(reg_data2[31:28]);
			col1_line[4][7] <= nibble_to_hex(reg_data2[27:24]);
			col1_line[4][8] <= nibble_to_hex(reg_data2[23:20]);
			col1_line[4][9] <= nibble_to_hex(reg_data2[19:16]);
			col1_line[4][10] <= nibble_to_hex(reg_data2[15:12]);
			col1_line[4][11] <= nibble_to_hex(reg_data2[11:8]);
			col1_line[4][12] <= nibble_to_hex(reg_data2[7:4]);
			col1_line[4][13] <= nibble_to_hex(reg_data2[3:0]);
			for (i = 14; i < 20; i = i + 1) col1_line[4][i] <= 8'd32;
			
			// Línea 5: IMM
			col1_line[5][0] <= 8'd73;  //I
			col1_line[5][1] <= 8'd77;  //M
			col1_line[5][2] <= 8'd77;  //M
			col1_line[5][3] <= 8'd58;  //:
			col1_line[5][4] <= 8'd48;  //0
			col1_line[5][5] <= 8'd120; //x
			col1_line[5][6] <= nibble_to_hex(imm_value[31:28]);
			col1_line[5][7] <= nibble_to_hex(imm_value[27:24]);
			col1_line[5][8] <= nibble_to_hex(imm_value[23:20]);
			col1_line[5][9] <= nibble_to_hex(imm_value[19:16]);
			col1_line[5][10] <= nibble_to_hex(imm_value[15:12]);
			col1_line[5][11] <= nibble_to_hex(imm_value[11:8]);
			col1_line[5][12] <= nibble_to_hex(imm_value[7:4]);
			col1_line[5][13] <= nibble_to_hex(imm_value[3:0]);
			for (i = 14; i < 20; i = i + 1) col1_line[5][i] <= 8'd32;
			
			// Línea 6: Separador
			for (i = 0; i < 18; i = i + 1) col1_line[6][i] <= 8'd45;
			for (i = 18; i < 20; i = i + 1) col1_line[6][i] <= 8'd32;
			
			// Línea 7: ALU
			col1_line[7][0] <= 8'd65;  
			col1_line[7][1] <= 8'd76;  
			col1_line[7][2] <= 8'd85;
			col1_line[7][3] <= 8'd58;  
			col1_line[7][4] <= 8'd48;  
			col1_line[7][5] <= 8'd120;
			col1_line[7][6] <= nibble_to_hex(alu_result[31:28]);
			col1_line[7][7] <= nibble_to_hex(alu_result[27:24]);
			col1_line[7][8] <= nibble_to_hex(alu_result[23:20]);
			col1_line[7][9] <= nibble_to_hex(alu_result[19:16]);
			col1_line[7][10] <= nibble_to_hex(alu_result[15:12]);
			col1_line[7][11] <= nibble_to_hex(alu_result[11:8]);
			col1_line[7][12] <= nibble_to_hex(alu_result[7:4]);
			col1_line[7][13] <= nibble_to_hex(alu_result[3:0]);
			for (i = 14; i < 20; i = i + 1) col1_line[7][i] <= 8'd32;
			
			// Línea 8: OP
			col1_line[8][0] <= 8'd79;  
			col1_line[8][1] <= 8'd80;  
			col1_line[8][2] <= 8'd58;
			col1_line[8][3] <= 8'd48;  
			col1_line[8][4] <= 8'd120;
			col1_line[8][5] <= nibble_to_hex({3'b0, alu_op[4]});
			col1_line[8][6] <= nibble_to_hex(alu_op[3:0]);
			for (i = 7; i < 20; i = i + 1) col1_line[8][i] <= 8'd32;
			
			// Línea 9: Separador
			for (i = 0; i < 18; i = i + 1) col1_line[9][i] <= 8'd45;
			for (i = 18; i < 20; i = i + 1) col1_line[9][i] <= 8'd32;
			
			// Línea 10: MEM
			col1_line[10][0] <= 8'd77;  
			col1_line[10][1] <= 8'd69;  
			col1_line[10][2] <= 8'd77;
			col1_line[10][3] <= 8'd58;  
			col1_line[10][4] <= 8'd48;  
			col1_line[10][5] <= 8'd120;
			col1_line[10][6] <= nibble_to_hex(mem_data_out[31:28]);
			col1_line[10][7] <= nibble_to_hex(mem_data_out[27:24]);
			col1_line[10][8] <= nibble_to_hex(mem_data_out[23:20]);
			col1_line[10][9] <= nibble_to_hex(mem_data_out[19:16]);
			col1_line[10][10] <= nibble_to_hex(mem_data_out[15:12]);
			col1_line[10][11] <= nibble_to_hex(mem_data_out[11:8]);
			col1_line[10][12] <= nibble_to_hex(mem_data_out[7:4]);
			col1_line[10][13] <= nibble_to_hex(mem_data_out[3:0]);
			for (i = 14; i < 20; i = i + 1) col1_line[10][i] <= 8'd32;
			
			// Línea 11: CTRL
			col1_line[11][0] <= 8'd82;  //R
			col1_line[11][1] <= 8'd85;  //U
			col1_line[11][2] <= 8'd87;  //W
			col1_line[11][3] <= 8'd82;  //R
			col1_line[11][4] <= 8'd58;  //:
			col1_line[11][5] <= reg_write_en ? 8'd49 : 8'd48;
			col1_line[11][6] <= 8'd32;  //
			col1_line[11][7] <= 8'd68;  //D
			col1_line[11][8] <= 8'd77;  //M
			col1_line[11][9] <= 8'd87;  //W
			col1_line[11][10] <= 8'd82;  //R
			col1_line[11][11] <= 8'd58;  //:
			col1_line[11][12] <= mem_write_en ? 8'd49 : 8'd48;
			for (i = 13; i < 20; i = i + 1) col1_line[11][i] <= 8'd32;
			
			// Línea 12: ALUA_SRC / ALUB_SRC
			col1_line[12][0] <= 8'd65;  // A
			col1_line[12][1] <= 8'd83;  // S
			col1_line[12][2] <= 8'd82;  // R
			col1_line[12][3] <= 8'd67;  // C
			col1_line[12][4] <= 8'd58;  // :
			col1_line[12][5] <= AluASrc ? 8'd49 : 8'd48; // 1/0
			col1_line[12][6] <= 8'd32;
			col1_line[12][7] <= 8'd66;  // B
			col1_line[12][8] <= 8'd83;  // S
			col1_line[12][9] <= 8'd82;  // R
			col1_line[12][10] <= 8'd67; // C
			col1_line[12][11] <= 8'd58; // :
			col1_line[12][12] <= AluBSrc ? 8'd49 : 8'd48;
			for (i = 13; i < 20; i = i + 1) col1_line[12][i] <= 8'd32;

			// Línea 13: ImmSrc y DMCtrl
			col1_line[13][0] <= 8'd73;  // I
			col1_line[13][1] <= 8'd77;  // M
			col1_line[13][2] <= 8'd77;  // M
			col1_line[13][3] <= 8'd83;  // S
			col1_line[13][4] <= 8'd82;  // R
			col1_line[13][5] <= 8'd67;  // C
			col1_line[13][6] <= 8'd58;  // :
			col1_line[13][7] <= nibble_to_hex({1'b0, ImmSrc});
			col1_line[13][8] <= 8'd32;
			col1_line[13][9] <= 8'd68;  // D
			col1_line[13][10] <= 8'd77; // M
			col1_line[13][11] <= 8'd67; // C
			col1_line[13][12] <= 8'd58; // :
			col1_line[13][13] <= nibble_to_hex({1'b0, DMCtrl});
			for (i = 14; i < 20; i = i + 1) col1_line[13][i] <= 8'd32;

			// Línea 14: Separador
			for (i = 0; i < 18; i = i + 1) col1_line[14][i] <= 8'd45;
			for (i = 18; i < 20; i = i + 1) col1_line[14][i] <= 8'd32;

			// Línea 15: DMOut
			col1_line[15][0] <= 8'd68;  // D
			col1_line[15][1] <= 8'd77;  // M
			col1_line[15][2] <= 8'd79;  // O
			col1_line[15][3] <= 8'd85;  // U
			col1_line[15][4] <= 8'd84;  // T
			col1_line[15][5] <= 8'd58;  // :
			col1_line[15][6] <= nibble_to_hex(DMOut[31:28]);
			col1_line[15][7] <= nibble_to_hex(DMOut[27:24]);
			col1_line[15][8] <= nibble_to_hex(DMOut[23:20]);
			col1_line[15][9] <= nibble_to_hex(DMOut[19:16]);
			col1_line[15][10] <= nibble_to_hex(DMOut[15:12]);
			col1_line[15][11] <= nibble_to_hex(DMOut[11:8]);
			col1_line[15][12] <= nibble_to_hex(DMOut[7:4]);
			col1_line[15][13] <= nibble_to_hex(DMOut[3:0]);
			for (i = 14; i < 20; i = i + 1) col1_line[15][i] <= 8'd32;

			// Línea 16: RU_DataWr
			col1_line[16][0] <= 8'd82;  // R
			col1_line[16][1] <= 8'd85;  // U
			col1_line[16][2] <= 8'd68;  // D
			col1_line[16][3] <= 8'd87;  // W
			col1_line[16][4] <= 8'd82;  // R
			col1_line[16][5] <= 8'd58;  // :
			col1_line[16][6] <= nibble_to_hex(RU_DataWr[31:28]);
			col1_line[16][7] <= nibble_to_hex(RU_DataWr[27:24]);
			col1_line[16][8] <= nibble_to_hex(RU_DataWr[23:20]);
			col1_line[16][9] <= nibble_to_hex(RU_DataWr[19:16]);
			col1_line[16][10] <= nibble_to_hex(RU_DataWr[15:12]);
			col1_line[16][11] <= nibble_to_hex(RU_DataWr[11:8]);
			col1_line[16][12] <= nibble_to_hex(RU_DataWr[7:4]);
			col1_line[16][13] <= nibble_to_hex(RU_DataWr[3:0]);
			for (i = 14; i < 20; i = i + 1) col1_line[16][i] <= 8'd32;

			// Línea 17: ALUA / ALUB
			col1_line[17][0] <= 8'd65;  // A
			col1_line[17][1] <= 8'd76;  // L
			col1_line[17][2] <= 8'd85;  // U
			col1_line[17][3] <= 8'd65;  // A
			col1_line[17][4] <= 8'd58;  // :
			col1_line[17][5] <= nibble_to_hex(AluA[7:4]);
			col1_line[17][6] <= nibble_to_hex(AluA[3:0]);
			col1_line[17][7] <= 8'd32;
			col1_line[17][8] <= 8'd66;  // B
			col1_line[17][9] <= 8'd58;  // :
			col1_line[17][10] <= nibble_to_hex(AluB[7:4]);
			col1_line[17][11] <= nibble_to_hex(AluB[3:0]);
			for (i = 12; i < 20; i = i + 1) col1_line[17][i] <= 8'd32;

			// Línea 18: Mux A / Mux B
			col1_line[18][0] <= 8'd77;  // M
			col1_line[18][1] <= 8'd85;  // U
			col1_line[18][2] <= 8'd88;  // X
			col1_line[18][3] <= 8'd65;  // A
			col1_line[18][4] <= 8'd58;  // :
			col1_line[18][5] <= nibble_to_hex(AluA_mux[7:4]);
			col1_line[18][6] <= nibble_to_hex(AluA_mux[3:0]);
			col1_line[18][7] <= 8'd32;
			col1_line[18][8] <= 8'd66;  // B
			col1_line[18][9] <= 8'd58;  // :
			col1_line[18][10] <= nibble_to_hex(AluB_mux[7:4]);
			col1_line[18][11] <= nibble_to_hex(AluB_mux[3:0]);
			for (i = 12; i < 20; i = i + 1) col1_line[18][i] <= 8'd32;
			
			// Línea 19: Separador
			for (i = 0; i < 18; i = i + 1) col1_line[19][i] <= 8'd45; // -
			for (i = 18; i < 20; i = i + 1) col1_line[19][i] <= 8'd32;

			// Línea 20: Branch / PCSrc
			col1_line[20][0] <= 8'd66;  // B
			col1_line[20][1] <= 8'd82;  // R
			col1_line[20][2] <= 8'd58;  // :
			col1_line[20][3] <= Branch ? 8'd49 : 8'd48;  // 1/0
			col1_line[20][4] <= 8'd32;
			col1_line[20][5] <= 8'd80;  // P
			col1_line[20][6] <= 8'd67;  // C
			col1_line[20][7] <= 8'd83;  // S
			col1_line[20][8] <= 8'd82;  // R
			col1_line[20][9] <= 8'd67;  // C
			col1_line[20][10] <= 8'd58; // :
			col1_line[20][11] <= PCSrc ? 8'd49 : 8'd48;
			for (i = 12; i < 20; i = i + 1) col1_line[20][i] <= 8'd32;

			// Línea 21: BrOp y PC+4
			col1_line[21][0] <= 8'd66;  // B
			col1_line[21][1] <= 8'd82;  // R
			col1_line[21][2] <= 8'd79;  // O
			col1_line[21][3] <= 8'd80;  // P
			col1_line[21][4] <= 8'd58;  // :
			col1_line[21][5] <= nibble_to_hex({3'b0, BrOp[4]});
			col1_line[21][6] <= nibble_to_hex(BrOp[3:0]);
			for (i = 7; i < 20; i = i + 1) col1_line[21][i] <= 8'd32;

			// Línea 22: PC+4 (dirección de retorno para JAL/JALR)
			col1_line[22][0] <= 8'd80;  // P
			col1_line[22][1] <= 8'd67;  // C
			col1_line[22][2] <= 8'd43;  // +
			col1_line[22][3] <= 8'd52;  // 4
			col1_line[22][4] <= 8'd58;  // :
			col1_line[22][5] <= nibble_to_hex(pc_plus_4[31:28]);
			col1_line[22][6] <= nibble_to_hex(pc_plus_4[27:24]);
			col1_line[22][7] <= nibble_to_hex(pc_plus_4[23:20]);
			col1_line[22][8] <= nibble_to_hex(pc_plus_4[19:16]);
			col1_line[22][9] <= nibble_to_hex(pc_plus_4[15:12]);
			col1_line[22][10] <= nibble_to_hex(pc_plus_4[11:8]);
			col1_line[22][11] <= nibble_to_hex(pc_plus_4[7:4]);
			col1_line[22][12] <= nibble_to_hex(pc_plus_4[3:0]);
			for (i = 13; i < 20; i = i + 1) col1_line[22][i] <= 8'd32;

			
			// COLUMNA 2: INSTRUCCIONES
			col2_line[0][0]<=8'd73;  //I
			col2_line[0][1]<=8'd78;  //N
			col2_line[0][2]<=8'd83;  //S
			col2_line[0][3]<=8'd84;  //T
			col2_line[0][4]<=8'd82;  //R
			col2_line[0][5]<=8'd85;  //U
			col2_line[0][6]<=8'd67;  //C
			col2_line[0][7]<=8'd84;  //T
			col2_line[0][8]<=8'd73;  //I
			col2_line[0][9]<=8'd79;  //O
			col2_line[0][10]<=8'd78; //N
			col2_line[0][11]<=8'd83; //S
			for (i = 12; i < 18; i = i + 1) col2_line[0][i] <= 8'd32;
			
			for(idx = 0;idx<32;idx=idx+1) begin
			  col2_line[idx+1][0] <= 8'd91;  // [
			  col2_line[idx+1][1] <= dec_to_ascii_tens(idx);
			  col2_line[idx+1][2] <= dec_to_ascii_ones(idx);
			  col2_line[idx+1][3] <= 8'd93;  // ]
			  col2_line[idx+1][4] <= 8'd58;  // :
			  col2_line[idx+1][5]  <= nibble_to_hex(instructions[idx][31:28]);
			  col2_line[idx+1][6]  <= nibble_to_hex(instructions[idx][27:24]);
			  col2_line[idx+1][7]  <= nibble_to_hex(instructions[idx][23:20]);
			  col2_line[idx+1][8]  <= nibble_to_hex(instructions[idx][19:16]);
			  col2_line[idx+1][9]  <= nibble_to_hex(instructions[idx][15:12]);
			  col2_line[idx+1][10] <= nibble_to_hex(instructions[idx][11:8]);
			  col2_line[idx+1][11] <= nibble_to_hex(instructions[idx][7:4]);
			  col2_line[idx+1][12] <= nibble_to_hex(instructions[idx][3:0]);
			  for(i=13;i<18;i=i+1) col2_line[idx+1][i]<=8'd32;
			end
			
			// COLUMNA 3: REGISTROS x0-x31
			// Título
			col3_line[0][0]<=8'd82;  //R
			col3_line[0][1]<=8'd69;  //E
			col3_line[0][2]<=8'd71;  //G
			col3_line[0][3]<=8'd83;  //S
			col3_line[0][4]<=8'd32;  
			col3_line[0][5]<=8'd120; //x
			col3_line[0][6]<=8'd48;  //0
			col3_line[0][7]<=8'd48;  //0
			col3_line[0][8]<=8'd45;  //-
			col3_line[0][9]<=8'd120; //x
			col3_line[0][10]<=8'd51; //3
			col3_line[0][11]<=8'd49; //1
			for(i=12;i<18;i=i+1) col3_line[0][i]<=8'd32;
			
			for(idx=0;idx<32;idx=idx+1) begin
			  col3_line[idx+1][0]<=8'd120;
			  col3_line[idx+1][1]<=dec_to_ascii_tens(idx);
			  col3_line[idx+1][2]<=dec_to_ascii_ones(idx);
			  col3_line[idx+1][3]<=8'd58;
			  col3_line[idx+1][4]<=nibble_to_hex(registers[idx][31:28]);
			  col3_line[idx+1][5]<=nibble_to_hex(registers[idx][27:24]);
			  col3_line[idx+1][6]<=nibble_to_hex(registers[idx][23:20]);
			  col3_line[idx+1][7]<=nibble_to_hex(registers[idx][19:16]);
			  col3_line[idx+1][8]<=nibble_to_hex(registers[idx][15:12]);
			  col3_line[idx+1][9]<=nibble_to_hex(registers[idx][11:8]);
			  col3_line[idx+1][10]<=nibble_to_hex(registers[idx][7:4]);
			  col3_line[idx+1][11]<=nibble_to_hex(registers[idx][3:0]);
			  for(i=12;i<18;i=i+1) col3_line[idx+1][i]<=8'd32;
			end
			
			// COLUMNA 4: MEMORIA
			// Título
			col4_line[0][0] <= 8'd77;  col4_line[0][1] <= 8'd69;  col4_line[0][2] <= 8'd77;
			col4_line[0][3] <= 8'd79;  col4_line[0][4] <= 8'd82;  col4_line[0][5] <= 8'd89;
			for (i = 6; i < 20; i = i + 1) col4_line[0][i] <= 8'd32;
			
			// Memoria [0-31]
			for (idx = 0; idx < 32; idx = idx + 1) begin
			  col4_line[idx+1][0] <= 8'd91;  // [
			  col4_line[idx+1][1] <= dec_to_ascii_tens(idx);
			  col4_line[idx+1][2] <= dec_to_ascii_ones(idx);
			  col4_line[idx+1][3] <= 8'd93;  // ]
			  col4_line[idx+1][4] <= 8'd58;  // :
			  col4_line[idx+1][5] <= nibble_to_hex(memory[idx][7:4]);
			  col4_line[idx+1][6] <= nibble_to_hex(memory[idx][3:0]);
			  for (i = 7; i < 20; i = i + 1) col4_line[idx+1][i] <= 8'd32;
			end
    end 
  end

 
  // Lógica de renderizado
  
  // Detectar región del mensaje ebreak
  wire in_ebreak = ebreak_active &&
                   (x >= EBREAK_X && x < EBREAK_X + CHAR_W * 24) &&
                   (y >= EBREAK_Y && y < EBREAK_Y + CHAR_H);
  
  wire [4:0] char_ebreak = (x - EBREAK_X) / CHAR_W;
  wire [3:0] row_ebreak = (y - EBREAK_Y);
  
  // Detectar en que columna y línea estamos
  wire in_col1 = (x >= COL1_X && x < COL1_X + CHAR_W * CHARS_PER_LINE);
  wire in_col2 = (x >= COL2_X && x < COL2_X + CHAR_W * CHARS_PER_LINE);
  wire in_col3 = (x >= COL3_X && x < COL3_X + CHAR_W * CHARS_PER_LINE);
  wire in_col4 = (x >= COL4_X && x < COL4_X + CHAR_W * CHARS_PER_LINE);
  
  // Calcular línea y columna
  wire [5:0] line_num_col1 = (y - COL1_Y) / LINE_SPACING;
  wire [5:0] line_num_col2 = (y - COL2_Y) / LINE_SPACING;
  wire [5:0] line_num_col3 = (y - COL3_Y) / LINE_SPACING;
  wire [5:0] line_num_col4 = (y - COL4_Y) / LINE_SPACING;
  
  wire [4:0] char_col1 = (x - COL1_X) / CHAR_W;
  wire [4:0] char_col2 = (x - COL2_X) / CHAR_W;
  wire [4:0] char_col3 = (x - COL3_X) / CHAR_W;
  wire [4:0] char_col4 = (x - COL4_X) / CHAR_W;
  
  wire [3:0] row_in_line_col1 = (y - COL1_Y) % LINE_SPACING;
  wire [3:0] row_in_line_col2 = (y - COL2_Y) % LINE_SPACING;
  wire [3:0] row_in_line_col3 = (y - COL3_Y) % LINE_SPACING;
  wire [3:0] row_in_line_col4 = (y - COL4_Y) % LINE_SPACING;
  
  wire valid_col1 = in_col1 && (y >= COL1_Y) && (line_num_col1 < 23) && (row_in_line_col1 < CHAR_H);
  wire valid_col2 = in_col2 && (y >= COL2_Y) && (line_num_col2 < 33) && (row_in_line_col2 < CHAR_H);
  wire valid_col3 = in_col3 && (y >= COL3_Y) && (line_num_col3 < 33) && (row_in_line_col3 < CHAR_H);
  wire valid_col4 = in_col4 && (y >= COL4_Y) && (line_num_col4 < 33) && (row_in_line_col4 < CHAR_H);
  wire valid_ebreak = in_ebreak;
  
  // Seleccionar carácter ASCII
  reg [7:0] current_ascii;
  reg [3:0] current_row;
  reg [2:0] current_col;
  
  always @(*) begin
    if (valid_ebreak) begin
      current_ascii = ebreak_line[char_ebreak];
      current_row = row_ebreak;
      current_col = (x - EBREAK_X) % CHAR_W;
    end else if (valid_col1) begin
      current_ascii = col1_line[line_num_col1][char_col1];
      current_row = row_in_line_col1;
      current_col = (x - COL1_X) % CHAR_W;
    end else if (valid_col2) begin
      current_ascii = col2_line[line_num_col2][char_col2];
      current_row = row_in_line_col2;
      current_col = (x - COL2_X) % CHAR_W;
    end else if (valid_col3) begin
      current_ascii = col3_line[line_num_col3][char_col3];
      current_row = row_in_line_col3;
      current_col = (x - COL3_X) % CHAR_W;
    end else if (valid_col4) begin
      current_ascii = col4_line[line_num_col4][char_col4];
      current_row = row_in_line_col4;
      current_col = (x - COL4_X) % CHAR_W;
    end else begin
      current_ascii = 8'd32;
      current_row = 4'd0;
      current_col = 3'd0;
    end
  end
  
  assign ascii_code = current_ascii;
  assign row_in_char = current_row;
  assign col_in_char = current_col;


  // Color de salida
  wire inside_text = valid_col1 || valid_col2 || valid_col3 || valid_col4 || valid_ebreak;
  
  always @(*) begin
    if (~videoOn)
      {vga_red, vga_green, vga_blue} = 24'h000000;
    else if (valid_ebreak && pixel_on)
      {vga_red, vga_green, vga_blue} = 24'hFF0000;  // Mensaje EBREAK en rojo
    else if (inside_text && pixel_on)
      {vga_red, vga_green, vga_blue} = 24'h00FF00;  // Texto normal en verde
    else
      {vga_red, vga_green, vga_blue} = 24'h001020;  // Fondo azul oscuro
  end

endmodule


// Módulos auxiliares
module clock1280x800(clock50, reset, vgaclk);
  input clock50;
  input reset;
  output vgaclk;

  vgaClock clk(
    .ref_clk_clk(clock50),
    .ref_reset_reset(reset),
    .reset_source_reset(rst_n),
    .vga_clk_clk(vgaclk)
  );
endmodule

module vga_controller_1280x800 (
  input clk,
  input reset,
  output wire hsync,
  output wire vsync,
  output reg [10:0] hcount,
  output reg [9:0]  vcount,
  output video_on
);

  parameter H_VISIBLE = 1280;
  parameter H_FP      = 48;
  parameter H_SYNC    = 32;
  parameter H_BP      = 80;
  parameter H_TOTAL   = H_VISIBLE + H_FP + H_SYNC + H_BP;

  parameter V_VISIBLE = 800;
  parameter V_FP      = 3;
  parameter V_SYNC    = 6;
  parameter V_BP      = 22;
  parameter V_TOTAL   = V_VISIBLE + V_FP + V_SYNC + V_BP;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      hcount <= 0;
      vcount <= 0;
    end else begin
      if (hcount == H_TOTAL - 1) begin
        hcount <= 0;
        if (vcount == V_TOTAL - 1)
          vcount <= 0;
        else
          vcount <= vcount + 1;
      end else begin
        hcount <= hcount + 1;
      end
    end
  end

  assign hsync = (hcount >= H_VISIBLE + H_FP) && 
                 (hcount < H_VISIBLE + H_FP + H_SYNC);
  assign vsync = (vcount >= V_VISIBLE + V_FP) && 
                 (vcount < V_VISIBLE + V_FP + V_SYNC);
  assign video_on = (hcount < H_VISIBLE) && (vcount < V_VISIBLE);
endmodule
