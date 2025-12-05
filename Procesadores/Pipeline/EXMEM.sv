module EXMEM(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        stall,
    input  logic        flush,
    
    // Entradas desde EX
    input  logic [31:0] pc_plus_4_in,
    input  logic [31:0] DataAlu_in,       
    input  logic [31:0] RU2_in,          
    input  logic [4:0]  rd_in,
    input  logic        PCSrc_in,        
    
    // Señales de control desde EX
    input  logic        RUWr_in,
    input  logic        DMWR_in,
    input  logic [2:0]  DMCtrl_in,
    input  logic [1:0]  RUDataWrSrc_in,
	 input        EBreak_in, 
    
    // Salidas hacia MEM
    output logic [31:0] pc_plus_4_out,
    output logic [31:0] DataAlu_out,
    output logic [31:0] RU2_out,
    output logic [4:0]  rd_out,
    output logic        PCSrc_out,
    
    // Señales de control hacia MEM
    output logic        RUWr_out,
    output logic        DMWR_out,
    output logic [2:0]  DMCtrl_out,
    output logic [1:0]  RUDataWrSrc_out,
	 output reg          EBreak_out
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_plus_4_out <= 32'b0;
            DataAlu_out <= 32'b0;
            RU2_out <= 32'b0;
            rd_out <= 5'b0;
            PCSrc_out <= 1'b0;
            
            RUWr_out <= 1'b0;
            DMWR_out <= 1'b0;
            DMCtrl_out <= 3'b0;
            RUDataWrSrc_out <= 2'b0;
				EBreak_out <= 1'b0;
        end
        else if (flush) begin
            pc_plus_4_out <= 32'b0;
            DataAlu_out <= 32'b0;
            RU2_out <= 32'b0;
            rd_out <= 5'b0;
            PCSrc_out <= 1'b0;
            
            RUWr_out <= 1'b0;
            DMWR_out <= 1'b0;
            DMCtrl_out <= 3'b0;
            RUDataWrSrc_out <= 2'b0;
				EBreak_out <= 1'b0; //NOP
        end
        else begin  
            pc_plus_4_out <= pc_plus_4_in;
            DataAlu_out <= DataAlu_in;
            RU2_out <= RU2_in;
            rd_out <= rd_in;
            PCSrc_out <= PCSrc_in;
            
            RUWr_out <= RUWr_in;
            DMWR_out <= DMWR_in;
            DMCtrl_out <= DMCtrl_in;
            RUDataWrSrc_out <= RUDataWrSrc_in;
				EBreak_out <= EBreak_in;
        end
    end

endmodule