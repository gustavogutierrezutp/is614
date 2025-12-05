module flush_control (
    // Entrada: Branch tomado
    input        PCSrc,      

    // Entrada: stall desde hazard_unit
    input        stall,     

    // Salidas de control
    output logic flush_if_id, 
    output logic flush_id_ex 
);

    always_comb begin
	 
        flush_if_id = 1'b0;
        flush_id_ex = 1'b0;

		  // Si hay branch se hace flush en ID y EX
        if (PCSrc && !stall) begin
            flush_if_id = 1'b1;  
            flush_id_ex = 1'b1; 
        end
    end

endmodule
