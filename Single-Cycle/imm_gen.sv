
module imm_gen (

    input  logic [31:0] instruction, // Instrucción 
    input  logic [2:0]  immsrc,      // Selector de tipo de inmediato 
    output logic [31:0] imm_out      // Inmediato extendido a 32 bits
	 
);

    always_comb begin
	 
        case (immsrc)
		  
            // -------------------------------------------------
            // TIPO I
            // -------------------------------------------------
				
            3'b000: 
                imm_out = { {20{instruction[31]}}, instruction[31:20] };
            
            // -------------------------------------------------
            // TIPO S 
            // -------------------------------------------------
	
            3'b001: 
                imm_out = { {20{instruction[31]}}, instruction[31:25], instruction[11:7] };
            
            // -------------------------------------------------
            // TIPO B 
            // -------------------------------------------------
				
            3'b010: 
                imm_out = { {19{instruction[31]}}, instruction[31], instruction[7], 
                            instruction[30:25],    instruction[11:8], 1'b0 };
            
            // -------------------------------------------------
            // TIPO U 
            // -------------------------------------------------
				
            3'b011: 
                imm_out = { instruction[31:12], 12'b0 };
            
            // -------------------------------------------------
            // TIPO J 
            // -------------------------------------------------
				
            3'b100: 
                imm_out = { {11{instruction[31]}}, instruction[31], instruction[19:12], 
                            instruction[20],       instruction[30:21], 1'b0 };
            
            // -------------------------------------------------
            // DEFAULT (R)
            // -------------------------------------------------
            default:
                imm_out = 32'b0;
        endcase
    end

endmodule