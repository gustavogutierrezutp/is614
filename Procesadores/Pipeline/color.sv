module color(
  input clock,
  input rst_n,
  
  // ETAPA IF
  input [31:0] if_pc,
  input [31:0] if_instruction,
  input [31:0] if_pc_plus_4,
  
  // ETAPA ID
  input [31:0] id_pc,
  input [31:0] id_instruction,
  input [31:0] id_pc_plus_4,
  input [4:0]  id_rs1,
  input [4:0]  id_rs2,
  input [4:0]  id_rd,
  input [31:0] id_imm,
  input [31:0] id_RU1,
  input [31:0] id_RU2,
  input        id_RUWr,
  input        id_Branch,
  input [4:0]  id_BrOp,
  
  // ETAPA EX
  input [31:0] ex_pc,
  input [31:0] ex_pc_plus_4,
  input [31:0] ex_alu_a,
  input [31:0] ex_alu_b,
  input [31:0] ex_alu_result,
  input [4:0]  ex_alu_op,
  input [4:0]  ex_rd,
  input        ex_branch_taken,
  input        ex_RUWr,
  
  // ETAPA MEM
  input [31:0] mem_alu_result,
  input [31:0] mem_data_in,
  input [31:0] mem_data_out,
  input [4:0]  mem_rd,
  input        mem_write_en,
  input        mem_RUWr,
  input [2:0]  mem_DMCtrl,
  
  // ETAPA WB
  input [31:0] wb_data,
  input [4:0]  wb_rd,
  input        wb_write_en,
  input [1:0]  mem_wb_RUDataWrSrc,
  
  // SEÑALES DE CONTROL DEL PIPELINE
  input [1:0]  forward_a,
  input [1:0]  forward_b,
  input        stall,
  input        flush_if_id,
  input        flush_id_ex,
  
  // ARRAYS
  input [31:0] registers [0:31],
  input [7:0]  memory [0:31],
  input [31:0] instructions [0:31],
  
  // EBREAK
  input        EBreak, 
  
  // SALIDAS VGA
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


  // Parámetros de layout - 5 COLUMNAS
  parameter CHAR_W = 8;
  parameter CHAR_H = 16;
  parameter LINE_SPACING = 18;
  parameter CHARS_PER_LINE = 20;
  
  // Columna 1: IF/ID
  parameter COL1_X = 250;
  parameter COL1_Y = 20;
  
  // Columna 2: EX/MEM/WB
  parameter COL2_X = 430;
  parameter COL2_Y = 20;
  
  // Columna 3: Memoria del programa
  parameter COL3_X = 650;
  parameter COL3_Y = 20;
  
  // Columna 4: Registros x0-x31
  parameter COL4_X = 850;
  parameter COL4_Y = 20;
  
  // Columna 5: Memoria
  parameter COL5_X = 1050;
  parameter COL5_Y = 20;
  
  // Señales de control del pipeline
  parameter CONTROL_X = 250;
  parameter CONTROL_Y = 650; 
  
  // Mensaje ebreak
  parameter EBREAK_X = 250;
  parameter EBREAK_Y = 440;
  

  // Buffers de texto

  // Columna 1: IF/ID
  reg [7:0] col1_line [0:24] [0:17];
  
  // Columna 2: EX/MEM/WB
  reg [7:0] col2_line [0:24] [0:19];
  
  // Columna 3: Memoria del programa
  reg [7:0] col3_line [0:32] [0:19];
  
  // Columna 4: Registros x0-x31
  reg [7:0] col4_line [0:32] [0:19];
  
  // Columna 5: Memoria DATAMEMORY
  reg [7:0] col5_line [0:32] [0:19];
  
  // Buffer para señales de control del pipeline
  reg [7:0] control_line [0:5] [0:19];
  
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
			// COLUMNA 1: IF/ID
			// Línea 0: IF
			col1_line[0][0] <= 8'd32;  //
			col1_line[0][1] <= 8'd32;  //
			col1_line[0][2] <= 8'd32;  //
			col1_line[0][3] <= 8'd73;  // I
			col1_line[0][4] <= 8'd70;  // F
			col1_line[0][5] <= 8'd32;  // 
			col1_line[0][6] <= 8'd32;  //
			col1_line[0][7] <= 8'd32;  //
			for(i=8;i<18;i=i+1) col1_line[0][i]<=8'd32;
      
			
			// Línea 1: IF : PC
			col1_line[1][0]<=8'd80; 
			col1_line[1][1]<=8'd67; 
			col1_line[1][2]<=8'd58;
			col1_line[1][3]<=nibble_to_hex(if_pc[31:28]); 
			col1_line[1][4]<=nibble_to_hex(if_pc[27:24]);
			col1_line[1][5]<=nibble_to_hex(if_pc[23:20]); 
			col1_line[1][6]<=nibble_to_hex(if_pc[19:16]);
			col1_line[1][7]<=nibble_to_hex(if_pc[15:12]); 
			col1_line[1][8]<=nibble_to_hex(if_pc[11:8]);
			col1_line[1][9]<=nibble_to_hex(if_pc[7:4]); 
			col1_line[1][10]<=nibble_to_hex(if_pc[3:0]);
			for(i = 11; i < 18;i = i + 1) col1_line[1][i] <= 8'd32;
			
			// Línea 2: IF : INST
			col1_line[2][0]<=8'd73; //I
			col1_line[2][1]<=8'd78; //N
			col1_line[2][2]<=8'd83; //S
			col1_line[2][3]<=8'd84; //T
			col1_line[2][4]<=8'd58; //:
			col1_line[2][5]<=nibble_to_hex(if_instruction[31:28]); col1_line[2][6]<=nibble_to_hex(if_instruction[27:24]);
			col1_line[2][7]<=nibble_to_hex(if_instruction[23:20]); col1_line[2][8]<=nibble_to_hex(if_instruction[19:16]);
			col1_line[2][9]<=nibble_to_hex(if_instruction[15:12]); col1_line[2][10]<=nibble_to_hex(if_instruction[11:8]);
			col1_line[2][11]<=nibble_to_hex(if_instruction[7:4]); col1_line[2][12]<=nibble_to_hex(if_instruction[3:0]);
			for(i = 13; i < 18; i = i + 1) col1_line[2][i] <= 8'd32;
			
			// Línea 3: IF : PC + 4
			col1_line[3][0]<=8'd80; //P
			col1_line[3][1]<=8'd67; //C
			col1_line[3][2]<=8'd43; //+
			col1_line[3][3]<=8'd52; //4
			col1_line[3][4]<=8'd58; //:
			col1_line[3][5]<=nibble_to_hex(if_pc_plus_4[31:28]); col1_line[3][6]<=nibble_to_hex(if_pc_plus_4[27:24]);
			col1_line[3][7]<=nibble_to_hex(if_pc_plus_4[23:20]); col1_line[3][8]<=nibble_to_hex(if_pc_plus_4[19:16]);
			col1_line[3][9]<=nibble_to_hex(if_pc_plus_4[15:12]); col1_line[3][10]<=nibble_to_hex(if_pc_plus_4[11:8]);
			col1_line[3][11]<=nibble_to_hex(if_pc_plus_4[7:4]); col1_line[3][12]<=nibble_to_hex(if_pc_plus_4[3:0]);
			for(i = 13;i < 18;i = i + 1) col1_line[3][i] <= 8'd32;
			
			// Separador
			for(i = 0;i < 16;i = i + 1) col1_line[4][i] <= 8'd45;
			for(i = 16;i < 18;i = i + 1) col1_line[4][i] <= 8'd32;
			
			// Título ID
			col1_line[5][0]<=8'd32; 
			col1_line[5][1]<=8'd32; 
			col1_line[5][2]<=8'd32;
			col1_line[5][3]<=8'd73; //I
			col1_line[5][4]<=8'd68; //D
			col1_line[5][5]<=8'd32;
			col1_line[5][6]<=8'd32; 
			col1_line[5][7]<=8'd32;
			for(i=8;i<18;i=i+1) col1_line[5][i]<=8'd32;
			
			// ID: PC
			col1_line[6][0]<=8'd80; col1_line[6][1]<=8'd67; col1_line[6][2]<=8'd58;
			col1_line[6][3]<=nibble_to_hex(id_pc[31:28]); col1_line[6][4]<=nibble_to_hex(id_pc[27:24]);
			col1_line[6][5]<=nibble_to_hex(id_pc[23:20]); col1_line[6][6]<=nibble_to_hex(id_pc[19:16]);
			col1_line[6][7]<=nibble_to_hex(id_pc[15:12]); col1_line[6][8]<=nibble_to_hex(id_pc[11:8]);
			col1_line[6][9]<=nibble_to_hex(id_pc[7:4]); col1_line[6][10]<=nibble_to_hex(id_pc[3:0]);
			for(i=11;i<18;i=i+1) col1_line[6][i]<=8'd32;
			
			// ID: INST
			col1_line[7][0]<=8'd73; col1_line[7][1]<=8'd78; col1_line[7][2]<=8'd83; col1_line[7][3]<=8'd84; col1_line[7][4]<=8'd58;
			col1_line[7][5]<=nibble_to_hex(id_instruction[31:28]); col1_line[7][6]<=nibble_to_hex(id_instruction[27:24]);
			col1_line[7][7]<=nibble_to_hex(id_instruction[23:20]); col1_line[7][8]<=nibble_to_hex(id_instruction[19:16]);
			col1_line[7][9]<=nibble_to_hex(id_instruction[15:12]); col1_line[7][10]<=nibble_to_hex(id_instruction[11:8]);
			col1_line[7][11]<=nibble_to_hex(id_instruction[7:4]); col1_line[7][12]<=nibble_to_hex(id_instruction[3:0]);
			for(i=13;i<18;i=i+1) col1_line[7][i]<=8'd32;
			
			// ID: RS1/RS2/RD
			col1_line[8][0]<=8'd82; col1_line[8][1]<=8'd83; col1_line[8][2]<=8'd49; col1_line[8][3]<=8'd58;
			col1_line[8][4]<=dec_to_ascii_tens(id_rs1); col1_line[8][5]<=dec_to_ascii_ones(id_rs1);
			col1_line[8][6]<=8'd32; col1_line[8][7]<=8'd82; col1_line[8][8]<=8'd83; col1_line[8][9]<=8'd50; col1_line[8][10]<=8'd58;
			col1_line[8][11]<=dec_to_ascii_tens(id_rs2); col1_line[8][12]<=dec_to_ascii_ones(id_rs2);
			for(i=13;i<18;i=i+1) col1_line[8][i]<=8'd32;
			
			// ID: RD
			col1_line[9][0]<=8'd82; col1_line[9][1]<=8'd68; col1_line[9][2]<=8'd58;
			col1_line[9][3]<=dec_to_ascii_tens(id_rd); col1_line[9][4]<=dec_to_ascii_ones(id_rd);
			col1_line[9][5]<=8'd32; col1_line[9][6]<=8'd82; col1_line[9][7]<=8'd85; col1_line[9][8]<=8'd87; col1_line[9][9]<=8'd82; col1_line[9][10]<=8'd58;
			col1_line[9][11]<=id_RUWr ? 8'd49 : 8'd48;
			for(i=12;i<18;i=i+1) col1_line[9][i]<=8'd32;
			
			// ID: RU1
			col1_line[10][0]<=8'd82; col1_line[10][1]<=8'd85; col1_line[10][2]<=8'd49; col1_line[10][3]<=8'd58;
			col1_line[10][4]<=nibble_to_hex(id_RU1[31:28]); col1_line[10][5]<=nibble_to_hex(id_RU1[27:24]);
			col1_line[10][6]<=nibble_to_hex(id_RU1[23:20]); col1_line[10][7]<=nibble_to_hex(id_RU1[19:16]);
			col1_line[10][8]<=nibble_to_hex(id_RU1[15:12]); col1_line[10][9]<=nibble_to_hex(id_RU1[11:8]);
			col1_line[10][10]<=nibble_to_hex(id_RU1[7:4]); col1_line[10][11]<=nibble_to_hex(id_RU1[3:0]);
			for(i=12;i<18;i=i+1) col1_line[10][i]<=8'd32;
			
			// ID: RU2
			col1_line[11][0]<=8'd82; col1_line[11][1]<=8'd85; col1_line[11][2]<=8'd50; col1_line[11][3]<=8'd58;
			col1_line[11][4]<=nibble_to_hex(id_RU2[31:28]); col1_line[11][5]<=nibble_to_hex(id_RU2[27:24]);
			col1_line[11][6]<=nibble_to_hex(id_RU2[23:20]); col1_line[11][7]<=nibble_to_hex(id_RU2[19:16]);
			col1_line[11][8]<=nibble_to_hex(id_RU2[15:12]); col1_line[11][9]<=nibble_to_hex(id_RU2[11:8]);
			col1_line[11][10]<=nibble_to_hex(id_RU2[7:4]); col1_line[11][11]<=nibble_to_hex(id_RU2[3:0]);
			for(i=12;i<18;i=i+1) col1_line[11][i]<=8'd32;
			
			// ID: IMM
			col1_line[12][0]<=8'd73; col1_line[12][1]<=8'd77; col1_line[12][2]<=8'd77; col1_line[12][3]<=8'd58;
			col1_line[12][4]<=nibble_to_hex(id_imm[31:28]); col1_line[12][5]<=nibble_to_hex(id_imm[27:24]);
			col1_line[12][6]<=nibble_to_hex(id_imm[23:20]); col1_line[12][7]<=nibble_to_hex(id_imm[19:16]);
			col1_line[12][8]<=nibble_to_hex(id_imm[15:12]); col1_line[12][9]<=nibble_to_hex(id_imm[11:8]);
			col1_line[12][10]<=nibble_to_hex(id_imm[7:4]); col1_line[12][11]<=nibble_to_hex(id_imm[3:0]);
			for(i=12;i<18;i=i+1) col1_line[12][i]<=8'd32;
			
			// ID: Branch
			col1_line[13][0]<=8'd66; col1_line[13][1]<=8'd82; col1_line[13][2]<=8'd58;
			col1_line[13][3]<=id_Branch ? 8'd49 : 8'd48;
			col1_line[13][4]<=8'd32; col1_line[13][5]<=8'd66; col1_line[13][6]<=8'd82; col1_line[13][7]<=8'd79; col1_line[13][8]<=8'd80; col1_line[13][9]<=8'd58;
			col1_line[13][10]<=nibble_to_hex({3'b0,id_BrOp[4]}); col1_line[13][11]<=nibble_to_hex(id_BrOp[3:0]);
			for(i=12;i<18;i=i+1) col1_line[13][i]<=8'd32;

			
			// COLUMNA 2: EX/MEM/WB
			// Título EX
			col2_line[0][0]<=8'd32; 
			col2_line[0][1]<=8'd32; 
			col2_line[0][2]<=8'd32;
			col2_line[0][3]<=8'd69; //E
			col2_line[0][4]<=8'd88; //X
			col2_line[0][5]<=8'd32;
			col2_line[0][6]<=8'd32; 
			col2_line[0][7]<=8'd32;
			for(i=8;i<18;i=i+1) col2_line[0][i]<=8'd32;
			
			// EX: PC
			col2_line[1][0]<=8'd80; col2_line[1][1]<=8'd67; col2_line[1][2]<=8'd58;
			col2_line[1][3]<=nibble_to_hex(ex_pc[31:28]); col2_line[1][4]<=nibble_to_hex(ex_pc[27:24]);
			col2_line[1][5]<=nibble_to_hex(ex_pc[23:20]); col2_line[1][6]<=nibble_to_hex(ex_pc[19:16]);
			col2_line[1][7]<=nibble_to_hex(ex_pc[15:12]); col2_line[1][8]<=nibble_to_hex(ex_pc[11:8]);
			col2_line[1][9]<=nibble_to_hex(ex_pc[7:4]); col2_line[1][10]<=nibble_to_hex(ex_pc[3:0]);
			for(i=11;i<18;i=i+1) col2_line[1][i]<=8'd32;
			
			// EX: ALU_A
			col2_line[2][0]<=8'd65; col2_line[2][1]<=8'd76; col2_line[2][2]<=8'd85; col2_line[2][3]<=8'd65; col2_line[2][4]<=8'd58;
			col2_line[2][5]<=nibble_to_hex(ex_alu_a[31:28]); col2_line[2][6]<=nibble_to_hex(ex_alu_a[27:24]);
			col2_line[2][7]<=nibble_to_hex(ex_alu_a[23:20]); col2_line[2][8]<=nibble_to_hex(ex_alu_a[19:16]);
			col2_line[2][9]<=nibble_to_hex(ex_alu_a[15:12]); col2_line[2][10]<=nibble_to_hex(ex_alu_a[11:8]);
			col2_line[2][11]<=nibble_to_hex(ex_alu_a[7:4]); col2_line[2][12]<=nibble_to_hex(ex_alu_a[3:0]);
			for(i=13;i<18;i=i+1) col2_line[2][i]<=8'd32;
			
			// EX: ALU_B
			col2_line[3][0]<=8'd65; col2_line[3][1]<=8'd76; col2_line[3][2]<=8'd85; col2_line[3][3]<=8'd66; col2_line[3][4]<=8'd58;
			col2_line[3][5]<=nibble_to_hex(ex_alu_b[31:28]); col2_line[3][6]<=nibble_to_hex(ex_alu_b[27:24]);
			col2_line[3][7]<=nibble_to_hex(ex_alu_b[23:20]); col2_line[3][8]<=nibble_to_hex(ex_alu_b[19:16]);
			col2_line[3][9]<=nibble_to_hex(ex_alu_b[15:12]); col2_line[3][10]<=nibble_to_hex(ex_alu_b[11:8]);
			col2_line[3][11]<=nibble_to_hex(ex_alu_b[7:4]); col2_line[3][12]<=nibble_to_hex(ex_alu_b[3:0]);
			for(i=13;i<18;i=i+1) col2_line[3][i]<=8'd32;
			
			// EX: ALU_RES
			col2_line[4][0]<=8'd82; col2_line[4][1]<=8'd69; col2_line[4][2]<=8'd83; col2_line[4][3]<=8'd58;
			col2_line[4][4]<=nibble_to_hex(ex_alu_result[31:28]); col2_line[4][5]<=nibble_to_hex(ex_alu_result[27:24]);
			col2_line[4][6]<=nibble_to_hex(ex_alu_result[23:20]); col2_line[4][7]<=nibble_to_hex(ex_alu_result[19:16]);
			col2_line[4][8]<=nibble_to_hex(ex_alu_result[15:12]); col2_line[4][9]<=nibble_to_hex(ex_alu_result[11:8]);
			col2_line[4][10]<=nibble_to_hex(ex_alu_result[7:4]); col2_line[4][11]<=nibble_to_hex(ex_alu_result[3:0]);
			for(i=12;i<18;i=i+1) col2_line[4][i]<=8'd32;
			
			// EX: OP/RD
			col2_line[5][0]<=8'd79; col2_line[5][1]<=8'd80; col2_line[5][2]<=8'd58;
			col2_line[5][3]<=nibble_to_hex({3'b0,ex_alu_op[4]}); col2_line[5][4]<=nibble_to_hex(ex_alu_op[3:0]);
			col2_line[5][5]<=8'd32; col2_line[5][6]<=8'd82; col2_line[5][7]<=8'd68; col2_line[5][8]<=8'd58;
			col2_line[5][9]<=dec_to_ascii_tens(ex_rd); col2_line[5][10]<=dec_to_ascii_ones(ex_rd);
			for(i=11;i<18;i=i+1) col2_line[5][i]<=8'd32;
			
			// EX: Branch (PCSrc)
			col2_line[6][0]<=8'd80; col2_line[6][1]<=8'd67; col2_line[6][2]<=8'd83; col2_line[6][3]<=8'd82; col2_line[6][4]<=8'd67; col2_line[6][6]<=8'd58;
			col2_line[6][7]<=ex_branch_taken ? 8'd49 : 8'd48;
			for(i=8;i<18;i=i+1) col2_line[6][i]<=8'd32;
			
			// Separador
			for(i=0;i<16;i=i+1) col2_line[7][i]<=8'd45;
			for(i=16;i<18;i=i+1) col2_line[7][i]<=8'd32;
			
			// Título MEM
			col2_line[8][0]<=8'd32; col2_line[8][1]<=8'd32; col2_line[8][2]<=8'd32;
			col2_line[8][3]<=8'd77; col2_line[8][4]<=8'd69; col2_line[8][5]<=8'd77; col2_line[8][6]<=8'd32;
			col2_line[8][7]<=8'd32; col2_line[8][8]<=8'd32;
			for(i=9;i<18;i=i+1) col2_line[8][i]<=8'd32;
			
			// MEM: ALU_RES (addr)
			col2_line[9][0]<=8'd65; col2_line[9][1]<=8'd68; col2_line[9][2]<=8'd68; col2_line[9][3]<=8'd82; col2_line[9][4]<=8'd58;
			col2_line[9][5]<=nibble_to_hex(mem_alu_result[31:28]); col2_line[9][6]<=nibble_to_hex(mem_alu_result[27:24]);
			col2_line[9][7]<=nibble_to_hex(mem_alu_result[23:20]); col2_line[9][8]<=nibble_to_hex(mem_alu_result[19:16]);
			col2_line[9][9]<=nibble_to_hex(mem_alu_result[15:12]); col2_line[9][10]<=nibble_to_hex(mem_alu_result[11:8]);
			col2_line[9][11]<=nibble_to_hex(mem_alu_result[7:4]); col2_line[9][12]<=nibble_to_hex(mem_alu_result[3:0]);
			for(i=13;i<18;i=i+1) col2_line[9][i]<=8'd32;
			
			// MEM: DATA_IN
			col2_line[10][0]<=8'd68; col2_line[10][1]<=8'd73; col2_line[10][2]<=8'd78; col2_line[10][3]<=8'd58;
			col2_line[10][4]<=nibble_to_hex(mem_data_in[31:28]); col2_line[10][5]<=nibble_to_hex(mem_data_in[27:24]);
			col2_line[10][6]<=nibble_to_hex(mem_data_in[23:20]); col2_line[10][7]<=nibble_to_hex(mem_data_in[19:16]);
			col2_line[10][8]<=nibble_to_hex(mem_data_in[15:12]); col2_line[10][9]<=nibble_to_hex(mem_data_in[11:8]);
			col2_line[10][10]<=nibble_to_hex(mem_data_in[7:4]); col2_line[10][11]<=nibble_to_hex(mem_data_in[3:0]);
			for(i=12;i<18;i=i+1) col2_line[10][i]<=8'd32;
			
			// MEM: DATA_OUT
			col2_line[11][0]<=8'd68; col2_line[11][1]<=8'd79; col2_line[11][2]<=8'd85; col2_line[11][3]<=8'd84; col2_line[11][4]<=8'd58;
			col2_line[11][5]<=nibble_to_hex(mem_data_out[31:28]); col2_line[11][6]<=nibble_to_hex(mem_data_out[27:24]);
			col2_line[11][7]<=nibble_to_hex(mem_data_out[23:20]); col2_line[11][8]<=nibble_to_hex(mem_data_out[19:16]);
			col2_line[11][9]<=nibble_to_hex(mem_data_out[15:12]); col2_line[11][10]<=nibble_to_hex(mem_data_out[11:8]);
			col2_line[11][11]<=nibble_to_hex(mem_data_out[7:4]); col2_line[11][12]<=nibble_to_hex(mem_data_out[3:0]);
			for(i=13;i<18;i=i+1) col2_line[11][i]<=8'd32;
			
			// MEM: RD/DMWR
			col2_line[12][0]<=8'd82; col2_line[12][1]<=8'd68; col2_line[12][2]<=8'd58;
			col2_line[12][3]<=dec_to_ascii_tens(mem_rd); col2_line[12][4]<=dec_to_ascii_ones(mem_rd);
			col2_line[12][5]<=8'd32; col2_line[12][6]<=8'd68; col2_line[12][7]<=8'd77; col2_line[12][8]<=8'd87; col2_line[12][9]<=8'd82; col2_line[12][10]<=8'd58;
			col2_line[12][11]<=mem_write_en ? 8'd49 : 8'd48;
			for(i=12;i<18;i=i+1) col2_line[12][i]<=8'd32;
			
			// MEM: DMCtrl
			col2_line[13][0]<=8'd68; col2_line[13][1]<=8'd77; col2_line[13][2]<=8'd67; col2_line[13][3]<=8'd58;
			col2_line[13][4]<=nibble_to_hex({1'b0, mem_DMCtrl});
			for(i=5;i<18;i=i+1) col2_line[13][i]<=8'd32;
			
			// Separador
			for(i=0;i<16;i=i+1) col2_line[14][i]<=8'd45;
			for(i=16;i<18;i=i+1) col2_line[14][i]<=8'd32;
			
			// Título WB
			col2_line[15][0]<=8'd61; col2_line[15][1]<=8'd61; col2_line[15][2]<=8'd32;
			col2_line[15][3]<=8'd87; col2_line[15][4]<=8'd66; col2_line[15][5]<=8'd32;
			col2_line[15][6]<=8'd61; col2_line[15][7]<=8'd61;
			for(i=8;i<18;i=i+1) col2_line[15][i]<=8'd32;
			
			// WB: DATA
			col2_line[16][0]<=8'd68; col2_line[16][1]<=8'd65; col2_line[16][2]<=8'd84; col2_line[16][3]<=8'd65; col2_line[16][4]<=8'd58;
			col2_line[16][5]<=nibble_to_hex(wb_data[31:28]); col2_line[16][6]<=nibble_to_hex(wb_data[27:24]);
			col2_line[16][7]<=nibble_to_hex(wb_data[23:20]); col2_line[16][8]<=nibble_to_hex(wb_data[19:16]);
			col2_line[16][9]<=nibble_to_hex(wb_data[15:12]); col2_line[16][10]<=nibble_to_hex(wb_data[11:8]);
			col2_line[16][11]<=nibble_to_hex(wb_data[7:4]); col2_line[16][12]<=nibble_to_hex(wb_data[3:0]);
			for(i=13;i<18;i=i+1) col2_line[16][i]<=8'd32;
			
			// WB: RD/WrEn
			col2_line[17][0]<=8'd82; col2_line[17][1]<=8'd68; col2_line[17][2]<=8'd58;
			col2_line[17][3]<=dec_to_ascii_tens(wb_rd); col2_line[17][4]<=dec_to_ascii_ones(wb_rd);
			col2_line[17][5]<=8'd32; col2_line[17][6]<=8'd82; col2_line[17][7]<=8'd85; col2_line[17][8]<=8'd68; col2_line[17][9]<=8'd87; col2_line[17][10]<=8'd82; col2_line[17][11]<=8'd58;
			col2_line[17][12]<=nibble_to_hex({1'b0, mem_wb_RUDataWrSrc});
			for(i=13;i<18;i=i+1) col2_line[17][i]<=8'd32;
			
			
			// COLUMNA 3: Instrucciones
			col3_line[0][0]<=8'd73;  //I
			col3_line[0][1]<=8'd78;  //N
			col3_line[0][2]<=8'd83;  //S
			col3_line[0][3]<=8'd84;  //T
			col3_line[0][4]<=8'd82;  //R
			col3_line[0][5]<=8'd85;  //U
			col3_line[0][6]<=8'd67;  //C
			col3_line[0][7]<=8'd84;  //T
			col3_line[0][8]<=8'd73;  //I
			col3_line[0][9]<=8'd79;  //O
			col3_line[0][10]<=8'd78; //N
			col3_line[0][11]<=8'd83; //S
			
			for(i=12;i<18;i=i+1) col3_line[0][i]<=8'd32;
			
			for(idx = 0;idx<32;idx=idx+1) begin
			  col3_line[idx+1][0] <= 8'd91;  // [
			  col3_line[idx+1][1] <= dec_to_ascii_tens(idx);
			  col3_line[idx+1][2] <= dec_to_ascii_ones(idx);
			  col3_line[idx+1][3] <= 8'd93;  // ]
			  col3_line[idx+1][4] <= 8'd58;  // :
			  col3_line[idx+1][5]  <= nibble_to_hex(instructions[idx][31:28]);
			  col3_line[idx+1][6]  <= nibble_to_hex(instructions[idx][27:24]);
			  col3_line[idx+1][7]  <= nibble_to_hex(instructions[idx][23:20]);
			  col3_line[idx+1][8]  <= nibble_to_hex(instructions[idx][19:16]);
			  col3_line[idx+1][9]  <= nibble_to_hex(instructions[idx][15:12]);
			  col3_line[idx+1][10] <= nibble_to_hex(instructions[idx][11:8]);
			  col3_line[idx+1][11] <= nibble_to_hex(instructions[idx][7:4]);
			  col3_line[idx+1][12] <= nibble_to_hex(instructions[idx][3:0]);
			  for(i=13;i<18;i=i+1) col3_line[idx+1][i]<=8'd32;
			end
			
			
			// COLUMNA 4: REGISTROS x0-x31
			// Título
			col4_line[0][0]<=8'd82;  //R
			col4_line[0][1]<=8'd69;  //E
			col4_line[0][2]<=8'd71;  //G
			col4_line[0][3]<=8'd83;  //S
			col4_line[0][4]<=8'd32;  
			col4_line[0][5]<=8'd120; //x
			col4_line[0][6]<=8'd48;  //0
			col4_line[0][7]<=8'd48;  //0
			col4_line[0][8]<=8'd45;  //-
			col4_line[0][9]<=8'd120; //x
			col4_line[0][10]<=8'd51; //3
			col4_line[0][11]<=8'd49; //1
			for(i=12;i<18;i=i+1) col4_line[0][i]<=8'd32;
			
			for(idx=0;idx<32;idx=idx+1) begin
			  col4_line[idx+1][0]<=8'd120;
			  col4_line[idx+1][1]<=dec_to_ascii_tens(idx);
			  col4_line[idx+1][2]<=dec_to_ascii_ones(idx);
			  col4_line[idx+1][3]<=8'd58;
			  col4_line[idx+1][4]<=nibble_to_hex(registers[idx][31:28]);
			  col4_line[idx+1][5]<=nibble_to_hex(registers[idx][27:24]);
			  col4_line[idx+1][6]<=nibble_to_hex(registers[idx][23:20]);
			  col4_line[idx+1][7]<=nibble_to_hex(registers[idx][19:16]);
			  col4_line[idx+1][8]<=nibble_to_hex(registers[idx][15:12]);
			  col4_line[idx+1][9]<=nibble_to_hex(registers[idx][11:8]);
			  col4_line[idx+1][10]<=nibble_to_hex(registers[idx][7:4]);
			  col4_line[idx+1][11]<=nibble_to_hex(registers[idx][3:0]);
			  for(i=12;i<18;i=i+1) col4_line[idx+1][i]<=8'd32;
			end
			
			// COLUMNA 5: MEMORIA
			// Título
			col5_line[0][0] <= 8'd77;  col5_line[0][1] <= 8'd69;  col5_line[0][2] <= 8'd77;
			col5_line[0][3] <= 8'd79;  col5_line[0][4] <= 8'd82;  col5_line[0][5] <= 8'd89;
			for (i = 6; i < 20; i = i + 1) col5_line[0][i] <= 8'd32;
			
			// Memoria [0-31]
			for (idx = 0; idx < 32; idx = idx + 1) begin
			  col5_line[idx+1][0] <= 8'd91;  // [
			  col5_line[idx+1][1] <= dec_to_ascii_tens(idx);
			  col5_line[idx+1][2] <= dec_to_ascii_ones(idx);
			  col5_line[idx+1][3] <= 8'd93;  // ]
			  col5_line[idx+1][4] <= 8'd58;  // :
			  col5_line[idx+1][5] <= nibble_to_hex(memory[idx][7:4]);
			  col5_line[idx+1][6] <= nibble_to_hex(memory[idx][3:0]);
			  for (i = 7; i < 20; i = i + 1) col5_line[idx+1][i] <= 8'd32;
			end
			
			// Actualizar señales de control
			// Línea 0: Título
			control_line[0][0] <= 8'd80;  // P
			control_line[0][1] <= 8'd73;  // I
			control_line[0][2] <= 8'd80;  // P
			control_line[0][3] <= 8'd69;  // E
			control_line[0][4] <= 8'd76;  // L
			control_line[0][5] <= 8'd73;  // I
			control_line[0][6] <= 8'd78;  // N
			control_line[0][7] <= 8'd69;  // E
			control_line[0][8] <= 8'd32;  // espacio
			control_line[0][9] <= 8'd67;  // C
			control_line[0][10] <= 8'd79; // O
			control_line[0][11] <= 8'd78; // N
			control_line[0][12] <= 8'd84; // T
			control_line[0][13] <= 8'd82; // R
			control_line[0][14] <= 8'd79; // O
			control_line[0][15] <= 8'd76; // L
			for(i=16; i<20; i=i+1) control_line[0][i] <= 8'd32;
			
			// Línea 1: STALL
			control_line[1][0] <= 8'd83;  // S
			control_line[1][1] <= 8'd84;  // T
			control_line[1][2] <= 8'd65;  // A
			control_line[1][3] <= 8'd76;  // L
			control_line[1][4] <= 8'd76;  // L
			control_line[1][5] <= 8'd58;  // :
			control_line[1][6] <= stall ? 8'd49 : 8'd48;  // 1 o 0
			for(i=7; i<20; i=i+1) control_line[1][i] <= 8'd32;
			
			// Línea 2: FLUSH IF/ID
			control_line[2][0] <= 8'd70;  // F
			control_line[2][1] <= 8'd76;  // L
			control_line[2][2] <= 8'd85;  // U
			control_line[2][3] <= 8'd83;  // S
			control_line[2][4] <= 8'd72;  // H
			control_line[2][5] <= 8'd32;  // espacio
			control_line[2][6] <= 8'd73;  // I
			control_line[2][7] <= 8'd70;  // F
			control_line[2][8] <= 8'd47;  // /
			control_line[2][9] <= 8'd73;  // I
			control_line[2][10] <= 8'd68; // D
			control_line[2][11] <= 8'd58; // :
			control_line[2][12] <= flush_if_id ? 8'd49 : 8'd48;
			for(i=13; i<20; i=i+1) control_line[2][i] <= 8'd32;
			
			// Línea 3: FLUSH ID/EX
			control_line[3][0] <= 8'd70;  // F
			control_line[3][1] <= 8'd76;  // L
			control_line[3][2] <= 8'd85;  // U
			control_line[3][3] <= 8'd83;  // S
			control_line[3][4] <= 8'd72;  // H
			control_line[3][5] <= 8'd32;  // espacio
			control_line[3][6] <= 8'd73;  // I
			control_line[3][7] <= 8'd68;  // D
			control_line[3][8] <= 8'd47;  // /
			control_line[3][9] <= 8'd69;  // E
			control_line[3][10] <= 8'd88; // X
			control_line[3][11] <= 8'd58; // :
			control_line[3][12] <= flush_id_ex ? 8'd49 : 8'd48;
			for(i=13; i<20; i=i+1) control_line[3][i] <= 8'd32;
			
			// Línea 4: FORWARD A
			control_line[4][0] <= 8'd70;  // F
			control_line[4][1] <= 8'd87;  // W
			control_line[4][2] <= 8'd68;  // D
			control_line[4][3] <= 8'd95;  // _
			control_line[4][4] <= 8'd65;  // A
			control_line[4][5] <= 8'd58;  // :
			control_line[4][6] <= nibble_to_hex({2'b0, forward_a});
			control_line[4][7] <= 8'd32;  // espacio
			control_line[4][8] <= 8'd40;  // (
			// Texto según valor
			if (forward_a == 2'b00) begin
			  control_line[4][9] <= 8'd78;  // N
			  control_line[4][10] <= 8'd79; // O
			  control_line[4][11] <= 8'd82; // R
			  control_line[4][12] <= 8'd77; // M
			  control_line[4][13] <= 8'd65; // A
			  control_line[4][14] <= 8'd76; // L
			  control_line[4][15] <= 8'd41; // )
			  for(i=16; i<20; i=i+1) control_line[4][i] <= 8'd32;
			end else if (forward_a == 2'b10) begin
			  control_line[4][9] <= 8'd69;  // E
			  control_line[4][10] <= 8'd88; // X
			  control_line[4][11] <= 8'd47; // /
			  control_line[4][12] <= 8'd77; // M
			  control_line[4][13] <= 8'd69; // E
			  control_line[4][14] <= 8'd77; // M
			  control_line[4][15] <= 8'd41; // )
			  for(i=16; i<20; i=i+1) control_line[4][i] <= 8'd32;
			end else if (forward_a == 2'b01) begin
			  control_line[4][9] <= 8'd77;  // M
			  control_line[4][10] <= 8'd69; // E
			  control_line[4][11] <= 8'd77; // M
			  control_line[4][12] <= 8'd47; // /
			  control_line[4][13] <= 8'd87; // W
			  control_line[4][14] <= 8'd66; // B
			  control_line[4][15] <= 8'd41; // )
			  for(i=16; i<20; i=i+1) control_line[4][i] <= 8'd32;
			end else begin
			  control_line[4][9] <= 8'd63;  // ?
			  control_line[4][10] <= 8'd41; // )
			  for(i=11; i<20; i=i+1) control_line[4][i] <= 8'd32;
			end
			
			// Línea 5: FORWARD B
			control_line[5][0] <= 8'd70;  // F
			control_line[5][1] <= 8'd87;  // W
			control_line[5][2] <= 8'd68;  // D
			control_line[5][3] <= 8'd95;  // _
			control_line[5][4] <= 8'd66;  // B
			control_line[5][5] <= 8'd58;  // :
			control_line[5][6] <= nibble_to_hex({2'b0, forward_b});
			control_line[5][7] <= 8'd32;  // espacio
			control_line[5][8] <= 8'd40;  // (
			if (forward_b == 2'b00) begin
			  control_line[5][9] <= 8'd78;  // N
			  control_line[5][10] <= 8'd79; // O
			  control_line[5][11] <= 8'd82; // R
			  control_line[5][12] <= 8'd77; // M
			  control_line[5][13] <= 8'd65; // A
			  control_line[5][14] <= 8'd76; // L
			  control_line[5][15] <= 8'd41; // )
			  for(i=16; i<20; i=i+1) control_line[5][i] <= 8'd32;
			end else if (forward_b == 2'b10) begin
			  control_line[5][9] <= 8'd69;  // E
			  control_line[5][10] <= 8'd88; // X
			  control_line[5][11] <= 8'd47; // /
			  control_line[5][12] <= 8'd77; // M
			  control_line[5][13] <= 8'd69; // E
			  control_line[5][14] <= 8'd77; // M
			  control_line[5][15] <= 8'd41; // )
			  for(i=16; i<20; i=i+1) control_line[5][i] <= 8'd32;
			end else if (forward_b == 2'b01) begin
			  control_line[5][9] <= 8'd77;  // M
			  control_line[5][10] <= 8'd69; // E
			  control_line[5][11] <= 8'd77; // M
			  control_line[5][12] <= 8'd47; // /
			  control_line[5][13] <= 8'd87; // W
			  control_line[5][14] <= 8'd66; // B
			  control_line[5][15] <= 8'd41; // )
			  for(i=16; i<20; i=i+1) control_line[5][i] <= 8'd32;
			end else begin
			  control_line[5][9] <= 8'd63;  // ?
			  control_line[5][10] <= 8'd41; // )
			  for(i=11; i<20; i=i+1) control_line[5][i] <= 8'd32;
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
  wire in_col5 = (x >= COL5_X && x < COL5_X + CHAR_W * CHARS_PER_LINE);
  
  // Región de señales de control
  wire in_control = (x >= CONTROL_X && x < CONTROL_X + CHAR_W * CHARS_PER_LINE);
  
  // Calcular línea y columna
  wire [5:0] line_num_col1 = (y - COL1_Y) / LINE_SPACING;
  wire [5:0] line_num_col2 = (y - COL2_Y) / LINE_SPACING;
  wire [5:0] line_num_col3 = (y - COL3_Y) / LINE_SPACING;
  wire [5:0] line_num_col4 = (y - COL4_Y) / LINE_SPACING;
  wire [5:0] line_num_col5 = (y - COL5_Y) / LINE_SPACING;
  wire [5:0] line_num_control = (y - CONTROL_Y) / LINE_SPACING;
  
  wire [4:0] char_col1 = (x - COL1_X) / CHAR_W;
  wire [4:0] char_col2 = (x - COL2_X) / CHAR_W;
  wire [4:0] char_col3 = (x - COL3_X) / CHAR_W;
  wire [4:0] char_col4 = (x - COL4_X) / CHAR_W;
  wire [4:0] char_col5 = (x - COL5_X) / CHAR_W;
  wire [4:0] char_control = (x - CONTROL_X) / CHAR_W;
  
  
  wire [3:0] row_in_line_col1 = (y - COL1_Y) % LINE_SPACING;
  wire [3:0] row_in_line_col2 = (y - COL2_Y) % LINE_SPACING;
  wire [3:0] row_in_line_col3 = (y - COL3_Y) % LINE_SPACING;
  wire [3:0] row_in_line_col4 = (y - COL4_Y) % LINE_SPACING;
  wire [3:0] row_in_line_col5 = (y - COL5_Y) % LINE_SPACING;
  wire [3:0] row_in_line_control = (y - CONTROL_Y) % LINE_SPACING;
  
  wire valid_col1 = in_col1 && (y >= COL1_Y) && (line_num_col1 < 23) && (row_in_line_col1 < CHAR_H);
  wire valid_col2 = in_col2 && (y >= COL2_Y) && (line_num_col2 < 19) && (row_in_line_col2 < CHAR_H);
  wire valid_col3 = in_col3 && (y >= COL3_Y) && (line_num_col3 < 33) && (row_in_line_col3 < CHAR_H);
  wire valid_col4 = in_col4 && (y >= COL4_Y) && (line_num_col4 < 33) && (row_in_line_col4 < CHAR_H);
  wire valid_col5 = in_col5 && (y >= COL5_Y) && (line_num_col5 < 33) && (row_in_line_col5 < CHAR_H);
  wire valid_control = in_control && (y >= CONTROL_Y) && (line_num_control < 6) && (row_in_line_control < CHAR_H);
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
	 end else if (valid_col5) begin
      current_ascii = col5_line[line_num_col5][char_col5];
      current_row = row_in_line_col5;
      current_col = (x - COL5_X) % CHAR_W;
	 end else if (valid_control) begin
      current_ascii = control_line[line_num_control][char_control];
      current_row = row_in_line_control;
      current_col = (x - CONTROL_X) % CHAR_W;
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
  wire inside_text = valid_col1 || valid_col2 || valid_col3 || valid_col4 || valid_col5 || valid_ebreak;
  
  always @(*) begin
    if (~videoOn)
      {vga_red, vga_green, vga_blue} = 24'h000000;
    else if (valid_ebreak && pixel_on)
      {vga_red, vga_green, vga_blue} = 24'hFF0000;  // Mensaje EBREAK en rojo
	 else if (valid_control && pixel_on)
      {vga_red, vga_green, vga_blue} = 24'hFFFF00;  // Amarillo para señales de control
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