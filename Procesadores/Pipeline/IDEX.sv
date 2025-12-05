module IDEX(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        stall,
    input  logic        flush,
    
    // Entradas desde ID
    input  logic [31:0] pc_in,
    input  logic [31:0] pc_plus_4_in,
    input  logic [31:0] RU1_in,
    input  logic [31:0] RU2_in,
    input  logic [31:0] imm_in,
    input  logic [4:0]  rs1_in,
    input  logic [4:0]  rs2_in,
    input  logic [4:0]  rd_in,
    
    // Señales de control desde ID
    input  logic        RUWr_in,
    input  logic        AluASrc_in,
    input  logic        AluBSrc_in,
    input  logic [4:0]  AluOp_in,
    input  logic        DMWR_in,
    input  logic [2:0]  DMCtrl_in,
    input  logic [1:0]  RUDataWrSrc_in,
    input  logic        Branch_in,
    input  logic [4:0]  BrOp_in,
	 input        EBreak_in, 
    
    // Salidas hacia EX
    output logic [31:0] pc_out,
    output logic [31:0] pc_plus_4_out,
    output logic [31:0] RU1_out,
    output logic [31:0] RU2_out,
    output logic [31:0] imm_out,
    output logic [4:0]  rs1_out,
    output logic [4:0]  rs2_out,
    output logic [4:0]  rd_out,
    
    // Señales de control hacia EX
    output logic        RUWr_out,
    output logic        AluASrc_out,
    output logic        AluBSrc_out,
    output logic [4:0]  AluOp_out,
    output logic        DMWR_out,
    output logic [2:0]  DMCtrl_out,
    output logic [1:0]  RUDataWrSrc_out,
    output logic        Branch_out,
    output logic [4:0]  BrOp_out,
	 output reg          EBreak_out
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_out <= 32'b0;
            pc_plus_4_out <= 32'b0;
            RU1_out <= 32'b0;
            RU2_out <= 32'b0;
            imm_out <= 32'b0;
            rs1_out <= 5'b0;
            rs2_out <= 5'b0;
            rd_out <= 5'b0;
            
            RUWr_out <= 1'b0;
            AluASrc_out <= 1'b0;
            AluBSrc_out <= 1'b0;
            AluOp_out <= 5'b0;
            DMWR_out <= 1'b0;
            DMCtrl_out <= 3'b0;
            RUDataWrSrc_out <= 2'b0;
            Branch_out <= 1'b0;
            BrOp_out <= 5'b0;
				EBreak_out <= 1'b0;
        end
        else if (stall) begin
            pc_out <= 32'b0;
            pc_plus_4_out <= 32'b0;
            RU1_out <= 32'b0;
            RU2_out <= 32'b0;
            imm_out <= 32'b0;
            rs1_out <= 5'b0;          
            rs2_out <= 5'b0;          
            rd_out <= 5'b0;
            
            RUWr_out <= 1'b0;         
            AluASrc_out <= 1'b0;
            AluBSrc_out <= 1'b0;
            AluOp_out <= 5'b0;
            DMWR_out <= 1'b0;     
            DMCtrl_out <= 3'b0;
            RUDataWrSrc_out <= 2'b0;
            Branch_out <= 1'b0;      
            BrOp_out <= 5'b0; //NOP
        end
        else if (flush) begin
            pc_out <= 32'b0;
            pc_plus_4_out <= 32'b0;
            RU1_out <= 32'b0;
            RU2_out <= 32'b0;
            imm_out <= 32'b0;
            rs1_out <= 5'b0;
            rs2_out <= 5'b0;
            rd_out <= 5'b0;
            
            RUWr_out <= 1'b0;
            AluASrc_out <= 1'b0;
            AluBSrc_out <= 1'b0;
            AluOp_out <= 5'b0;
            DMWR_out <= 1'b0;
            DMCtrl_out <= 3'b0;
            RUDataWrSrc_out <= 2'b0;
            Branch_out <= 1'b0;
            BrOp_out <= 5'b0;
				EBreak_out <= 1'b0; //NOP
        end
        else begin
            pc_out <= pc_in;
            pc_plus_4_out <= pc_plus_4_in;
            RU1_out <= RU1_in;
            RU2_out <= RU2_in;
            imm_out <= imm_in;
            rs1_out <= rs1_in;
            rs2_out <= rs2_in;
            rd_out <= rd_in;
            
            RUWr_out <= RUWr_in;
            AluASrc_out <= AluASrc_in;
            AluBSrc_out <= AluBSrc_in;
            AluOp_out <= AluOp_in;
            DMWR_out <= DMWR_in;
            DMCtrl_out <= DMCtrl_in;
            RUDataWrSrc_out <= RUDataWrSrc_in;
            Branch_out <= Branch_in;
            BrOp_out <= BrOp_in;
				EBreak_out <= EBreak_in;
        end
    end
endmodule