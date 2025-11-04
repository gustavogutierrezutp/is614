module top_level (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [9:0] SW,
    output wire [6:0] HEX0,
    output wire [6:0] HEX1,
    output wire [6:0] HEX2,
    output wire [6:0] HEX3,
    output wire [6:0] HEX4,
    output wire [6:0] HEX5
);

    logic [31:0] pc;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pc <= 32'b0;
        else
            pc <= pc + 4;
    end

    logic [31:0] instruction;
    logic [31:0] imm_gen_out;
    logic [31:0] reg_rs1_data;
    logic [31:0] reg_rs2_data;
    logic [31:0] alu_b_in;
    logic [31:0] alu_result;
    logic [31:0] mem_read_data;
    logic [31:0] reg_wdata;
    logic [31:0] display_data_32bit;
    logic [23:0] display_window_24bit;
    logic       alu_b_src;
    logic [3:0] alu_op;
    logic       mem_read, mem_write, reg_write, mem_to_reg;
    
    logic [6:0] opcode;
    logic [4:0] rd, rs1, rs2;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7 = instruction[31:25];

    instruction_memory i_imem (
        .addr(pc),
        .instruction(instruction)
    );

    control_unit i_ctrl (
        .opcode(opcode), .funct3(funct3), .funct7(funct7),
        .alu_b_src(alu_b_src), .alu_op(alu_op),
        .mem_read(mem_read), .mem_write(mem_write),
        .reg_write(reg_write), .mem_to_reg(mem_to_reg)
    );

    imm_gen i_imm (
        .instruction(instruction), .opcode(opcode),
        .imm_out(imm_gen_out)
    );
    
    register_file i_regfile (
        .clk(clk), .rst_n(rst_n), .we(reg_write),
        .rs1_addr(rs1), .rs2_addr(rs2), .rd_addr(rd),
        .wdata(reg_wdata),
        .rs1_data(reg_rs1_data), .rs2_data(reg_rs2_data)
    );

    assign alu_b_in = alu_b_src ? imm_gen_out : reg_rs2_data;
    
    alu i_alu (
        .a(reg_rs1_data),
        .b(alu_b_in),
        .alu_op(alu_op),
        .result(alu_result)
    );

    data_memory i_dmem (
        .clk(clk), .rst_n(rst_n),
        .mem_read(mem_read), .mem_write(mem_write),
        .addr(alu_result),
        .wdata(reg_rs2_data),
        .funct3(funct3),
        .rdata(mem_read_data)
    );

    assign reg_wdata = mem_to_reg ? mem_read_data : alu_result;

    display_selector i_disp_sel (
        .sel       (SW[2:0]),
        .pc_in     (pc),
        .instr_in  (instruction),
        .wdata_in  (reg_wdata),
        .rs1_in    (reg_rs1_data),
        .rs2_in    (reg_rs2_data),
        .imm_in    (imm_gen_out),
        .alu_in    (alu_result),
        .mem_in    (mem_read_data),
        .data_out  (display_data_32bit)
    );
    
    assign display_window_24bit = (SW[3] == 1'b0) ? 
                                  display_data_32bit[23:0] :
                                  display_data_32bit[31:8];

    hex7seg dec0 (.val(display_window_24bit[3:0]),   .display(HEX0));
    hex7seg dec1 (.val(display_window_24bit[7:4]),   .display(HEX1));
    hex7seg dec2 (.val(display_window_24bit[11:8]),  .display(HEX2));
    hex7seg dec3 (.val(display_window_24bit[15:12]), .display(HEX3));
    hex7seg dec4 (.val(display_window_24bit[19:16]), .display(HEX4));
    hex7seg dec5 (.val(display_window_24bit[23:20]), .display(HEX5));

endmodule