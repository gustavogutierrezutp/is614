module hazard_unit (
    // Entradas desde ID/EX 
    input [4:0]  id_ex_rd,
    input        id_ex_MemRead,    // La instrucción en EX es un LOAD
    
    // Entradas desde IF/ID 
    input [4:0]  if_id_rs1,
    input [4:0]  if_id_rs2,
    
    // Salida
    output logic stall
);

    // Si la instrucción en EX es un LOAD y la siguiente en ID necesita
    always_comb begin
        if (id_ex_MemRead && 
            (id_ex_rd != 5'b0) &&    
            ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2))) begin

            stall = 1'b1;            // Detener pipeline un ciclo

        end else begin
            stall = 1'b0;
        end
    end

endmodule
