module top_level(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        sw0,
    input  wire        sw1,
    input  wire        sw2,
    input  wire        sw3,
    input  wire        sw9,
    input  wire        step_button,
    output wire [6:0]  display0,
    output wire [6:0]  display1,
    output wire [6:0]  display2,
    output wire [6:0]  display3,
    output wire [9:0]  leds,
    output wire [7:0]  vga_red,
    output wire [7:0]  vga_green,
    output wire [7:0]  vga_blue,
    output wire        vga_hsync,
    output wire        vga_vsync,
    output wire        vga_clock
);

    wire VGA_CLK_83M5;

    wire [31:0] address;
    wire [31:0] inst;
    wire [31:0] next_pc;
    wire [31:0] branch_target;
    wire        branch_taken;

    wire [6:0]  opcode = inst[6:0];
    wire [2:0]  funct3 = inst[14:12];
    wire [6:0]  funct7 = inst[31:25];
    wire [4:0]  rs1_addr = inst[19:15];
    wire [4:0]  rs2_addr = inst[24:20];
    wire [4:0]  rd_addr  = inst[11:7];
    wire [4:0]  ALUOp;
    wire [2:0]  IMMSrc;
    wire        ALUBSrc;
    wire        RegWrite;
    wire        MemtoReg;
    wire        DMWR;
    wire [2:0]  DMCtrl;
    wire [4:0]  BrOp;
    wire [31:0] imm_ext;
    wire [31:0] rs1_data, rs2_data;
    wire [31:0] data_wr_from_regbank;
    wire [31:0] alu_a;
    wire [31:0] alu_b;
    wire [31:0] alu_res;
    wire [31:0] mem_data;
    wire [31:0] wb_data;

    reg clk_button;
    assign clk_button = ~step_button;

    assign alu_a = rs1_data;
    assign alu_b = (ALUBSrc) ? imm_ext : rs2_data;
    assign wb_data = (MemtoReg) ? mem_data : alu_res;
    assign data_wr_from_regbank = wb_data;

    reg [31:0] pc_reg;
    wire step_req;
    reg [2:0] sw0_sync;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            sw0_sync <= 3'b000;
        end else begin
            sw0_sync <= {sw0_sync[1:0], sw0};
        end
    end
    assign step_req = (sw0_sync[2] & ~sw0_sync[1]);

    assign branch_target = (pc_reg + 32'd4) + imm_ext;
    assign next_pc = branch_taken ? branch_target : (pc_reg + 32'd4);

    program_counter pc_inst (
        .clk(clk_button),
        .reset(~rst_n),
        .NextPC(next_pc),
        .Pc(pc_reg)
    );

    assign address = pc_reg;

    instruction_memory imem (
        .address(address),
        .inst(inst)
    );

    control_unit cu_inst (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .ALUOp(ALUOp),
        .IMMSrc(IMMSrc),
        .ALUBSrc(ALUBSrc),
        .RegWrite(RegWrite),
        .MemtoReg(MemtoReg),
        .DMWR(DMWR),
        .DMCtrl(DMCtrl),
        .BrOp(BrOp)
    );

    genInm genInm_inst (
        .instr(inst),
        .IMMSrc(IMMSrc),
        .imm_out(imm_ext)
    );

    wire [31:0] all_registers [0:31];  // Todos los registros para VGA debug

    registers_unit ru_inst (
        .clk(clk_button),
        .rstn(rst_n),
        .rs1(rs1_addr),
        .rs2(rs2_addr),
        .rd(rd_addr),
        .ru_wr(RegWrite),
        .data_wr(data_wr_from_regbank),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .registers_out(all_registers)  // Salida de todos los registros
    );

    alu alu_inst (
        .a(alu_a),
        .b(alu_b),
        .alu_op(ALUOp),
        .alu_res(alu_res)
    );

    branch_unit bu_inst (
        .ru_X1(rs1_data),
        .ru_X2(rs2_data),
        .BrOp(BrOp),
        .branch_taken(branch_taken)
    );

    data_memory dm_inst (
        .clk(clk_button),
        .DMWR(DMWR),
        .DMCtrl(DMCtrl),
        .Address(alu_res),
        .DataWr(rs2_data),
        .DataRd(mem_data)
    );

    
    // Señales para escritura VGA
    wire [12:0] vga_write_addr;
    wire [7:0] vga_write_data;
    wire vga_we;

    vga vga_inst (
        .CLK_50(clk),
        .reset(1'b0),
        .address_w(vga_write_addr),
        .we(vga_we),
        .ascii_char_data(vga_write_data),
        .VGA_HS(vga_hsync),
        .VGA_VS(vga_vsync),
        .VGA_R(vga_red),
        .VGA_G(vga_green),
        .VGA_B(vga_blue),
        .VGA_CLK_83M5(VGA_CLK_83M5)
    );

    // Módulo para escribir señales de debug en VGA
    write_vga write_vga_inst (
        .clk(clk),
        .vga_clk(VGA_CLK_83M5),
        .rst_n(rst_n),
        .enable(clk),  // Escribir cuando se ejecuta un step
        
        // Señales de la CPU
        .pc(pc_reg),
        .next_pc(next_pc),
        .inst(inst),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .data_wr(data_wr_from_regbank),
        .ru_wr(RegWrite),
        .imm_ext(imm_ext),
        .imm_src(IMMSrc),
        .alu_op(ALUOp),
        .alu_a(alu_a),
        .alu_b(alu_b),
        .alu_res(alu_res),
        .alu_b_src(ALUBSrc),
        .mem_address(alu_res),
        .mem_data_read(mem_data),
        .mem_data_write(rs2_data),
        .dm_wr(DMWR),
        .dm_ctrl(DMCtrl),
        .br_op(BrOp),
        .branch_taken(branch_taken),
        .mem_to_reg(MemtoReg),
        
        // Registros
        .registers(all_registers),
        
        // Salidas para VGA
        .vga_write_addr(vga_write_addr),
        .vga_write_data(vga_write_data),
        .vga_we(vga_we)
    );


    reg [31:0] visible32_sel;

    always @(*) begin
        if (~rst_n) visible32_sel = 32'h00000000;
        else if (sw0 && sw1) visible32_sel = alu_res;
        else if (sw0) visible32_sel = wb_data;
        else visible32_sel = wb_data;
    end

    wire [15:0] visible16_disp = (sw0) ? visible32_sel[31:16] : visible32_sel[15:0];
    wire [3:0] nib0 = visible16_disp[3:0];
    wire [3:0] nib1 = visible16_disp[7:4];
    wire [3:0] nib2 = visible16_disp[11:8];
    wire [3:0] nib3 = visible16_disp[15:12];

    hex7seg hex0(.val(nib0), .display(display0));
    hex7seg hex1(.val(nib1), .display(display1));
    hex7seg hex2(.val(nib2), .display(display2));
    hex7seg hex3(.val(nib3), .display(display3));

    assign leds[4:0] = ALUOp;
    assign leds[7:5] = IMMSrc;
    assign leds[8]   = ALUBSrc;
    assign leds[9]   = RegWrite;

    reg [23:0] write_div;
	reg [3:0]  write_idx;
	reg [31:0] writer_val;
	integer i;
	reg [3:0] nib;
	integer nib_i;

    assign vga_clock = VGA_CLK_83M5;
endmodule