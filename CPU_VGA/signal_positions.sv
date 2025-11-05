// Auto-generado por txt_to_hex.py
// Análisis automático con filtrado inteligente

// Total detectado: 94 patrones
// Valores (filtrados): 62 señales
// Etiquetas (ignoradas): 32

// ========== SEÑALES DE VALOR (FILTRADAS) ==========
// [ 0] Fila  3, Col  10, Len 8 | Después de = o :          |      PC = XXXXXXXX  Next PC 
// [ 1] Fila  3, Col  30, Len 8 | Después de = o :          | XXXXXXXX  Next PC = XXXXXXXX  Inst = X
// [ 2] Fila  3, Col  47, Len 8 | Después de = o :          |  = XXXXXXXX  Inst = XXXXXXXX      |   
// [ 3] Fila  3, Col  73, Len 2 | Después de = o :          | XX      |      rs1: XX  rs2: XX 
// [ 4] Fila  3, Col  82, Len 2 | Después de = o :          |       rs1: XX  rs2: XX  rd: XX  
// [ 5] Fila  3, Col  90, Len 2 | Después de = o :          | 1: XX  rs2: XX  rd: XX       Dat
// [ 6] Fila  3, Col 111, Len 8 | Después de = o :          | X       DataWrite = XXXXXXXX   RUWR = 
// [ 7] Fila  3, Col 129, Len 1 | Después de = o :          | = XXXXXXXX   RUWR = X       !
// [ 8] Fila  5, Col  80, Len 8 | Después de = o :          |  |            RU1 = XXXXXXXX          
// [ 9] Fila  5, Col 115, Len 8 | Después de = o :          |               RU2 = XXXXXXXX          
// [10] Fila  7, Col  11, Len 7 | Después de = o :          |    OPCODE: XXXXXXX      Func
// [11] Fila  7, Col  32, Len 3 | Después de = o :          | XXXXXX      Funct3: XXX     Funct
// [12] Fila  7, Col  48, Len 7 | Después de = o :          | t3: XXX     Funct7: XXXXXXX      |   
// [13] Fila  7, Col  83, Len 8 | Después de = o :          |               IMM = XXXXXXXX          
// [14] Fila  7, Col 113, Len 2 | Después de = o :          |            IMMSrc = XX          
// [15] Fila 13, Col  94, Len 1 | Señal corta (no etiqueta) |                    EXECUTE:    
// [16] Fila 15, Col  14, Len 8 | Después de = o :          |    Address  = XXXXXXXX          
// [17] Fila 15, Col  45, Len 8 | Después de = o :          |         DataWrite = XXXXXXXX        | 
// [18] Fila 15, Col  75, Len 8 | Después de = o :          |       |      ALUA = XXXXXXXX       ALU
// [19] Fila 15, Col  97, Len 8 | Después de = o :          | XXXXXX       ALUB = XXXXXXXX       ALU
// [20] Fila 15, Col 121, Len 8 | Después de = o :          | XXXX       ALURES = XXXXXXXX        !
// [21] Fila 17, Col  27, Len 8 | Después de = o :          |          DataRead = XXXXXXXX          
// [22] Fila 17, Col  80, Len 3 | Después de = o :          |  |          ALUOP = XXX         A
// [23] Fila 17, Col 102, Len 1 | Después de = o :          | X         ALUASrc = X          
// [24] Fila 17, Col 124, Len 1 | Después de = o :          |           ALUBSrc = X          
// [25] Fila 19, Col  21, Len 1 | Después de = o :          |            DMCtrl = X          
// [26] Fila 19, Col  41, Len 1 | Después de = o :          | X            DMWr = X          
// [27] Fila 25, Col  29, Len 2 | Después de = o :          |          BranchOP = XX         B
// [28] Fila 25, Col  49, Len 1 | Después de = o :          | XX         Branch = X          
// [29] Fila 25, Col 103, Len 1 | Después de = o :          |         RuDataSrc = X          
// [30] Fila 30, Col  46, Len 8 | Después de = o :          |               X0  = XXXXXXXX          
// [31] Fila 30, Col  76, Len 8 | Después de = o :          |               X16 = XXXXXXXX          
// [32] Fila 31, Col  46, Len 8 | Después de = o :          |               X1  = XXXXXXXX          
// [33] Fila 31, Col  76, Len 8 | Después de = o :          |               X17 = XXXXXXXX          
// [34] Fila 32, Col  46, Len 8 | Después de = o :          |               X2  = XXXXXXXX          
// [35] Fila 32, Col  76, Len 8 | Después de = o :          |               X18 = XXXXXXXX          
// [36] Fila 33, Col  46, Len 8 | Después de = o :          |               X3  = XXXXXXXX          
// [37] Fila 33, Col  76, Len 8 | Después de = o :          |               X19 = XXXXXXXX          
// [38] Fila 34, Col  46, Len 8 | Después de = o :          |               X4  = XXXXXXXX          
// [39] Fila 34, Col  76, Len 8 | Después de = o :          |               X20 = XXXXXXXX          
// [40] Fila 35, Col  46, Len 8 | Después de = o :          |               X5  = XXXXXXXX          
// [41] Fila 35, Col  76, Len 8 | Después de = o :          |               X21 = XXXXXXXX          
// [42] Fila 36, Col  46, Len 8 | Después de = o :          |               X6  = XXXXXXXX          
// [43] Fila 36, Col  76, Len 8 | Después de = o :          |               X22 = XXXXXXXX          
// [44] Fila 37, Col  46, Len 8 | Después de = o :          |               X7  = XXXXXXXX          
// [45] Fila 37, Col  76, Len 8 | Después de = o :          |               X23 = XXXXXXXX          
// [46] Fila 38, Col  46, Len 8 | Después de = o :          |               X8  = XXXXXXXX          
// [47] Fila 38, Col  76, Len 8 | Después de = o :          |               X24 = XXXXXXXX          
// [48] Fila 39, Col  46, Len 8 | Después de = o :          |               X9  = XXXXXXXX          
// [49] Fila 39, Col  76, Len 8 | Después de = o :          |               X25 = XXXXXXXX          
// [50] Fila 40, Col  46, Len 8 | Después de = o :          |               X10 = XXXXXXXX          
// [51] Fila 40, Col  76, Len 8 | Después de = o :          |               X26 = XXXXXXXX          
// [52] Fila 41, Col  46, Len 8 | Después de = o :          |               X11 = XXXXXXXX          
// [53] Fila 41, Col  76, Len 8 | Después de = o :          |               X27 = XXXXXXXX          
// [54] Fila 42, Col  46, Len 8 | Después de = o :          |               X12 = XXXXXXXX          
// [55] Fila 42, Col  76, Len 8 | Después de = o :          |               X28 = XXXXXXXX          
// [56] Fila 43, Col  46, Len 8 | Después de = o :          |               X13 = XXXXXXXX          
// [57] Fila 43, Col  76, Len 8 | Después de = o :          |               X29 = XXXXXXXX          
// [58] Fila 44, Col  46, Len 8 | Después de = o :          |               X14 = XXXXXXXX          
// [59] Fila 44, Col  76, Len 8 | Después de = o :          |               X30 = XXXXXXXX          
// [60] Fila 45, Col  46, Len 8 | Después de = o :          |               X15 = XXXXXXXX          
// [61] Fila 45, Col  76, Len 8 | Después de = o :          |               X31 = XXXXXXXX          


