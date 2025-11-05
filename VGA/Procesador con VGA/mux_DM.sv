module mux_DM (
    input  [31:0] I0,
    input  [31:0] I1,
    input  [31:0] I2,
    input  [1:0]  S,
    output [31:0] Y
);

    assign Y = (S == 2'b00) ? I0 :
               (S == 2'b01) ? I1 :
               (S == 2'b10) ? I2 : 32'b0;

endmodule
