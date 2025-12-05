module MEMWB(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        stall,
    input  logic        flush,
    
    // Entradas desde MEM
    input  logic [31:0] pc_plus_4_in,
    input  logic [31:0] DataAlu_in,
    input  logic [31:0] DMOut_in,        
    input  logic [4:0]  rd_in,
    
    // Señales de control desde MEM
    input  logic        RUWr_in,
    input  logic [1:0]  RUDataWrSrc_in,
	 input        EBreak_in, 
    
    // Salidas hacia WB
    output logic [31:0] pc_plus_4_out,
    output logic [31:0] DataAlu_out,
    output logic [31:0] DMOut_out,
    output logic [4:0]  rd_out,
    
    // Señales de control hacia WB
    output logic        RUWr_out,
    output logic [1:0]  RUDataWrSrc_out,
	 output reg          EBreak_out
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_plus_4_out <= 32'b0;
            DataAlu_out <= 32'b0;
            DMOut_out <= 32'b0;
            rd_out <= 5'b0;
            
            RUWr_out <= 1'b0;
            RUDataWrSrc_out <= 2'b0;
				EBreak_out <= 1'b0;
        end
        else if (flush) begin
            pc_plus_4_out <= 32'b0;
            DataAlu_out <= 32'b0;
            DMOut_out <= 32'b0;
            rd_out <= 5'b0;
            
            RUWr_out <= 1'b0;
            RUDataWrSrc_out <= 2'b0;
				EBreak_out <= 1'b0; //NOP
        end
        else begin  
            pc_plus_4_out <= pc_plus_4_in;
            DataAlu_out <= DataAlu_in;
            DMOut_out <= DMOut_in;
            rd_out <= rd_in;
            
            RUWr_out <= RUWr_in;
            RUDataWrSrc_out <= RUDataWrSrc_in;
				EBreak_out <= EBreak_in;
        end
    end

endmodule