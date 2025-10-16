module top_level(
  input  wire clk,
  input  wire rst_n, // reset activo bajo en la placa
  output wire [6:0]  display,
  output wire [9:0]  leds
);

  // Convertir reset activo-bajo a activo-alto para los módulos
  logic reset;
  assign reset = ~rst_n;

  // Program Counter
  logic [31:0] pc;
  logic [31:0] pc_next;
  logic [31:0] pc_plus4;

  pc u_pc (
    .clk(clk),
    .reset(reset),
    .pc_next(pc_next),
    .pc(pc)
  );

  // PC + 4 (combinacional)
  assign pc_plus4 = pc + 32'd4;

  // Instruction Memory
  logic [31:0] instr;

  instr_mem u_imem (
    .addr(pc),
    .instr(instr)
  );

  // Instruction fields
  logic [6:0]  opcode;
  logic [4:0]  rd_idx;
  logic [2:0]  funct3;
  logic [6:0]  funct7;
  logic [4:0]  rs1_idx;
  logic [4:0]  rs2_idx;

  assign opcode  = instr[6:0];
  assign rd_idx  = instr[11:7];
  assign funct3  = instr[14:12];
  assign rs1_idx = instr[19:15];
  assign rs2_idx = instr[24:20];
  assign funct7  = instr[31:25];

  // Control Unit
  logic        Branch;
  logic        MemRead;
  logic        MemtoReg;
  logic [1:0]  ALUOp;
  logic        MemWrite;
  logic        ALUSrc;
  logic        RegWrite;

  control_unit u_ctrl (
    .opcode(opcode),
    .Branch(Branch),
    .MemRead(MemRead),
    .MemtoReg(MemtoReg),
    .ALUOp(ALUOp),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite)
  );

  // Register File
  logic [31:0] reg_rd1;
  logic [31:0] reg_rd2;
  logic [31:0] write_back_data;

  reg_file u_regfile (
    .clk(clk),
    .reset(reset),
    .reg_write(RegWrite),
    .rs1(rs1_idx),
    .rs2(rs2_idx),
    .rd(rd_idx),
    .write_data(write_back_data),
    .read_data1(reg_rd1),
    .read_data2(reg_rd2)
  );

  // Immediate Generator
  logic [31:0] imm_out;

  imm_gen u_imm (
    .instr(instr),
    .imm_out(imm_out)
  );

  // ALU Control
  logic [3:0]  alu_ctrl;

  alu_control u_aluctrl (
    .ALUOp(ALUOp),
    .funct3(funct3),
    .funct7(funct7),
    .alu_ctrl(alu_ctrl)
  );

  // ALU input B MUX (ALUSrc)
  logic [31:0] alu_b;

  // instantiate generic 32-bit MUX
  mltplx #(.WIDTH(32)) u_mux_alusrc (
    .in0(reg_rd2),
    .in1(imm_out),
    .sel(ALUSrc),
    .out(alu_b)
  );

  // ALU
  logic [31:0] alu_result;
  logic        alu_zero;

  alu u_alu (
    .a(reg_rd1),
    .b(alu_b),
    .alu_ctrl(alu_ctrl),
    .result(alu_result),
    .zero(alu_zero)
  );

  // Data Memory (for loads/stores)
  logic [31:0] mem_read_data;

  data_mem u_dmem (
    .clk(clk),
    .mem_read(MemRead),
    .mem_write(MemWrite),
    .addr(alu_result),        // dirección calculada por la ALU
    .write_data(reg_rd2),     // dato a almacenar (rs2)
    .read_data(mem_read_data)
  );

  // Write-back MUX (MemToReg)
  mltplx #(.WIDTH(32)) u_mux_memtoreg (
    .in0(alu_result),
    .in1(mem_read_data),
    .sel(MemtoReg),
    .out(write_back_data)
  );

  // ---------------------------
  // Branch target calculation and PC next selection
  // PCSrc = Branch & Zero
  // branch_target = pc + imm_out
  // ---------------------------
  logic pc_src;
  logic [31:0] branch_target;

  assign pc_src = Branch & alu_zero;
  assign branch_target = pc + imm_out; // imm_out already has LSB=0 for B-type (imm*), imm is sign-extended

  // PC next selection: PC+4 or branch target
  mltplx #(.WIDTH(32)) u_mux_pc (
    .in0(pc_plus4),
    .in1(branch_target),
    .sel(pc_src),
    .out(pc_next)
  );

  // Outputs: display and leds
  hex7seg display0 (
    .val(pc[3:0]),
    .display(display)
  );

  // Show some status on leds:
  // bits [9:0] = lower 10 bits of alu_result (as an example / debug)
  assign leds = alu_result[9:0];

endmodule
