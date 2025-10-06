module top_level(
    input  wire clk,
    input  wire rst_n,
    output wire [6:0] display,
    output wire [9:0] leds
);

    logic [31:0] pc, next_pc;
    logic [31:0] instruction;
    logic [6:0]  funct7;
    logic [2:0]  funct3;
    logic [4:0]  rs1, rs2, rd;
    logic [1:0]  ALUOp;
    logic        RegWrite;
    logic [3:0]  ALUControl;
    logic [31:0] rs1_data, rs2_data;
    logic [31:0] alu_result;
    logic        zero;

    // ========= 1. PROGRAM COUNTER =========
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pc <= 32'b0;
        else
            pc <= next_pc;
    end

    assign next_pc = pc + 4;

    // ========= 2. INSTRUCTION MEMORY =========
    instruction_memory imem(
        .addr(pc),
        .instruction(instruction)
    );

    // ========= 3. DECODIFICACIÓN =========
    assign funct7 = instruction[31:25];
    assign rs2    = instruction[24:20];
    assign rs1    = instruction[19:15];
    assign funct3 = instruction[14:12];
    assign rd     = instruction[11:7];
    // Para instrucciones tipo R (opcode = 0110011)
    wire [6:0] opcode = instruction[6:0];

    // ========= 4. CONTROL UNIT (simplificada) =========
    always_comb begin
        if (opcode == 7'b0110011) begin
            RegWrite = 1'b1;
            ALUOp    = 2'b10; // tipo R
        end else begin
            RegWrite = 1'b0;
            ALUOp    = 2'b00;
        end
    end

    // ========= 5. REGISTER FILE =========
    register_file reg_file(
        .clk(clk),
        .rst_n(rst_n),
        .RegWrite(RegWrite),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(alu_result),
        .read_data1(rs1_data),
        .read_data2(rs2_data)
    );

    // ========= 6. ALU CONTROL =========
    alu_control alu_ctrl_unit(
        .ALUOp(ALUOp),
        .funct7(funct7),
        .funct3(funct3),
        .ALUControl(ALUControl)
    );

    // ========= 7. ALU =========
    alu alu_unit(
        .a(rs1_data),
        .b(rs2_data),
        .ALUControl(ALUControl),
        .result(alu_result),
        .zero(zero)
    );

    // ========= 8. SALIDAS =========
    // Mostrar los 4 bits menos significativos del resultado
    hex7seg display0(
        .val(alu_result[3:0]),
        .display(display)
    );

    // Mostrar el resultado en los LEDs (10 bits menos significativos)
    assign leds = alu_result[9:0];

endmodule
