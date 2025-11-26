
module top_level(

    input  logic CLOCK_50,      // Reloj base de la FPGA (50 MHz) 
    input  logic clk,           // Reloj manual 
    input  logic rst_n,         // Reset 
    
    output logic [7:0] VGA_R,   // Canal Rojo
    output logic [7:0] VGA_G,   // Canal Verde
    output logic [7:0] VGA_B,   // Canal Azul
    output logic VGA_HS,        // Sincronismo Horizontal
    output logic VGA_VS,        // Sincronismo Vertical
    output logic VGA_CLK        // Reloj  
	 
);

    // ============================================================
    // 1. PROGRAM COUNTER 
    // ============================================================
    
    wire [31:0] next_pc;       // Próxima dirección a ejecutar
    wire [31:0] address;       // Dirección actual
    wire [31:0] pc_plus_4 = address + 4; // Dirección secuencial (PC+4)

    pc pc_inst(
        .clk     (clk),
        .rst     (~rst_n),     
        .next_pc (next_pc),
        .pc_out  (address)   
    );
	 
	     wire pc_src;
  
    // Lógica de Detención del Procesador 
    logic processor_stopped;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            processor_stopped <= 1'b0; 
        else if (ctrl_halt) 
            processor_stopped <= 1'b1;
    end
  
    assign pc_src = branch_taken;
    
    // Dirección destino del salto 
    wire [31:0] jump_target = ALU_res;

    // Selección del próximo PC:
    // 1. Si está detenido -> Mantener actual
    // 2. Si hay salto -> Ir a target
    // 3. Sino -> Siguiente instrucción secuencial (PC+4)
    assign next_pc = processor_stopped ? address : (pc_src ? jump_target : pc_plus_4);
  
    // ============================================================
    // 2. MEMORIA DE INSTRUCCIONES 
    // ============================================================

    wire [31:0] instr;

    instruction_memory imem_inst (
        .address     (address), 
        .instruction (instr)
    );

    // Decodificación de Campo de la instrucción RISC-V
	 
    wire [6:0] funct7 = instr[31:25];
    wire [4:0] rs2    = instr[24:20];
    wire [4:0] rs1    = instr[19:15];
    wire [2:0] funct3 = instr[14:12];
    wire [4:0] rd     = instr[11:7];
    wire [6:0] opcode = instr[6:0];

    // ============================================================
    // 3. UNIDAD DE CONTROL
    // ============================================================

    wire [3:0] ALU_op;
    wire       ALU_Bsrc;       // Mux selección fuente B de ALU
    wire       ALU_Asrc;      // Mux selección fuente A de ALU
    wire       reg_write;
    wire       mem_to_reg;
    wire       mem_write;
    wire       branch;
    wire       jump;
    wire [2:0] branch_type;
    wire [2:0] immsrc;       
  
    // Señales filtradas para visualización en VGA
    wire [6:0] clean_funct7; 
    wire [2:0] clean_dmctrl; 
    wire       ctrl_halt;     // Señal de parada (EBREAK)

    control_unit control_inst (
        .opcode       (opcode),
        .funct3       (funct3),
        .funct7       (funct7),
        
        // Señales de Control Datapath
        .ALU_op       (ALU_op),
        .ALU_src      (ALU_Bsrc),
        .ALU_Asrc     (ALU_Asrc),   
        .reg_write    (reg_write),
        .mem_to_reg   (mem_to_reg),
        .mem_write    (mem_write),
        .branch       (branch),
        .jump         (jump),
        .branch_type  (branch_type),
        .immsrc       (immsrc),
        
        // Señales para VGA
        .funct7_out   (clean_funct7),
        .mem_ctrl_out (clean_dmctrl),
        .is_halted    (ctrl_halt) 
    );

    // ============================================================
    // 4. GENERADOR DE INMEDIATOS 
    // ============================================================

    wire [31:0] imm_extended;

    imm_gen imm_gen_inst (
        .instruction (instr),
        .immsrc      (immsrc),      
        .imm_out     (imm_extended)
    );

    // ============================================================
    // 5. BANCO DE REGISTROS 
    // ============================================================
	 
    wire [31:0] rs1_data;     // Dato leído puerto 1
    wire [31:0] rs2_data;     // Dato leído puerto 2
    wire [31:0] mem_data;     // Dato leído de memoria
    wire [31:0] ALU_res;      // Resultado de la ALU
  
    wire [31:0] data_wr = jump ? pc_plus_4 : (mem_to_reg ? mem_data : ALU_res);
  
    logic [31:0] all_registers [0:31]; 

    registers_unit regfile_inst (
        .clk             (clk),
        .rst             (~rst_n),      
        .rs1             (rs1),
        .rs2             (rs2),
        .rd              (rd),
        .ru_wr           (reg_write), 
        .data_wr         (data_wr),
        .rs1_data        (rs1_data),
        .rs2_data        (rs2_data),
        .debug_registers (all_registers) 
    );

    // ============================================================
    // 6. ALU 
    // ============================================================
	 
    wire [31:0] ALU_A; 
    wire [31:0] ALU_B; 

    // Mux Entrada A: rs1 o PC Actual (para saltos)
    assign ALU_A = ALU_Asrc ? address : rs1_data;

    // Mux Entrada B: rs2 o Inmediato extendido
    assign ALU_B = ALU_Bsrc ? imm_extended : rs2_data;

    alu alu_inst (
        .A       (ALU_A),
        .B       (ALU_B),
        .ALU_op  (ALU_op),
        .ALU_res (ALU_res)
    );

    // ============================================================
    // 7. BRANCH UNIT 
    // ============================================================

    wire branch_taken;
  
    branch_unit branch_unit_inst (
        .rs1_data     (rs1_data),
        .rs2_data     (rs2_data),
        .branch_type  (branch_type),
        .branch       (branch),
        .jump         (jump),          
        .branch_taken (branch_taken)
    );

    // ============================================================
    // 8. MEMORIA DE DATOS 
    // ============================================================
    
    logic [31:0] all_memory [0:31]; 

    data_memory dmem_inst (
        .clk          (clk),
		  .rst          (~rst_n), 
        .address      (ALU_res),    // Dirección calculada por ALU
        .DatamW       (rs2_data),   // Dato a escribir 
        .DMCTRL       (funct3),     // Control de tamaño (Byte/Half/Word)
        .mem_write    (mem_write), 
        .Datard       (mem_data),
        .debug_memory (all_memory)  
    );
  


    // ============================================================
    // 9. CONTROLADOR VGA 
    // ============================================================
    
    wire [31:0] vga_dm_wr_display;
    assign vga_dm_wr_display = {31'd0, mem_write};

    color vga_inst (
        .clock           (CLOCK_50),
        .rst             (~rst_n),

        // Señales PC e Instrucción
        .next_pc_value   (next_pc),
        .address_value   (address),
        .instr_value     (instr),
        
        // Decodificación
        .rs1_idx         (rs1),
        .rs2_idx         (rs2),
        .rd_idx          (rd),
        
        // Control
        .data_wr_value   (data_wr),
        .ru_wr_value     (reg_write),
        .immsrc_value    (immsrc),
        .opcode_value    (opcode),
        .funct3_value    (funct3),      
        .funct7_value    (clean_funct7), 
        .dm_ctrl_value   (clean_dmctrl), 
        .imm_value       (imm_extended),
        
        // ALU
        .alu_a_value     (ALU_A),      
        .alu_b_value     (ALU_B),      
        .alu_res_value   (ALU_res),
        .alu_op_value    (ALU_op),
        .alu_asrc_value  (ALU_Asrc),   
        .alu_bsrc_value  (ALU_Bsrc),    
        
        // Saltos
        .br_op_value     (branch_type), 
        .branch_value    (branch | jump),
        
       
        .dm_wr_value     (vga_dm_wr_display),   
        
        
        .data_rd_value   (mem_data),   
        
        // Mux Source
        .ru_wr_src_value (jump ? 2'd2 : (mem_to_reg ? 2'd1 : 2'd0)), 
        .branch_a_value  ( (branch | jump) ? rs1_data : 32'd0 ), 
        .branch_b_value  ( (branch | jump) ? rs2_data : 32'd0 ),
        
        // Debug
        .program_ended   (processor_stopped),
        .register_values (all_registers),
        .memory_values   (all_memory), 

        // Salidas
        .vga_red   (VGA_R),
        .vga_green (VGA_G),
        .vga_blue  (VGA_B),
        .vga_hsync (VGA_HS),
        .vga_vsync (VGA_VS),
        .vga_clock (VGA_CLK)
    );

endmodule