module top_level (
    // ENTRADAS
    input  logic        CLOCK_50,
    input  logic        clk,
    input  logic        rst_n,
    input  logic        selector,
    input  logic        selector2,
    
    // SALIDAS
    output logic [6:0]  HEX0,
    output logic [6:0]  HEX1,
    output logic [6:0]  HEX2,
    output logic [6:0]  HEX3,
    output logic [9:0]  leds,
    
    // SALIDAS VGA
    output logic [7:0]  vga_red,
    output logic [7:0]  vga_green,
    output logic [7:0]  vga_blue,
    output logic        vga_hsync,
    output logic        vga_vsync,
    output logic        vga_clock
);

  // SEÑALES DEL PROCESADOR
  wire [31:0] next_pc;
  wire [31:0] address;
  wire [31:0] instruction;
  wire [31:0] DataAlu;
  wire [31:0] AluA;
  wire [31:0] AluB;
  wire [31:0] AluA_mux;
  wire [31:0] AluB_mux;

  wire [6:0] opcode = instruction[6:0];
  wire [2:0] funct3 = instruction[14:12];
  wire [6:0] funct7 = instruction[31:25];
  
  wire [4:0] rd = instruction[11:7];
  wire [4:0] rs1 = instruction[19:15];
  wire [4:0] rs2 = instruction[24:20];
  wire [31:0] registers [0:31];
  
  wire [4:0] AluOp;
  wire RUWr;
  wire AluASrc;
  wire AluBSrc;
  wire [1:0]  ImmSrc;
  
  wire [31:0] imm_out;
  wire DMWR;
  wire [2:0]  DMCtrl;
  wire [31:0] DMOut;
  wire [7:0]  memory [0:31];
  wire [31:0] RU_DataWr;
  wire [1:0]  RUDataWrSrc;
  wire [4:0]  BrOp;

  // MÓDULOS DEL PROCESADOR
  control_unit cu_inst(
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .RUWr(RUWr),
    .AluASrc(AluASrc),
    .AluBSrc(AluBSrc),
    .AluOp(AluOp),
    .ImmSrc(ImmSrc),
    .DMWR(DMWR),
    .DMCtrl(DMCtrl),
    .RUDataWrSrc(RUDataWrSrc),
    .BrOp(BrOp)
  );

  program_counter pc_inst(
    .clk(clk),
    .rst_n(rst_n),
    .pc_out(address)
  );
  
  instruction_memory memory_inst(
    .address(address),
    .instruction(instruction)
  );
  
  registers_unit ru_inst(
    .clk(clk),
	 .rst_n(rst_n),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .DataWr(RU_DataWr),
    .RUWr(RUWr),
    .RU1(AluA),
    .RU2(AluB),
	 .registers(registers)
  );
  
  imm_generator imm_inst (
    .instruction(instruction),
    .ImmSrc(ImmSrc),
    .imm_out(imm_out)
  );
  
  mux_ALUA aluamux_inst(
    .I0(AluA),
    .I1(address),
    .S(AluASrc),
    .Y(AluA_mux)
  );
  
  mux_ALUB alubmux_inst(
    .I0(AluB),
    .I1(imm_out),
    .S(AluBSrc),
    .Y(AluB_mux)
  );

  alu alu_inst(
    .AluA(AluA_mux),
    .AluB(AluB_mux),
    .AluOp(AluOp),
    .AluRes(DataAlu)
  );
  
  data_memory dm_inst(
    .clk(clk),
	 .rst_n(rst_n),
    .address(DataAlu),
    .DataWr(AluB),
    .DMWR(DMWR),
    .DMCtrl(DMCtrl),
    .DMOut(DMOut),
	 .memory(memory)
  );
  
  mux_DM mux_dm_inst(
    .I0(DataAlu),
    .I1(DMOut),
    .I2(32'h01400393),
    .S(RUDataWrSrc),
    .Y(RU_DataWr)
  );
  
  // SEÑAL PARA MOSTRAR DATO DE MEMORIA
  wire [31:0] mem_data_display;
  assign mem_data_display = DMWR ? AluB : DMOut; //Si es Load mostrar DMOut y si es S mostrar AluB

  // MODULO VGA DEBUG
  color vga_display (
    .clock(CLOCK_50),           // Clock 50 MHz
    .sw0(~rst_n),               // Reset
    
    .pc_value(address),         
    .instruction(instruction),  
    .alu_result(DataAlu),       
    .reg_data1(AluA),           
    .reg_data2(AluB),           
    
    .imm_value(imm_out),        
    .mem_data_out(mem_data_display),  
    .mem_address(DataAlu),      
    .alu_op(AluOp),             
    .reg_write_en(RUWr),        
    .mem_write_en(DMWR),        
	 .registers(registers),
	 .memory(memory),
	 .AluASrc(AluASrc),
	 .AluBSrc(AluBSrc),
    .ImmSrc(ImmSrc),
    .DMCtrl(DMCtrl),
    .DMOut(DMOut),
    .RU_DataWr(RU_DataWr),
    .RUDataWrSrc(RUDataWrSrc),
	 .AluA(AluA),
	 .AluB(AluB),
	 .AluA_mux(AluA_mux),
	 .AluB_mux(AluB_mux),
    
    // Salidas VGA
    .vga_red(vga_red),
    .vga_green(vga_green),
    .vga_blue(vga_blue),
    .vga_hsync(vga_hsync),
    .vga_vsync(vga_vsync),
    .vga_clock(vga_clock)
  );

  // DISPLAYS 7 SEGMENTOS
  logic [15:0] selected_16_reg;

  always @(*) begin
    if (selector == 1'b0)
      selected_16_reg <= instruction[15:0];
    else
      selected_16_reg <= DataAlu[15:0];
  end

  hex7seg d0 (.val(selected_16_reg[3:0]), .display(HEX0));
  hex7seg d1 (.val(selected_16_reg[7:4]), .display(HEX1));
  hex7seg d2 (.val(selected_16_reg[11:8]), .display(HEX2));
  hex7seg d3 (.val(selected_16_reg[15:12]), .display(HEX3));

  // LEDS DE DEBUG
  assign leds[7:0] = address[7:0];
  assign leds[8]   = RUWr;
  assign leds[9]   = AluBSrc;

endmodule