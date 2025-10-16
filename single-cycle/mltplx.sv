// Multiplexor
module mltplx #(
    parameter WIDTH = 32  // Ancho del bus de datos
)(
    input  logic [WIDTH-1:0] in0, // Entrada 0
    input  logic [WIDTH-1:0] in1, // Entrada 1
    input  logic sel, // Señal de selección
    output logic [WIDTH-1:0] out // Salida
);

    always_comb begin
        if (sel)
            out = in1;
        else
            out = in0;
    end

endmodule
