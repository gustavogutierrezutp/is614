module forwarding_unit (
    // Registros fuente de la instrucción en EX
    input  logic [4:0] id_ex_rs1,
    input  logic [4:0] id_ex_rs2,
    
    // Registro destino y control desde EX/MEM
    input  logic [4:0] ex_mem_rd,
    input  logic       ex_mem_RegWrite,
    
    // Registro destino y control desde MEM/WB
    input  logic [4:0] mem_wb_rd,
    input  logic       mem_wb_RegWrite,
    
    // Señales de forwarding
    output logic [1:0] forward_a,  
    output logic [1:0] forward_b 
);

    // Forwarding para A (rs1)
    always_comb begin
        if (ex_mem_RegWrite && 
            (ex_mem_rd != 5'b0) && 
            (ex_mem_rd == id_ex_rs1)) begin

            // Forwarding desde EX/MEM
            forward_a = 2'b10;

        end else if (mem_wb_RegWrite && 
                     (mem_wb_rd != 5'b0) && 
                     (mem_wb_rd == id_ex_rs1)) begin

            // Forwarding desde MEM/WB
            forward_a = 2'b01;

        end else begin
            forward_a = 2'b00;
        end
    end

	 
    // Forwarding para B (rs2)
    always_comb begin
        if (ex_mem_RegWrite && 
            (ex_mem_rd != 5'b0) && 
            (ex_mem_rd == id_ex_rs2)) begin

            // Forwarding desde EX/MEM
            forward_b = 2'b10;

        end else if (mem_wb_RegWrite && 
                     (mem_wb_rd != 5'b0) && 
                     (mem_wb_rd == id_ex_rs2)) begin

            // Forwarding desde MEM/WB
            forward_b = 2'b01;

        end else begin
            forward_b = 2'b00;
        end
    end

endmodule
