module top_level(
    input wire clk,
    input wire rst_n,
    input wire [1:0] switches,
    output wire [6:0] display,
    output wire [6:0] display1,
    output wire [6:0] display2,
    output wire [6:0] display3,
    output wire [6:0] display4,
    output wire [6:0] display5,
    output wire [9:0] leds
);
    // Señales internas
    wire [31:0] pc, pc_next;
    wire [31:0] instruction;
    wire [31:0] sr1, sr2;
    wire [31:0] immediate;
    wire [31:0] alu_operand2;
    wire [31:0] alu_result;
    wire [31:0] mem_read_data;
    wire [31:0] write_back_data;
    wire [31:0] display_value;
    wire [3:0] alu_control;
    wire reg_write, alu_src, mem_write, mem_read, mem_to_reg;
    wire zero_flag;
    
    // PC incrementa en 4
    assign pc_next = pc + 4;
    
    // Instanciación de Program Counter
    program_counter pc_inst(
        .clk(clk),
        .rst_n(rst_n),
        .pc_next(pc_next),
        .pc(pc)
    );
    
    // Instanciación de Instruction Memory
    instruction_memory imem_inst(
        .pc(pc),
        .instruction(instruction)
    );
    
    // Instanciación de Control Unit
    control_unit cu_inst(
        .instruction(instruction),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .alu_control(alu_control)
    );
    
    // Instanciación de Register File
    register_file rf_inst(
        .clk(clk),
        .rst_n(rst_n),
        .reg_write(reg_write),
        .rs1(instruction[19:15]),
        .rs2(instruction[24:20]),
        .rd(instruction[11:7]),
        .write_data(write_back_data),
        .read_data1(sr1),
        .read_data2(sr2)
    );
    
    // Instanciación de Immediate Generator
    immediate_generator imm_gen(
        .instruction(instruction),
        .immediate(immediate)
    );
    
    // MUX para operando B de la ALU
    assign alu_operand2 = alu_src ? immediate : sr2;
    
    // Instanciación de ALU
    alu alu_inst(
        .operand1(sr1),
        .operand2(alu_operand2),
        .alu_control(alu_control),
        .alu_result(alu_result),
        .zero_flag(zero_flag)
    );
    
    // Instanciación de Data Memory
    data_memory dmem_inst(
        .clk(clk),
        .rst_n(rst_n),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .funct3(instruction[14:12]),
        .address(alu_result),
        .write_data(sr2),
        .read_data(mem_read_data)
    );
    
    // MUX para Write Back
    assign write_back_data = mem_to_reg ? mem_read_data : alu_result;
    
    // Instanciación de Display Multiplexor
    display_mux disp_mux(
        .switches(switches),
        .pc(pc),
        .immediate(immediate),
        .alu_result(alu_result),
        .sr1(sr1),
        .display_value(display_value)
    );
    
    // Instanciación de Displays de 7 Segmentos
    hex7seg disp0(
        .val(display_value[3:0]),
        .display(display)
    );
    
    hex7seg disp1(
        .val(display_value[7:4]),
        .display(display1)
    );

    hex7seg disp2(
        .val(display_value[11:8]),
        .display(display2)
    );

    hex7seg disp3(
        .val(display_value[15:12]),
        .display(display3)
    );

    hex7seg disp4(
        .val(display_value[19:16]),
        .display(display4)
    );

    hex7seg disp5(
        .val(display_value[23:20]),
        .display(display5)
    );
    
    // Asignación de LEDs
    assign leds = display_value[9:0];
    
endmodule