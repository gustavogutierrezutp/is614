module top_level (
    input  logic [9:0] SW,     // Interruptores
    output logic [9:0] LEDR    // LEDs
);

    // Reflejo de switches en LEDs
    assign LEDR = SW;

endmodule