module top_vga_display (
    input reset,                  // Reset del sistema
    input [31:0] pc_value, inst, imm, rs1, rs2, rd, a, b, res, data, out, wrb,
	 input [31:0] x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x20, x21, x22, x23, x24, x25, x26, x27, x28, 
  x29, x30, x31, 
	 input [2:0] ctrl, br,
	 input [3:0] alu_ctrl,
	 input [9:0] x,
	 input [9:0] y, 
    input video_on,              // ON mientras se cuentan los píxeles
    input clk,                   // Reloj de 25 MHz
	 output [7:0] VGA_R,       // Salida del color rojo
    output [7:0] VGA_G,       // Salida del color verde
    output [7:0] VGA_B        // Salida del color azul
);

	 reg [7:0] ascii;
	 reg [31:0] value;
  wire [63:0] value_ascii;
  wire [15:0] value_ascii_2;
  wire [7:0] value_ascii_1;
  wire [55:0] value_ascii_bin;
  wire [39:0] value_ascii_bin_5;
  wire [23:0] value_ascii_bin_3;
  reg [2:0] index;
  reg [2:0] x_counter;
  
	 
	 wire [7:0] fixed_ascii;
	 reg [1:0] case_;
	 reg [1:0] case_2;
  
  initial begin
    index <= 3'b000;
    x_counter <= 3'b000;
  end
	

	 bin_to_hex_ascii to_hex(
		.bin_in(value),
       .ascii_out(value_ascii)
		);
		
	bin_to_hex_ascii_2 to_hex_2(
		.bin_in(value[7:0]),
       .ascii_out(value_ascii_2)
		);
		
	bin_to_ascii to_ascii(
		.binary_in(value),
		.ascii_out(value_ascii_bin)
	);
	
	bin_to_ascii_5 to_ascii_5(
		.binary_in(value),
		.ascii_out(value_ascii_bin_5)
	);
	
	bin_to_ascii_3 to_ascii_3(
		.binary_in(value),
		.ascii_out(value_ascii_bin_3)
	);
	
	to_ascii hex(
		.hex_digit(value[3:0]),
		.ascii(value_ascii_1)
	);
		
	fixed_text_rom fixed_rom(
      .address({ y[8:4], x[9:3]}),
		.data(fixed_ascii)
		);
		
	ascii_test test(
      .clk(clk),
		 .video_on(video_on),
		 .ascii_char(ascii),
		 .x(x),
		 .y(y),
		 .reset(reset),
		 .VGA_R(VGA_R),
		 .VGA_G(VGA_G),
		 .VGA_B(VGA_B)
	);
	

	 
  always @(posedge clk or posedge reset) begin
    // Resetear el contador y el índice si hay un reset
    if (reset) begin
        index <= 3'b000;
        x_counter <= 3'b000;
    end else if (fixed_ascii == 8'h0) begin
        // Incrementar el contador de 0 a 7
        x_counter <= x_counter + 1;

        // Cada vez que el contador alcanza 8, actualizamos el índice
        if (x_counter == 3'b111) begin
            x_counter <= 3'b000;   // Reiniciar el contador
            index <= index + 1;    // Avanzar al siguiente segmento de 8 bits

            // Si el índice alcanza 7, reiniciarlo a 0
            if (index == 3'b111) begin
                index <= 3'b000;
            end
			end
		end else begin
		  index <= 3'b000;
        x_counter <= 3'b000;
		end
	end
	
	
  always @* begin
    if (~reset) begin
			case_ = 2'b00;
			case_2 = 2'b11;
			if (fixed_ascii == 8'h0) begin  
				if (x >= 120 && x < 184 && y < 16) begin
					value = pc_value;
					case_ = 2'b00;
            end else if(x >= 248 && x < 312 && y < 16) begin
					value = inst;
					case_ = 2'b00;
				end else if(x >= 392 && x < 400 && y < 16) begin
					value = br;
					case_ = 2'b11;
				end else if(x >= 456 && x < 520 && y < 16) begin
					value = wrb;
					case_ = 2'b00;
					
					
				end else if(x >= 48 && x < 112 && y >= 32 && y < 48) begin
					value = x0;
					case_ = 2'b00;
				end else if(x >= 144 && x < 208 && y >= 32 && y < 48) begin
					value = x1;
					case_ = 2'b00;
				end else if(x >= 240 && x < 304 && y >= 32 && y < 48) begin
					value = x2;
					case_ = 2'b00;
				end else if(x >= 336 && x < 400 && y >= 32 && y < 48) begin
					value = x3;
					case_ = 2'b00;
				end else if(x >= 432 && x < 496 && y >= 32 && y < 48) begin
					value = x4;
					case_ = 2'b00;
				end else if(x >= 528 && x < 592 && y >= 32 && y < 48) begin
					value = x5;
					case_ = 2'b00;
					
				end else if(x >= 48 && x < 112 && y >= 48 && y < 64) begin
					value = x6;
					case_ = 2'b00;
				end else if(x >= 144 && x < 208 && y >= 48 && y < 64) begin
					value = x7;
					case_ = 2'b00;
				end else if(x >= 240 && x < 304 && y >= 48 && y < 64) begin
					value = x8;
					case_ = 2'b00;
				end else if(x >= 336 && x < 400 && y >= 48 && y < 64) begin
					value = x9;
					case_ = 2'b00;
				end else if(x >= 440 && x < 504 && y >= 48 && y < 64) begin
					value = x10;
					case_ = 2'b00;
				end else if(x >= 544 && x < 608 && y >= 48 && y < 64) begin
					value = x11;
					case_ = 2'b00;
					
				end else if(x >= 48 && x < 112 && y >= 64 && y < 80) begin
					value = x12;
					case_ = 2'b00;
				end else if(x >= 152 && x < 216 && y >= 64 && y < 80) begin
					value = x13;
					case_ = 2'b00;
				end else if(x >= 256 && x < 320 && y >= 64 && y < 80) begin
					value = x14;
					case_ = 2'b00;
				end else if(x >= 360 && x < 424 && y >= 64 && y < 80) begin
					value = x15;
					case_ = 2'b00;
				end else if(x >= 464 && x < 528 && y >= 64 && y < 80) begin
					value = x16;
					case_ = 2'b00;
				end else if(x >= 568 && x < 632 && y >= 64 && y < 80) begin
					value = x17;
					case_ = 2'b00;
				
				end else if(x >= 48 && x < 112 && y >= 80 && y < 96) begin
					value = x18;
					case_ = 2'b00;
				end else if(x >= 152 && x < 216 && y >= 80 && y < 96) begin
					value = x19;
					case_ = 2'b00;
				end else if(x >= 256 && x < 320 && y >= 80 && y < 96) begin
					value = x20;
					case_ = 2'b00;
				end else if(x >= 360 && x < 424 && y >= 80 && y < 96) begin
					value = x21;
					case_ = 2'b00;
				end else if(x >= 464 && x < 528 && y >= 80 && y < 96) begin
					value = x22;
					case_ = 2'b00;
				end else if(x >= 568 && x < 632 && y >= 80 && y < 96) begin
					value = x23;
					case_ = 2'b00;
					
				end else if(x >= 48 && x < 112 && y >= 96 && y < 112) begin
					value = x24;
					case_ = 2'b00;
				end else if(x >= 152 && x < 216 && y >= 96 && y < 112) begin
					value = x25;
					case_ = 2'b00;
				end else if(x >= 256 && x < 320 && y >= 96 && y < 112) begin
					value = x26;
					case_ = 2'b00;
				end else if(x >= 360 && x < 424 && y >= 96 && y < 112) begin
					value = x27;
					case_ = 2'b00;
				end else if(x >= 464 && x < 528 && y >= 96 && y < 112) begin
					value = x28;
					case_ = 2'b00;
				end else if(x >= 568 && x < 632 && y >= 96 && y < 112) begin
					value = x29;
					case_ = 2'b00;
					
				end else if(x >= 96 && x < 160 && y >= 112 && y < 128) begin
					value = x30;
					case_ = 2'b00;
				end else if(x >= 200 && x < 264 && y >= 112 && y < 128) begin
					value = x31;
					case_ = 2'b00;
					
				end else if(x >= 88 && x < 144 && y >= 144 && y < 160) begin
					value = inst[31:25];
					case_ = 2'b01;
					case_2 = 2'b00;
				end else if (x >= 152 && x < 192 && y >= 144 && y < 160) begin
					value = inst[24:20];
					case_ = 2'b01;
					case_2 = 2'b01;
				end else if (x >= 200 && x < 240 && y >= 144 && y < 160) begin
					value = inst[19:15];
					case_ = 2'b01;
					case_2 = 2'b01;
				end else if (x >= 248 && x < 272 && y >= 144 && y < 160) begin
					value = inst[14:12];
					case_ = 2'b01;
					case_2 = 2'b10;
				end else if (x >= 280 && x < 320 && y >= 144 && y < 160) begin
					value = inst[11:7];
					case_ = 2'b01;
					case_2 = 2'b01;
				end else if (x >= 328 && x < 384 && y >= 144 && y < 160) begin
					value = inst[6:0];
					case_ = 2'b01;
					case_2 = 2'b00;
					
				end else if(x >= 88 && x < 144 && y >= 160 && y < 176) begin
					value = inst[6:0];
					case_ = 2'b01;
					case_2 = 2'b00;
				end else if (x >= 224 && x < 248 && y >= 160 && y < 176) begin
					value = inst[14:12];
					case_ = 2'b01;
					case_2 = 2'b10;
				end else if (x >= 328 && x < 384 && y >= 160 && y < 176) begin
					value = inst[31:25];
					case_ = 2'b01;
					case_2 = 2'b00;
				end else if (x >= 448 && x < 512 && y >= 160 && y < 176) begin
					value = imm;
					case_ = 2'b00;
					
				end else if (x >= 48 && x < 64 && y >= 176 && y < 192) begin
					value = inst[11:7];
					case_ = 2'b10;
				end else if (x >= 80 && x < 144 && y >= 176 && y < 192) begin
					value = rd;
					case_ = 2'b00;	
				end else if (x >= 200 && x < 216 && y >= 176 && y < 192) begin
					value = inst[19:15];
					case_ = 2'b10;
				end else if (x >= 240 && x < 304 && y >= 176 && y < 192) begin
					value = rs1;
					case_ = 2'b00;
				end else if (x >= 360 && x < 376 && y >= 176 && y < 192) begin
					value = inst[24:20];
					case_ = 2'b10;
				end else if (x >= 400 && x < 464 && y >= 176 && y < 192) begin
					value = rs2;
					case_ = 2'b00;
					
				end else if (x >= 88 && x < 152 && y >= 208 && y < 224) begin
					value = a;
					case_ = 2'b00;
				end else if (x >= 200 && x < 264 && y >= 208 && y < 224) begin
					value = b;
					case_ = 2'b00;
				end else if (x >= 312 && x < 376 && y >= 208 && y < 224) begin
					value = res;
					case_ = 2'b00;
				end else if (x >= 436 && x < 444 && y >= 208 && y < 224) begin
					value = alu_ctrl;
					case_ = 2'b11;
				
				end else if (x >= 144 && x < 208 && y >= 240 && y < 256) begin
					value = data;
					case_ = 2'b00;
				end else if (x >= 296 && x < 304 && y >= 240 && y < 256) begin
					value = ctrl;
					case_ = 2'b11;
				end else if (x >= 368 && x < 432 && y >= 240 && y < 256) begin
					value = ctrl;
					case_ = 2'b11;
					
				end else begin
					value = "X";
					case_ = 2'b11;
				end
					if (case_ == 2'b00) begin
						ascii = value_ascii[63 - index*8 -: 8];
					end else if (case_ == 2'b01) begin
						if(case_2 == 2'b00) begin 
							ascii = value_ascii_bin[55 - index*8 -: 8];
						end else if (case_2 == 2'b01) begin
							ascii = value_ascii_bin_5[39 - index*8 -: 8];
						end else if (case_2 == 2'b10) begin
							ascii = value_ascii_bin_3[23 - index*8 -: 8];
						end
					end else if (case_ == 2'b10) begin
						ascii = value_ascii_2[15 - index*8 -:8];
					end else if (case_ == 2'b11) begin
						ascii = value_ascii_1;
					end 
			end else begin
				ascii = fixed_ascii;
			end
    end
		
  end
 
	 

endmodule
