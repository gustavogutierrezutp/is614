module top_level (
    input  logic [9:0] SW,    
    output logic [9:0] LED   
);
    // Reflejar switches en LEDs
    assign LED = SW;

endmodule
