module top_level( 
	input wire clk, 
	input wire rst_n,
	input wire [9:0] sw,
	output wire [6:0] HEX_0, 
	output wire [6:0] HEX_1, 
	output wire [6:0] HEX_2, 
	output wire [6:0] HEX_3, 
	output wire [6:0] HEX_4, 
	output wire [6:0] HEX_5, 
	output wire [9:0] leds 
); 

	wire [31:0] instruction; 
	wire [3:0] alu_op; 
	wire reg_write; 
	wire [31:0] imm; 
	wire [31:0] read_data1, read_data2, alu_result; 
	wire zero; 
	wire mem_read, mem_write, mem_to_reg; 
	wire [31:0] read_data_mem; 
	wire [31:0] pc;
	
	reg [31:0] dato_mostrar;
	
	// This block will change when you implement branching. 
	always @(posedge clk or negedge rst_n) 
		begin if (!rst_n) pc <= 32'b0; 
		else pc <= pc + 4; 
	end
	// Memoria de instrucciones 
	inst_mem IM( 
		.addr(pc), 
		.instruction(instruction) 
	); 
	
	// Unidad de control 
	control_unit CU( .opcode(instruction[6:0]), 
		.funct3(instruction[14:12]), 
		.funct7(instruction[31:25]), 
		.alu_op(alu_op), 
		.reg_write(reg_write), 
		.mem_read(mem_read), 
		.mem_write(mem_write), 
		.mem_to_reg(mem_to_reg) 
	);
	
	// Memoria de datos 
	data_memory DM(
	  .clk(clk),
	  .mem_read(mem_read),
	  .mem_write(mem_write),
	  .addr(alu_result),
	  .write_data(read_data2),
	  .read_data(read_data_mem)
	);
	//assign read_data_mem = 32'b0;
	
	// MUX entre resultado de ALU y lectura de memoria
	wire [31:0] write_back_data;
	assign write_back_data = (mem_to_reg) ? read_data_mem : alu_result;
	
	// Unidad de registros 
	register_unit UR(
		.clk(clk),
		.reset(!rst_n),
		.rs1(instruction[19:15]),
		.rs2(instruction[24:20]),
		.rd(instruction[11:7]),
		.datawr(write_back_data),
		.RUWr(reg_write),
		.read_data1(read_data1),
		.read_data2(read_data2)
	); 
	
	// ALU 
	alu ALU( 
		.A(read_data1), 
		.B((instruction[6:0] == 7'b0010011 || instruction[6:0] == 7'b0000011 || instruction[6:0] == 7'b0100011) ? imm : read_data2), //revisa si la instruccion es tipo i o load 
		.op(alu_op), 
		.ALUres(alu_result), 
		.zero(zero) 
	);
	
	// Generador de inmediatos 
	imm_gen GI(
		.inst(instruction),
		.imm(imm)
	);
	
	 always @(*) begin
	case (sw[2:0])
		3'b000: dato_mostrar = alu_result;
		3'b001: dato_mostrar = pc;
		3'b010: dato_mostrar = imm;
		3'b011: dato_mostrar = instruction;
		3'b100: dato_mostrar = read_data1;
		3'b101: dato_mostrar = read_data2;
		default: dato_mostrar = 32'h00000000;
	endcase
	end
	
	// Displays
	hex7seg display0(.val(dato_mostrar[3:0]),  .display(HEX_0));
	hex7seg display1(.val(dato_mostrar[7:4]),  .display(HEX_1));
	hex7seg display2(.val(dato_mostrar[11:8]), .display(HEX_2));
	hex7seg display3(.val(dato_mostrar[15:12]),.display(HEX_3));
	hex7seg display4(.val(dato_mostrar[19:16]),.display(HEX_4));
	hex7seg display5(.val(dato_mostrar[23:20]),.display(HEX_5));
	
	assign leds = 10'b1010101010;
endmodule