// ========== CÓDIGO PARA write_vga.sv ==========
// parameter NUM_SIGNALS = 62;

// Array SIGNAL_CONFIGS (valores filtrados):
/*
  '{6'd 3, 8'd 10, 5'd8},  //  0
  '{6'd 3, 8'd 30, 5'd8},  //  1
  '{6'd 3, 8'd 47, 5'd8},  //  2
  '{6'd 3, 8'd 73, 5'd2},  //  3
  '{6'd 3, 8'd 82, 5'd2},  //  4
  '{6'd 3, 8'd 90, 5'd2},  //  5
  '{6'd 3, 8'd111, 5'd8},  //  6
  '{6'd 3, 8'd129, 5'd1},  //  7
  '{6'd 5, 8'd 80, 5'd8},  //  8
  '{6'd 5, 8'd115, 5'd8},  //  9
  '{6'd 7, 8'd 11, 5'd7},  // 10
  '{6'd 7, 8'd 32, 5'd3},  // 11
  '{6'd 7, 8'd 48, 5'd7},  // 12
  '{6'd 7, 8'd 83, 5'd8},  // 13
  '{6'd 7, 8'd113, 5'd2},  // 14
  '{6'd13, 8'd 94, 5'd1},  // 15
  '{6'd15, 8'd 14, 5'd8},  // 16
  '{6'd15, 8'd 45, 5'd8},  // 17
  '{6'd15, 8'd 75, 5'd8},  // 18
  '{6'd15, 8'd 97, 5'd8},  // 19
  '{6'd15, 8'd121, 5'd8},  // 20
  '{6'd17, 8'd 27, 5'd8},  // 21
  '{6'd17, 8'd 80, 5'd3},  // 22
  '{6'd17, 8'd102, 5'd1},  // 23
  '{6'd17, 8'd124, 5'd1},  // 24
  '{6'd19, 8'd 21, 5'd1},  // 25
  '{6'd19, 8'd 41, 5'd1},  // 26
  '{6'd25, 8'd 29, 5'd2},  // 27
  '{6'd25, 8'd 49, 5'd1},  // 28
  '{6'd25, 8'd103, 5'd1},  // 29
  '{6'd30, 8'd 46, 5'd8},  // 30
  '{6'd30, 8'd 76, 5'd8},  // 31
  '{6'd31, 8'd 46, 5'd8},  // 32
  '{6'd31, 8'd 76, 5'd8},  // 33
  '{6'd32, 8'd 46, 5'd8},  // 34
  '{6'd32, 8'd 76, 5'd8},  // 35
  '{6'd33, 8'd 46, 5'd8},  // 36
  '{6'd33, 8'd 76, 5'd8},  // 37
  '{6'd34, 8'd 46, 5'd8},  // 38
  '{6'd34, 8'd 76, 5'd8},  // 39
  '{6'd35, 8'd 46, 5'd8},  // 40
  '{6'd35, 8'd 76, 5'd8},  // 41
  '{6'd36, 8'd 46, 5'd8},  // 42
  '{6'd36, 8'd 76, 5'd8},  // 43
  '{6'd37, 8'd 46, 5'd8},  // 44
  '{6'd37, 8'd 76, 5'd8},  // 45
  '{6'd38, 8'd 46, 5'd8},  // 46
  '{6'd38, 8'd 76, 5'd8},  // 47
  '{6'd39, 8'd 46, 5'd8},  // 48
  '{6'd39, 8'd 76, 5'd8},  // 49
  '{6'd40, 8'd 46, 5'd8},  // 50
  '{6'd40, 8'd 76, 5'd8},  // 51
  '{6'd41, 8'd 46, 5'd8},  // 52
  '{6'd41, 8'd 76, 5'd8},  // 53
  '{6'd42, 8'd 46, 5'd8},  // 54
  '{6'd42, 8'd 76, 5'd8},  // 55
  '{6'd43, 8'd 46, 5'd8},  // 56
  '{6'd43, 8'd 76, 5'd8},  // 57
  '{6'd44, 8'd 46, 5'd8},  // 58
  '{6'd44, 8'd 76, 5'd8},  // 59
  '{6'd45, 8'd 46, 5'd8},  // 60
  '{6'd45, 8'd 76, 5'd8}   // 61
*/


