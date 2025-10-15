module clock_divider #(
    parameter DIVISOR = 50_000_000  // Divide 50 MHz -> 1 Hz
)(
    input  wire clk_in,     // reloj rápido del FPGA
    input  wire rst_n,      // reset activo en bajo
    output reg  clk_out     // reloj lento generado
);

    integer counter;

    always @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            clk_out <= 0;
        end else begin
            if (counter == (DIVISOR/2 - 1)) begin
                clk_out <= ~clk_out; // cambiar estado del reloj
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule
