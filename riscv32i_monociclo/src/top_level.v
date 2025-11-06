module top_level(
    input wire clk,
    input wire clk_fpga,
	 input wire reset,
	 input reset_core,
    output wire [7:0] VGA_R,       // Salida color rojo (8 bits)
    output wire [7:0] VGA_G,       // Salida color verde (8 bits)
    output wire [7:0] VGA_B,       // Salida color azul (8 bits)
    output wire VGA_CLK,           // Reloj VGA
    output wire VGA_SYNC_N,        // Sincronización VGA (siempre en bajo)
    output wire VGA_BLANK_N,       // Señal de blanking
    output wire VGA_HS,            // Sincronización horizontal
    output wire VGA_VS             // Sincronización vertical
);

   wire video_on; 
	wire [9:0] x, y; 
	wire [31:0] pc, inst, imm, rs1, rs2, rd, a, b, res, data, out, wrb;
	wire [31:0] x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, 
  x29, x30, x31;
  wire [2:0] br, ctrl;
  wire [3:0] alu_ctrl;
	
	
	core core(
		.clk(clk),
		.pc_vga(pc),
		.reset(~reset_core),
		.inst(inst),
		.imm(imm),
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd),
		.a(a),
		.b(b),
		.res(res),
		.data(data),
		.out(out),
		.ctrl(ctrl),
		.br(br),
		.wrb(wrb),
		.alu_ctrl(alu_ctrl),
		.x0(x0),
		  .x1(x1),
		  .x2(x2),
		  .x3(x3),
		  .x4(x4),
		  .x5(x5),
		  .x6(x6),
		  .x7(x7),
		  .x8(x8),
		  .x9(x9),
		  .x10(x10),
		  .x11(x11),
		  .x12(x12),
		  .x13(x13),
		  .x14(x14),
		  .x15(x15),
		  .x16(x16),
		  .x17(x17),
		  .x18(x18),
		  .x19(x19),
		  .x20(x20),
		  .x21(x21),
		  .x22(x22),
		  .x23(x23),
		  .x24(x24),
		  .x25(x25),
		  .x26(x26),
		  .x27(x27),
		  .x28(x28),
		  .x29(x29),
		  .x30(x30),
		  .x31(x31)
	);
	
    vga_controller vga (
        .clk_50MHz(clk_fpga),
        .reset(reset),
        .video_on(video_on),
        .hsync(VGA_HS),
		  .vsync(VGA_VS),
        .clk(VGA_CLK),
        .x(x),
        .y(y)
    );
		
	top_vga_display display(
		.reset(reset),
		.pc_value(pc),
		.inst(inst),
		.video_on(video_on),
		.x(x),
		.y(y),
		.clk(VGA_CLK),
		.imm(imm),
		.rs1(rs1),
		.rs2(rs2),
		.rd(rd),
		.a(a),
		.b(b),
		.res(res),
		.data(data),
		.out(out),
		.ctrl(ctrl),
		.br(br),
		.wrb(wrb),
		.alu_ctrl(alu_ctrl),
		.x0(x0),
		  .x1(x1),
		  .x2(x2),
		  .x3(x3),
		  .x4(x4),
		  .x5(x5),
		  .x6(x6),
		  .x7(x7),
		  .x8(x8),
		  .x9(x9),
		  .x10(x10),
		  .x11(x11),
		  .x12(x12),
		  .x13(x13),
		  .x14(x14),
		  .x15(x15),
		  .x16(x16),
		  .x17(x17),
		  .x18(x18),
		  .x19(x19),
		  .x20(x20),
		  .x21(x21),
		  .x22(x22),
		  .x23(x23),
		  .x24(x24),
		  .x25(x25),
		  .x26(x26),
		  .x27(x27),
		  .x28(x28),
		  .x29(x29),
		  .x30(x30),
		  .x31(x31),
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B)
	);
	
	

    // Señales VGA adicionales
    assign VGA_SYNC_N = 0;          // Sincronización en bajo
    assign VGA_BLANK_N = video_on;  // Señal de blanking

endmodule

