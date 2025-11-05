module alu (
    input  [31:0] a,      
    input  [31:0] b,       
    input  [4:0]  alu_op,  // Operación ALU: 
    output [31:0] alu_res  
);

    localparam ADD  = 5'b00000; // Suma
    localparam SUB  = 5'b00001; // Resta
    localparam SLL  = 5'b00010; // Shift lógico a la izquierda
    localparam SLT  = 5'b00011; // Set menor que (signed)
    localparam SLTU = 5'b00100; // Set menor que (unsigned)
    localparam XOR_ = 5'b00101; // XOR
    localparam SRL  = 5'b00110; // Shift lógico a la derecha
    localparam SRA  = 5'b00111; // Shift aritmético a la derecha
    localparam OR_  = 5'b01000; // OR
    localparam AND_ = 5'b01001; // AND

	 wire signed [31:0] a_signed = a;
	 wire signed [31:0] b_signed = b;
	 wire [31:0] a_unsigned= a;
	 wire [31:0] b_unsigned = b;
	 
    reg [31:0] result;

    always @(*) begin
        case (alu_op)
            ADD:   result = a + b;
            SUB:   result = a - b;
            SLL:   result = a << b[4:0];               // Se usan 5 bits para shift
            SLT:   result = {31'b0, a_signed < b_signed};
            SLTU:  result = {31'b0, a_unsigned < b_unsigned};
            XOR_:  result = a ^ b;
            SRL:   result = a >> b[4:0];               // Shift lógico
            SRA:   result = a_signed >>> b[4:0];     // Shift aritmético
            OR_:   result = a | b;
            AND_:  result = a & b;
            default: result = 32'b0;                   // Caso por defecto
        endcase
    end

    assign alu_res = result;

endmodule
