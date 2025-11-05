module font_rom(
    input  wire [10:0] addr,
    output reg  [7:0]  data
);
    reg [7:0] rom[0:2047];

    initial begin
        $readmemh("font_8x16.hex", rom);
    end

    always @(*) begin
        data = rom[addr];
    end
endmodule