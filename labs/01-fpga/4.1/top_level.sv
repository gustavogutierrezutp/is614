module top_level (
    input  logic [9:0] SW,     // Interruptores de fpga
    output logic [9:0] LEDR    // prueba leds
);

    // reflejo de switches en los leds
    assign LEDR = SW;

endmodule