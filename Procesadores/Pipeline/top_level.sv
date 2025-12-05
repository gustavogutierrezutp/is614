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
  wire [31:0] address;
  wire [31:0] pc_plus_4;
  wire PCSrc;
  wire [31:0] instruction;
  wire [31:0] DataAlu;
  wire [31:0] AluA;
  wire [31:0] AluB;
  wire [31:0] AluA_mux;
  wire [31:0] AluB_mux;
  
  wire [6:0] opcode = if_id_instruction[6:0];
  wire [2:0] funct3 = if_id_instruction[14:12];
  wire [6:0] funct7 = if_id_instruction[31:25];
  wire [4:0] rd = if_id_instruction[11:7];
  wire [4:0] rs1 = if_id_instruction[19:15];
  wire [4:0] rs2 = if_id_instruction[24:20];
  
  reg [31:0] instructions [0:31];
  wire [31:0] registers [0:31];
  
  wire [4:0] AluOp;
  wire RUWr;
  wire AluASrc;
  wire AluBSrc;
  wire [2:0] ImmSrc;
  
  wire [31:0] imm_out;
  wire DMWR;
  wire [2:0]  DMCtrl;
  wire [31:0] DMOut;
  wire [7:0]  memory [0:31];
  wire [31:0] RU_DataWr;
  wire [1:0]  RUDataWrSrc;
  
  wire Branch;
  wire [4:0] BrOp;
  
  // Señales EBreak para cada etapa
  wire id_ex_EBreak;
  wire ex_mem_EBreak;
  wire mem_wb_EBreak;
  wire ebreak_active;
  wire EBreak;
  
  // Señales de control del pipeline
  wire stall_pipeline;
  wire flush_if_id, flush_id_ex, flush_ex_mem;
  
  logic [1:0] forward_a, forward_b;
  
  assign flush_ex_mem = 1'b0;

  // Señales IF/ID
  wire [31:0] if_id_pc;
  wire [31:0] if_id_pc_plus_4;
  wire [31:0] if_id_instruction;

  // Señales ID/EX
  wire [31:0] id_ex_pc;
  wire [31:0] id_ex_pc_plus_4;
  wire [31:0] id_ex_RU1;
  wire [31:0] id_ex_RU2;
  wire [31:0] id_ex_imm;
  wire [4:0]  id_ex_rs1;
  wire [4:0]  id_ex_rs2;
  wire [4:0]  id_ex_rd;
  wire        id_ex_RUWr;
  wire        id_ex_AluASrc;
  wire        id_ex_AluBSrc;
  wire [4:0]  id_ex_AluOp;
  wire        id_ex_DMWR;
  wire [2:0]  id_ex_DMCtrl;
  wire [1:0]  id_ex_RUDataWrSrc;
  wire        id_ex_Branch;
  wire [4:0]  id_ex_BrOp;

  // Señales EX/MEM
  wire [31:0] ex_mem_pc_plus_4;
  wire [31:0] ex_mem_DataAlu;
  wire [31:0] ex_mem_RU2;
  wire [4:0]  ex_mem_rd;
  wire        ex_mem_PCSrc;
  wire        ex_mem_RUWr;
  wire        ex_mem_DMWR;
  wire [2:0]  ex_mem_DMCtrl;
  wire [1:0]  ex_mem_RUDataWrSrc;

  // Señales MEM/WB
  wire [31:0] mem_wb_pc_plus_4;
  wire [31:0] mem_wb_DataAlu;
  wire [31:0] mem_wb_DMOut;
  wire [4:0]  mem_wb_rd;
  wire        mem_wb_RUWr;
  wire [1:0]  mem_wb_RUDataWrSrc;

  // Clock seleccionado
  logic clk_selected;

  // MUX del clock
  always_comb begin
      if (selector2)
          clk_selected = clk;        // Clock manual (KEY0)
      else
          clk_selected = CLOCK_50;   // Clock de la board
  end

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
	 .Branch(Branch),
    .BrOp(BrOp),
	 .EBreak(EBreak)
  );

  program_counter pc_inst(
    .clk(clk_selected),
    .rst_n(rst_n),
	 .stall(stall_pipeline),
    .PCSrc(ex_mem_PCSrc),      
	 .EBreak(mem_wb_EBreak),
    .pc_target(ex_mem_DataAlu),
    .pc_out(address),
    .pc_plus_4(pc_plus_4),
	 .ebreak_active(ebreak_active)
  );
  
  instruction_memory memory_inst(
    .address(address),
	 .page(2'b00),
    .instruction(instruction),
	 .show_memory(instructions)
  );

  IFID ifid_inst(
    .clk(clk_selected),
    .rst_n(rst_n),
    .stall(stall_pipeline),
    .flush(flush_if_id),
    
    // Entradas desde IF
    .pc_in(address),
    .pc_plus_4_in(pc_plus_4),
    .instruction_in(instruction),
    
    // Salidas hacia ID
    .pc_out(if_id_pc),
    .pc_plus_4_out(if_id_pc_plus_4),
    .instruction_out(if_id_instruction)
  );
  
  registers_unit ru_inst(
    .clk(clk_selected),
    .rst_n(rst_n),
    .rs1(rs1),              
    .rs2(rs2),              
    .rd(mem_wb_rd),         
    .DataWr(RU_DataWr),
    .RUWr(mem_wb_RUWr),     
    .RU1(AluA),
    .RU2(AluB),
    .registers(registers)
  );
  
  imm_generator imm_inst (
    .instruction(if_id_instruction),
    .ImmSrc(ImmSrc),
    .imm_out(imm_out)
  );
  
  IDEX idex_inst(
    .clk(clk_selected),
    .rst_n(rst_n),
    .stall(stall_pipeline),
    .flush(flush_id_ex),
    
    // Entradas desde ID
    .pc_in(if_id_pc),
    .pc_plus_4_in(if_id_pc_plus_4),
    .RU1_in(AluA),
    .RU2_in(AluB),
    .imm_in(imm_out),
    .rs1_in(rs1),
    .rs2_in(rs2),
    .rd_in(rd),
    
    // Señales de control de entrada
    .RUWr_in(RUWr),
    .AluASrc_in(AluASrc),
    .AluBSrc_in(AluBSrc),
    .AluOp_in(AluOp),
    .DMWR_in(DMWR),
    .DMCtrl_in(DMCtrl),
    .RUDataWrSrc_in(RUDataWrSrc),
    .Branch_in(Branch),
    .BrOp_in(BrOp),
	 .EBreak_in(EBreak),
    
    // Salidas hacia EX
    .pc_out(id_ex_pc),
    .pc_plus_4_out(id_ex_pc_plus_4),
    .RU1_out(id_ex_RU1),
    .RU2_out(id_ex_RU2),
    .imm_out(id_ex_imm),
    .rs1_out(id_ex_rs1),
    .rs2_out(id_ex_rs2),
    .rd_out(id_ex_rd),
    
    // Señales de control hacia EX
    .RUWr_out(id_ex_RUWr),
    .AluASrc_out(id_ex_AluASrc),
    .AluBSrc_out(id_ex_AluBSrc),
    .AluOp_out(id_ex_AluOp),
    .DMWR_out(id_ex_DMWR),
    .DMCtrl_out(id_ex_DMCtrl),
    .RUDataWrSrc_out(id_ex_RUDataWrSrc),
    .Branch_out(id_ex_Branch),
    .BrOp_out(id_ex_BrOp),
	 .EBreak_out(id_ex_EBreak)
  );

  // Señal para detectar si es instrucción LOAD
  wire id_ex_MemRead = (id_ex_RUDataWrSrc == 2'b01);

  // HAZARD DETECTION UNIT
  hazard_unit hdu_inst (
    .id_ex_rd(id_ex_rd),
    .id_ex_MemRead(id_ex_MemRead),
    .if_id_rs1(rs1),
    .if_id_rs2(rs2),
    .stall(stall_pipeline)
  );

  // FLUSH CONTROL
  flush_control fc_inst (
    .PCSrc(PCSrc),              
	 .stall(stall_pipeline),
    .flush_if_id(flush_if_id),
    .flush_id_ex(flush_id_ex)
  );
  
	mux_ALUA aluamux_inst(
		 .I0(alu_src_a),       
		 .I1(id_ex_pc),      
		 .S(id_ex_AluASrc),
		 .Y(AluA_mux)
	);

	mux_ALUB alubmux_inst(
		 .I0(alu_src_b_fwd),   
		 .I1(id_ex_imm),
		 .S(id_ex_AluBSrc),
		 .Y(AluB_mux)
	);

  alu alu_inst(
    .AluA(AluA_mux),
    .AluB(AluB_mux),
    .AluOp(id_ex_AluOp),
    .AluRes(DataAlu)
  );
  
	branch_unit branch_inst(
		 .A(alu_src_a),        
		 .B(alu_src_b_fwd),    
		 .Branch(id_ex_Branch),
		 .BrOp(id_ex_BrOp),
		 .branchOut(PCSrc)
	);
  
  EXMEM exmem_inst(
    .clk(clk_selected),
    .rst_n(rst_n),
    .stall(stall_pipeline),
    .flush(flush_ex_mem),
    
    // Entradas desde EX
    .pc_plus_4_in(id_ex_pc_plus_4),
    .DataAlu_in(DataAlu),
    .RU2_in(id_ex_RU2),
    .rd_in(id_ex_rd),
    .PCSrc_in(PCSrc),
    
    // Señales de control desde EX
    .RUWr_in(id_ex_RUWr),
    .DMWR_in(id_ex_DMWR),
    .DMCtrl_in(id_ex_DMCtrl),
    .RUDataWrSrc_in(id_ex_RUDataWrSrc),
	 .EBreak_in(id_ex_EBreak),
    
    // Salidas hacia MEM
    .pc_plus_4_out(ex_mem_pc_plus_4),
    .DataAlu_out(ex_mem_DataAlu),
    .RU2_out(ex_mem_RU2),
    .rd_out(ex_mem_rd),
    .PCSrc_out(ex_mem_PCSrc),
    
    // Señales de control hacia MEM
    .RUWr_out(ex_mem_RUWr),
    .DMWR_out(ex_mem_DMWR),
    .DMCtrl_out(ex_mem_DMCtrl),
    .RUDataWrSrc_out(ex_mem_RUDataWrSrc),
	 .EBreak_out(ex_mem_EBreak)
  ); 
 
  data_memory dm_inst(
    .clk(clk_selected),
    .rst_n(rst_n),
    .address(ex_mem_DataAlu),
    .DataWr(ex_mem_RU2),
    .DMWR(ex_mem_DMWR),
    .DMCtrl(ex_mem_DMCtrl),
    .DMOut(DMOut),
    .memory(memory)
  );
  
  MEMWB memwb_inst(
    .clk(clk_selected),
    .rst_n(rst_n),
    .stall(stall_pipeline),
    .flush(1'b0),  // WB no necesita flush
    
    // Entradas desde MEM
    .pc_plus_4_in(ex_mem_pc_plus_4),
    .DataAlu_in(ex_mem_DataAlu),
    .DMOut_in(DMOut),
    .rd_in(ex_mem_rd),
    
    // Señales de control desde MEM
    .RUWr_in(ex_mem_RUWr),
    .RUDataWrSrc_in(ex_mem_RUDataWrSrc),
	 .EBreak_in(ex_mem_EBreak),
    
    // Salidas hacia WB
    .pc_plus_4_out(mem_wb_pc_plus_4),
    .DataAlu_out(mem_wb_DataAlu),
    .DMOut_out(mem_wb_DMOut),
    .rd_out(mem_wb_rd),
    
    // Señales de control hacia WB
    .RUWr_out(mem_wb_RUWr),
    .RUDataWrSrc_out(mem_wb_RUDataWrSrc),
	 .EBreak_out(mem_wb_EBreak)
  );
  
  mux_DM mux_dm_inst(
    .I0(mem_wb_DataAlu),
    .I1(mem_wb_DMOut),
    .I2(mem_wb_pc_plus_4),
    .S(mem_wb_RUDataWrSrc),
    .Y(RU_DataWr)
  );
  
	// FORWARDING DETECTION UNIT
	forwarding_unit fwd_unit (
		 .id_ex_rs1(id_ex_rs1),
		 .id_ex_rs2(id_ex_rs2),
		 .ex_mem_rd(ex_mem_rd),
		 .ex_mem_RegWrite(ex_mem_RUWr),     
		 .mem_wb_rd(mem_wb_rd),
		 .mem_wb_RegWrite(mem_wb_RUWr),     
		 .forward_a(forward_a),
		 .forward_b(forward_b)
	);

	// MUX de forwarding en la etapa EX
	logic [31:0] alu_src_a, alu_src_b_fwd;

	always_comb begin
		 case (forward_a)
			  2'b00:   alu_src_a = id_ex_RU1;         
			  2'b10:   alu_src_a = ex_mem_DataAlu;    
			  2'b01:   alu_src_a = RU_DataWr;         
			  default: alu_src_a = id_ex_RU1;
		 endcase
	end

	always_comb begin
		 case (forward_b)
			  2'b00:   alu_src_b_fwd = id_ex_RU2;
			  2'b10:   alu_src_b_fwd = ex_mem_DataAlu;
			  2'b01:   alu_src_b_fwd = RU_DataWr;
			  default: alu_src_b_fwd = id_ex_RU2;
		 endcase
	end
  
  
	// SEÑAL PARA MOSTRAR DATO DE MEMORIA
	wire [31:0] mem_data_display;
	assign mem_data_display = ex_mem_DMWR ? ex_mem_RU2 : DMOut; //Si es Load mostrar DMOut y si es S mostrar AluB

	// MODULO VGA
	color vga_display (
	  .clock(CLOCK_50),
	  .rst_n(~rst_n),
	  
	  // ETAPA IF
	  .if_pc(address),
	  .if_instruction(instruction),
	  .if_pc_plus_4(pc_plus_4),
	  
	  // ETAPA ID
	  .id_pc(if_id_pc),
	  .id_instruction(if_id_instruction),
	  .id_pc_plus_4(if_id_pc_plus_4),
	  .id_rs1(rs1),
	  .id_rs2(rs2),
	  .id_rd(rd),
	  .id_imm(imm_out),
	  .id_RU1(AluA),
	  .id_RU2(AluB),
	  .id_RUWr(RUWr),
	  .id_Branch(Branch),
	  .id_BrOp(BrOp),
	  
	  // ETAPA EX
	  .ex_pc(id_ex_pc),
	  .ex_pc_plus_4(id_ex_pc_plus_4),
	  .ex_alu_a(AluA_mux),
	  .ex_alu_b(AluB_mux),
	  .ex_alu_result(DataAlu),
	  .ex_alu_op(id_ex_AluOp),
	  .ex_rd(id_ex_rd),
	  .ex_branch_taken(PCSrc),
	  .ex_RUWr(id_ex_RUWr),
	  
	  // ETAPA MEM
	  .mem_alu_result(ex_mem_DataAlu),
	  .mem_data_in(ex_mem_RU2),
	  .mem_data_out(DMOut),
	  .mem_rd(ex_mem_rd),
	  .mem_write_en(ex_mem_DMWR),
	  .mem_RUWr(ex_mem_RUWr),
	  .mem_DMCtrl(ex_mem_DMCtrl),
	  
	  // ETAPA WB
	  .wb_data(RU_DataWr),
	  .wb_rd(mem_wb_rd),
	  .wb_write_en(mem_wb_RUWr),
	  .mem_wb_RUDataWrSrc(mem_wb_RUDataWrSrc),
	  
	  // SEÑALES DE CONTROL
	  .forward_a(forward_a),           
	  .forward_b(forward_b),          
	  .stall(stall_pipeline),          
	  .flush_if_id(flush_if_id),     
	  .flush_id_ex(flush_id_ex),
	  
	  // ARRAYS
	  .registers(registers),
	  .memory(memory),
	  .instructions(instructions),
	  
	  .EBreak(ebreak_active),
	  
	  // SALIDAS VGA
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

  // LEDS
  assign leds[7:0] = address[7:0];
  assign leds[8]   = RUWr;
  assign leds[9]   = AluBSrc;

endmodule