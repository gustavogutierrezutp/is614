module top_level(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        sw0,
    input  wire        sw1,
    input  wire        sw2,
    input  wire        sw3,
    input  wire        sw4,
    output wire [6:0]  display0,
    output wire [6:0]  display1,
    output wire [6:0]  display2,
    output wire [6:0]  display3,
    output wire [6:0]  display4,
    output wire [6:0]  display5,
    output wire [9:0]  leds
);

    // PC
    wire [31:0] address;
    wire [31:0] next_pc;
    
    pc pc_inst(
        .clk(clk),
        .rst_n(rst_n),
        .next_pc(next_pc),
        .address(address)
    );
    
    // PC secuencial (sin branch)
    assign next_pc = address + 32'd4;
    
    // Instruction Memory
    wire [31:0] inst;
    instruction_memory imem(
        .address(address),
        .inst(inst)
    );
    
    // Decodificación de la instrucción
    wire [6:0] opcode = inst[6:0];
    wire [2:0] funct3 = inst[14:12];
    wire [6:0] funct7 = inst[31:25];
    wire [4:0] rs1_addr = inst[19:15];
    wire [4:0] rs2_addr = inst[24:20];
    wire [4:0] rd_addr  = inst[11:7];
    
    // Señales de control
    wire [4:0] ALUOp;
    wire [2:0] IMMSrc;
    wire       ALUBSrc;
    wire       RegWrite;
    wire       MemtoReg;
    wire       DMWR;
    wire [2:0] DMCtrl;
    wire [4:0] BrOp;  // No se usa pero el control_unit lo genera
    
    control_unit cu_inst (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .ALUOp(ALUOp),
        .IMMSrc(IMMSrc),
        .ALUBSrc(ALUBSrc),
        .RegWrite(RegWrite),
        .MemtoReg(MemtoReg),
        .DMWR(DMWR),
        .DMCtrl(DMCtrl),
        .BrOp(BrOp)
    );
    
    // Generador de inmediatos
    wire [31:0] imm_ext;
    genInm genInm_inst(
        .instr(inst),
        .IMMSrc(IMMSrc),
        .imm_out(imm_ext)
    );
    
    // Banco de registros
    wire [31:0] rs1_data, rs2_data;
    wire [31:0] data_wr_from_regbank;
    
    registers_unit ru_inst(
        .clk(clk),
        .rstn(rst_n),
        .rs1(rs1_addr),
        .rs2(rs2_addr),
        .rd(rd_addr),
        .ru_wr(RegWrite),
        .data_wr(data_wr_from_regbank),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );
    
    // ALU
    wire [31:0] alu_a = rs1_data;
    wire [31:0] alu_b = (ALUBSrc) ? imm_ext : rs2_data;
    wire [31:0] alu_res;
    
    alu alu_inst(
        .a(alu_a),
        .b(alu_b),
        .alu_op(ALUOp),
        .alu_res(alu_res)
    );
    
    // Data Memory
    wire [31:0] mem_data;
    data_memory dm_inst (
        .clk(clk),
        .DMWR(DMWR),
        .DMCtrl(DMCtrl),
        .Address(alu_res),
        .DataWr(rs2_data),
        .DataRd(mem_data)
    );
    
    // Write-back
    wire [31:0] wb_data = (MemtoReg) ? mem_data : alu_res;
    assign data_wr_from_regbank = wb_data;
    
    // Lógica de selección de visualización con prioridades
    reg [31:0] visible32;
    
    always @(*) begin
        if (sw4 == 1'b1) begin
            // SW4 tiene máxima prioridad: mostrar salida de Data Memory
            visible32 = mem_data;
        end
        else if (sw3 == 1'b1) begin
            // SW3: mostrar salida de ALU
            visible32 = alu_res;
        end
        else if (sw2 == 1'b1) begin
            // SW2: mostrar inmediato extendido
            visible32 = imm_ext;
        end
        else begin
            // SW1 y SW0 para seleccionar partes de la instrucción o PC
            case ({sw1, sw0})
                2'b00: visible32 = address;              // Ninguno: mostrar PC
                2'b01: visible32 = {16'd0, inst[15:0]};  // SW0: bits bajos de inst
                2'b10: visible32 = {16'd0, inst[31:16]}; // SW1: bits altos de inst
                2'b11: visible32 = inst;                 // SW0 y SW1: instrucción completa
                default: visible32 = 32'd0;
            endcase
        end
    end
    
    // Separación en nibbles para los 6 displays (mostramos 24 bits)
    wire [3:0] nib0 = visible32[3:0];
    wire [3:0] nib1 = visible32[7:4];
    wire [3:0] nib2 = visible32[11:8];
    wire [3:0] nib3 = visible32[15:12];
    wire [3:0] nib4 = visible32[19:16];
    wire [3:0] nib5 = visible32[23:20];
    
    // Instancias de decodificadores hex a 7 segmentos
    hex7seg hex0(.val(nib0), .display(display0));
    hex7seg hex1(.val(nib1), .display(display1));
    hex7seg hex2(.val(nib2), .display(display2));
    hex7seg hex3(.val(nib3), .display(display3));
    hex7seg hex4(.val(nib4), .display(display4));
    hex7seg hex5(.val(nib5), .display(display5));
    
    // Asignación de LEDs para debug
    assign leds[4:0] = ALUOp;
    assign leds[7:5] = IMMSrc;
    assign leds[8]   = ALUBSrc;
    assign leds[9]   = RegWrite;

endmodule