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
    wire [31:0] pc_actual, siguiente_pc;
    wire [31:0] instruccion;
    wire [31:0] dato_rs1, dato_rs2;
    wire [31:0] valor_inmediato;
    wire [31:0] entrada_b_alu;
    wire [31:0] resultado_alu;
    wire [31:0] dato_leido_mem;
    wire [31:0] dato_writeback;
    wire [31:0] valor_display;
    wire [3:0] ctrl_alu;
    wire escribir_reg, sel_inmediato, escribir_mem, leer_mem, sel_mem;
    wire bandera_cero;
    
    assign siguiente_pc = pc_actual + 4;
    
    program_counter contador_prog(
        .clk(clk),
        .rst_n(rst_n),
        .pc_next(siguiente_pc),
        .pc(pc_actual)
    );
    
    instruction_memory mem_instrucciones(
        .pc(pc_actual),
        .instruction(instruccion)
    );
    
    control_unit unidad_control(
        .instruction(instruccion),
        .reg_write(escribir_reg),
        .alu_src(sel_inmediato),
        .mem_write(escribir_mem),
        .mem_read(leer_mem),
        .mem_to_reg(sel_mem),
        .alu_control(ctrl_alu)
    );
    
    register_file banco_registros(
        .clk(clk),
        .rst_n(rst_n),
        .reg_write(escribir_reg),
        .rs1(instruccion[19:15]),
        .rs2(instruccion[24:20]),
        .rd(instruccion[11:7]),
        .write_data(dato_writeback),
        .read_data1(dato_rs1),
        .read_data2(dato_rs2)
    );
    
    immediate_generator gen_inmediato(
        .instruction(instruccion),
        .immediate(valor_inmediato)
    );
    
    assign entrada_b_alu = sel_inmediato ? valor_inmediato : dato_rs2;
    
    alu unidad_alu(
        .operand1(dato_rs1),
        .operand2(entrada_b_alu),
        .alu_control(ctrl_alu),
        .alu_result(resultado_alu),
        .zero_flag(bandera_cero)
    );
    
    data_memory mem_datos(
        .clk(clk),
        .rst_n(rst_n),
        .mem_write(escribir_mem),
        .mem_read(leer_mem),
        .funct3(instruccion[14:12]),
        .address(resultado_alu),
        .write_data(dato_rs2),
        .read_data(dato_leido_mem)
    );
    
    assign dato_writeback = sel_mem ? dato_leido_mem : resultado_alu;
    
    display_mux mux_display(
        .switches(switches),
        .pc(pc_actual),
        .immediate(valor_inmediato),
        .alu_result(resultado_alu),
        .sr1(dato_rs1),
        .display_value(valor_display)
    );
    
    hex7seg seg0(.val(valor_display[3:0]), .display(display));
    hex7seg seg1(.val(valor_display[7:4]), .display(display1));
    hex7seg seg2(.val(valor_display[11:8]), .display(display2));
    hex7seg seg3(.val(valor_display[15:12]), .display(display3));
    hex7seg seg4(.val(valor_display[19:16]), .display(display4));
    hex7seg seg5(.val(valor_display[23:20]), .display(display5));
    
    assign leds = valor_display[9:0];
    
endmodule