// ========== DEBUG: ETIQUETAS IGNORADAS ==========
// IGNORADO: Fila 30, Col  40, Len 1 |                           |                     X0  = XXXXX
// IGNORADO: Fila 30, Col  70, Len 1 |                           | XXXX                X16 = XXXXX
// IGNORADO: Fila 31, Col  40, Len 1 |                           |                     X1  = XXXXX
// IGNORADO: Fila 31, Col  70, Len 1 |                           | XXXX                X17 = XXXXX
// IGNORADO: Fila 32, Col  40, Len 1 |                           |                     X2  = XXXXX
// IGNORADO: Fila 32, Col  70, Len 1 |                           | XXXX                X18 = XXXXX
// IGNORADO: Fila 33, Col  40, Len 1 |                           |                     X3  = XXXXX
// IGNORADO: Fila 33, Col  70, Len 1 |                           | XXXX                X19 = XXXXX
// IGNORADO: Fila 34, Col  40, Len 1 |                           |                     X4  = XXXXX
// IGNORADO: Fila 34, Col  70, Len 1 |                           | XXXX                X20 = XXXXX
// IGNORADO: Fila 35, Col  40, Len 1 |                           |                     X5  = XXXXX
// IGNORADO: Fila 35, Col  70, Len 1 |                           | XXXX                X21 = XXXXX
// IGNORADO: Fila 36, Col  40, Len 1 |                           |                     X6  = XXXXX
// IGNORADO: Fila 36, Col  70, Len 1 |                           | XXXX                X22 = XXXXX
// IGNORADO: Fila 37, Col  40, Len 1 |                           |                     X7  = XXXXX
// IGNORADO: Fila 37, Col  70, Len 1 |                           | XXXX                X23 = XXXXX
// IGNORADO: Fila 38, Col  40, Len 1 |                           |                     X8  = XXXXX
// IGNORADO: Fila 38, Col  70, Len 1 |                           | XXXX                X24 = XXXXX
// IGNORADO: Fila 39, Col  40, Len 1 |                           |                     X9  = XXXXX
// IGNORADO: Fila 39, Col  70, Len 1 |                           | XXXX                X25 = XXXXX
// IGNORADO: Fila 40, Col  40, Len 1 |                           |                     X10 = XXXXX
// IGNORADO: Fila 40, Col  70, Len 1 |                           | XXXX                X26 = XXXXX
// IGNORADO: Fila 41, Col  40, Len 1 |                           |                     X11 = XXXXX
// IGNORADO: Fila 41, Col  70, Len 1 |                           | XXXX                X27 = XXXXX
// IGNORADO: Fila 42, Col  40, Len 1 |                           |                     X12 = XXXXX
// IGNORADO: Fila 42, Col  70, Len 1 |                           | XXXX                X28 = XXXXX
// IGNORADO: Fila 43, Col  40, Len 1 |                           |                     X13 = XXXXX
// IGNORADO: Fila 43, Col  70, Len 1 |                           | XXXX                X29 = XXXXX
// IGNORADO: Fila 44, Col  40, Len 1 |                           |                     X14 = XXXXX
// IGNORADO: Fila 44, Col  70, Len 1 |                           | XXXX                X30 = XXXXX
// IGNORADO: Fila 45, Col  40, Len 1 |                           |                     X15 = XXXXX
// IGNORADO: Fila 45, Col  70, Len 1 |                           | XXXX                X31 = XXXXX
