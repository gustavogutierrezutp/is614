module top_level(
  input  wire       clk,
  input  wire       rst_n,
  input  wire       sw9,
  input  wire       sw8,
  input  wire       sw7,
  input  wire       sw6,
  output wire [6:0] displayA,
  output wire [6:0] displayB,
  output wire [6:0] displayC,
  output wire [6:0] displayD
);

  // PC
  wire [31:0] next_pc;
  wire [31:0] address;

  pc pc_inst(
    .clk(clk),
    .rst(~rst_n),      
    .next_pc(next_pc),
    .pc_out(address)   
  );

  // Instruction Memory
  wire [31:0] instr;

    instruction_memory imem_inst (
      .clk(clk),
      .address(address[6:2]),
      .instruction(instr)
    );

  // Instruction fields
  wire [6:0] funct7 = instr[31:25];
  wire [4:0] rs2    = instr[24:20];
  wire [4:0] rs1    = instr[19:15];
  wire [2:0] funct3 = instr[14:12];
  wire [4:0] rd     = instr[11:7];
  wire [6:0] opcode = instr[6:0];

  // Immediate Generator
  wire [31:0] imm_extended;
  wire [2:0] immsrc;

  assign immsrc = (opcode == 7'b0010011) ? 3'b000 :
                   (opcode == 7'b0000011) ? 3'b000 :
                   (opcode == 7'b0100011) ? 3'b001 :
                   (opcode == 7'b1100011) ? 3'b010 :
                   (opcode == 7'b0110111) ? 3'b011 :
                   (opcode == 7'b0010111) ? 3'b011 :
                   (opcode == 7'b1101111) ? 3'b100 :
                   3'b000;

  imm_gen imm_gen_inst (
    .instruction(instr),
    .immsrc(immsrc),
    .imm_out(imm_extended)
  );

  // Control Unit
  wire [3:0] ALU_op;
  wire       ALU_src;
  wire       reg_write;
  wire       mem_to_reg;
  wire       mem_write;
  wire       branch;
  wire       jump;
  wire [2:0] branch_type;

  control_unit control_inst (
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .ALU_op(ALU_op),
    .ALU_src(ALU_src),
    .reg_write(reg_write),
    .mem_to_reg(mem_to_reg),
    .mem_write(mem_write),
    .branch(branch),
    .jump(jump),
    .branch_type(branch_type)
  );

  // Register File
  wire [31:0] rs1_data, rs2_data;
  wire [31:0] pc_plus_4 = address + 4;
  wire [31:0] data_wr = jump ? pc_plus_4 : (mem_to_reg ? mem_data : ALU_res);

  registers_unit regfile_inst (
    .clk(clk),
    .rst(~rst_n),      
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .ru_wr(reg_write),
    .data_wr(data_wr),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data)
  );

  // ALU
  wire [31:0] ALU_res;
  wire [31:0] ALU_B;

  assign ALU_B = ALU_src ? imm_extended : rs2_data;

  alu alu_inst (
    .A(rs1_data),
    .B(ALU_B),
    .ALU_op(ALU_op),
    .ALU_res(ALU_res)
  );

  // Branch Unit
  wire branch_taken;

  branch_unit branch_unit_inst (
    .rs1_data(rs1_data),
    .rs2_data(rs2_data),
    .branch_type(branch_type),
    .branch(branch),
    .branch_taken(branch_taken)
  );

  // PC Logic
  wire [31:0] pc_branch = address + imm_extended;
  wire        pc_src = (branch_taken | jump);
  wire        is_jalr = (opcode == 7'b1100111);
  wire [31:0] jump_target = is_jalr ? ALU_res : pc_branch;
  assign next_pc = pc_src ? jump_target : pc_plus_4;

  // Data Memory
  wire [31:0] mem_data;

  data_memory dmem_inst (
    .clk(clk),
    .address(ALU_res),
    .DMWR(rs2_data),
    .DMCTRL(funct3),
    .mem_write(mem_write),
    .Datard(mem_data)
  );

  // Display selector
  // sw9: muestra mitad alta/baja
  // sw8-sw6: selecciona señal
  //   000: PC
  //   001: Instrucción
  //   010: rs1_data
  //   011: rs2_data
  //   100: Immediate
  //   101: Resultado ALU
  //   110: Memoria de datos
  //   111: Dato escrito a rd

  // Señales intermedias explícitas para depuración
  wire sel_pc         = (~sw8 & ~sw7 & ~sw6);  // 000
  wire sel_instr      = (~sw8 & ~sw7 &  sw6);  // 001
  wire sel_rs1        = (~sw8 &  sw7 & ~sw6);  // 010
  wire sel_rs2        = (~sw8 &  sw7 &  sw6);  // 011
  wire sel_imm        = ( sw8 & ~sw7 & ~sw6);  // 100
  wire sel_alu_res    = ( sw8 & ~sw7 &  sw6);  // 101
  wire sel_mem_data   = ( sw8 &  sw7 & ~sw6);  // 110
  wire sel_data_wr    = ( sw8 &  sw7 &  sw6);  // 111

  reg [31:0] selected_value;
  always @(*) begin
    if (sel_pc)
      selected_value = address;           // 000: PC
    else if (sel_instr)
      selected_value = instr;             // 001: Instrucción
    else if (sel_rs1)
      selected_value = rs1_data;          // 010: Fuente 1
    else if (sel_rs2)
      selected_value = rs2_data;          // 011: Fuente 2
    else if (sel_imm)
      selected_value = imm_extended;      // 100: Inmediato
    else if (sel_alu_res)
      selected_value = ALU_res;           // 101: Resultado ALU
    else if (sel_mem_data)
      selected_value = mem_data;          // 110: Dato memoria
    else if (sel_data_wr)
      selected_value = data_wr;           // 111: Dato escrito en rd
    else
      selected_value = 32'hDEADBEEF;      // Default (no debería ocurrir)
  end

  wire [15:0] value_to_display = sw9 ? selected_value[31:16] : selected_value[15:0];

  // Displays
  hex7seg display0(.val(value_to_display[3:0]),   .display(displayA));
  hex7seg display1(.val(value_to_display[7:4]),   .display(displayB));
  hex7seg display2(.val(value_to_display[11:8]),  .display(displayC));
  hex7seg display3(.val(value_to_display[15:12]), .display(displayD));

endmodule
