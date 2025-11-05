module screen_ram(
    input  wire [12:0] address_w,
    input  wire [12:0] address_r,
    input  wire [7:0]  data,
    input  wire        clk,
    input  wire        we,
    output reg  [7:0]  char_out
);

   (* ramstyle = "M10K" *) reg [7:0] ram[0:8191];

   initial begin
      $readmemh("screen_ram.hex", ram);
   end

    always @(posedge clk) begin
        if (we) begin
            ram[address_w] <= data;
        end
        char_out <= ram[address_r];
    end

endmodule