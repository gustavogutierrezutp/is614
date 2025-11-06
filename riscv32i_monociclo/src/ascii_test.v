module ascii_test(
    input clk,
    input video_on,
	 input [7:0] ascii_char,
    input [9:0] x, y,
	 input reset,
	 //input [9:0] x_pos, y_pos,
    output reg [7:0] VGA_R,       // Salida del color rojo
    output reg [7:0] VGA_G,       // Salida del color verde
    output reg [7:0] VGA_B        // Salida del color azul
    );
    
    // signal declarations
    wire [10:0] rom_addr;           // 11-bit text ROM address
    wire [3:0] char_row;            // 4-bit row of ASCII character
    wire [2:0] bit_addr;            // column number of ROM data
    wire [7:0] rom_data;            // 8-bit row data from text ROM
    wire ascii_bit, ascii_bit_on;     // ROM bit and status signal
    
    // instantiate ASCII ROM
    //ascii_rom rom(.addr(rom_addr), .data(rom_data));
	 char_rom rom(.addr(rom_addr), .data(rom_data));
      
    // ASCII ROM interface
    assign rom_addr = {ascii_char, char_row};   // ROM address is ascii code + row
    assign ascii_bit = rom_data[~bit_addr];     // reverse bit order

    assign char_row = y[3:0];               // row number of ascii character rom
    assign bit_addr = x[2:0];               // column number of ascii character rom
    // "on" region in center of screen
    assign ascii_bit_on = video_on ? ascii_bit : 1'b0;
	 
	 localparam [7:0] COLOR_BLACK  = 8'h00; // Negro
    localparam [7:0] COLOR_WHITE = 8'hFF; // Blanco
    
    // rgb multiplexing circuit
    always @*
        if(reset || ~video_on || ~ascii_bit_on) begin
            VGA_R <= COLOR_BLACK;
				VGA_B <= COLOR_BLACK;
				VGA_G <= COLOR_BLACK;
        end else begin
				 VGA_R <= COLOR_WHITE;
				 VGA_B <= COLOR_WHITE;
				 VGA_G <= COLOR_WHITE;
		  end
   
endmodule
