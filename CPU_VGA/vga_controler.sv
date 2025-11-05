module vga (
    input CLK_50,
    input reset,
    input [7:0] ascii_char_data,
    input [12:0] address_w,
    input we,
    output VGA_HS,
    output VGA_VS,
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B,
    output VGA_CLK_83M5
);

    wire vgaclk;
	clock1280x800 vgaclock(
		.clock50(CLK_50),
		.reset(reset),
		.vgaclk(vgaclk)
	  );

    wire        active;
    wire [11:0] x;
    wire [11:0] y;

    wire [7:0] ascii_char_vga;

    vga_controller_1280x800 vga_ctrl (
        .clk_pixel(vgaclk), //83.3333 MHz
        .reset(reset),
        .hsync(VGA_HS),
        .vsync(VGA_VS),
        .active_video(active),
        .px_x(x),
        .px_y(y)
    );


    text_mode #(.DEBUG_TILES(1'b0)) text_mode_inst (
        .clk(vgaclk),
        .video_on(active),
        .ascii_char(ascii_char_vga),
        .x(x),
        .y(y),
        .reset(reset),
        .vga_red(VGA_R),
        .vga_green(VGA_G),
        .vga_blue(VGA_B)
    );

        screen_ram vga_screen_ram (
        .address_r(13'((y[9:4] * 160) + x[10:3])),
        .address_w(address_w),
        .data(ascii_char_data),
        .clk(VGA_CLK_83M5),
        .we(we),
        .char_out(ascii_char_vga)
    );


    assign VGA_CLK_83M5 = vgaclk;

endmodule