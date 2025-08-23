module top_level (
    input  logic [9:0] SW,       
    input  logic       KEY0,     
    output logic [9:0] LED,      
    output logic [6:0] HEX0,     
    output logic [6:0] HEX1,     
    output logic [6:0] HEX2      
);

    assign LED = SW;


    logic [11:0] unsigned_value;
    logic [11:0] signed_value;
    logic [11:0] final_value;

    assign unsigned_value = {2'b00, SW};          
    assign signed_value   = {{2{SW[9]}}, SW};     

    assign final_value = (KEY0) ? unsigned_value : signed_value;

    logic [3:0] nibble0; 
    logic [3:0] nibble1;
    logic [3:0] nibble2; 

    assign nibble0 = final_value[3:0];
    assign nibble1 = final_value[7:4];
    assign nibble2 = final_value[11:8];


    hex7seg h0 (.bin(nibble0), .seg(HEX0));
    hex7seg h1 (.bin(nibble1), .seg(HEX1));
    hex7seg h2 (.bin(nibble2), .seg(HEX2));

endmodule



module hex7seg (
    input  logic [3:0] bin,
    output logic [6:0] seg
);
    always_comb begin
        case (bin)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;
            default: seg = 7'b1111111; // todo apagado
        endcase
    end
endmodule
