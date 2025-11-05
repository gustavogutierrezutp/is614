module text_mode #(DEBUG_TILES = 1'b0) (
    input clk,
    input video_on,
    input [7:0] ascii_char,
    input [10:0] x,
    input [9:0] y,
    input reset,
    output reg [7:0] vga_red,
    output reg [7:0] vga_green,
    output reg [7:0] vga_blue
    );

    // Local parameters for character dimensions (should match the top-level definition)
    localparam integer CHAR_WIDTH = 8;
    localparam integer CHAR_HEIGHT = 16;

    reg [10:0] x_d;
    reg [9:0] y_d;
    reg video_on_d;
    always @(posedge clk) begin
        x_d <= x;
        y_d <= y;
        video_on_d <= video_on;
    end

    // Signal declarations
    wire [10:0] rom_addr;           // 11-bit text ROM address
    wire [3:0] char_row;            // 4-bit row of ASCII character
    wire [2:0] bit_addr;            // column number of ROM data
    wire [7:0] rom_data;            // 8-bit row data from text ROM
    wire ascii_bit, ascii_bit_on;    // ROM bit and status signal

    // instantiate ASCII ROM
    font_rom rom(.addr(rom_addr), .data(rom_data));

    // ASCII ROM interface
    assign rom_addr = {ascii_char, char_row};   // ROM address is ascii code + row
    assign ascii_bit = rom_data[~bit_addr];      // reverse bit order

    assign char_row = y_d % CHAR_HEIGHT;         // row number within the current character
    assign bit_addr = x_d % CHAR_WIDTH;           // column number within the current character

    // "on" region (where characters are displayed)
    assign ascii_bit_on = video_on_d ? ascii_bit : 1'b0;

    localparam [23:0] COLOR_BLACK = 24'h000000; // Black
    localparam [23:0] COLOR_WHITE = 24'hFFFFFF; // White
    localparam [23:0] COLOR_TILE_COLOR = {8'h80, 8'h80, 8'h80}; // Gray

    // rgb multiplexing circuit
    always @*
      if (reset || ~video_on_d)
        {vga_red,vga_green, vga_blue} <= COLOR_BLACK;
      else begin
        // Check if the current pixel (x, y) is on the border of a character tile AND debug is enabled
        if (DEBUG_TILES && 
          ((x_d % CHAR_WIDTH == 0) || (y_d % CHAR_HEIGHT == 0) ||
          (x_d % CHAR_WIDTH == CHAR_WIDTH - 1) || 
          (y_d % CHAR_HEIGHT == CHAR_HEIGHT - 1))
        )
          // If on the border and debug is enabled, draw the tile color
          {vga_red,vga_green, vga_blue} <= COLOR_TILE_COLOR;
        else
          // If not on the border or debug is disabled, draw the character
          if (ascii_bit_on)
            {vga_red,vga_green, vga_blue} <= COLOR_WHITE;
          else
            {vga_red,vga_green, vga_blue} <= COLOR_BLACK;
      end
endmodule