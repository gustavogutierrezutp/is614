
module data_memory (

    input  logic        clk,
    input  logic        rst,          
    input  logic [31:0] address,        
    input  logic [31:0] DatamW,         
    input  logic [2:0]  DMCTRL,         
    input  logic        mem_write,      
    
    output logic [31:0] Datard,         
    output logic [31:0] debug_memory [0:31] 
);

    parameter MEM_SIZE = 32;         

    // =================================================================
    // 1. ROM DE INICIALIZACIÓN 
    // =================================================================
    
    logic [31:0] init_rom [0:MEM_SIZE-1];

    initial begin
        
        for (int i=0; i<MEM_SIZE; i++) init_rom[i] = 32'h0;
        
        $readmemh("C:/Users/tomas/Documents/GitHub/Lab-1/Assembler/program_data.hex", init_rom); 
    end

    // =================================================================
    // 2. RAM PRINCIPAL 
    // =================================================================
    
    logic [31:0] memory [0:MEM_SIZE-1]; 

    assign debug_memory = memory; 

    // =================================================================
    // 3. LÓGICA DE LECTURA 
    // =================================================================
    wire [9:0] word_addr   = address[11:2];  
    wire [1:0] byte_offset = address[1:0];   
    
    always_comb begin
        
        case (DMCTRL)
            3'b000: begin // LB
                case (byte_offset)
                    2'b00: Datard = {{24{memory[word_addr][7]}},  memory[word_addr][7:0]};
                    2'b01: Datard = {{24{memory[word_addr][15]}}, memory[word_addr][15:8]};
                    2'b10: Datard = {{24{memory[word_addr][23]}}, memory[word_addr][23:16]};
                    2'b11: Datard = {{24{memory[word_addr][31]}}, memory[word_addr][31:24]};
                endcase
            end
            3'b001: begin // LH
                case (byte_offset[1])
                    1'b0: Datard = {{16{memory[word_addr][15]}}, memory[word_addr][15:0]};
                    1'b1: Datard = {{16{memory[word_addr][31]}}, memory[word_addr][31:16]};
                endcase
            end
            3'b010: begin // LW
                Datard = memory[word_addr];
            end
            3'b100: begin // LBU
                case (byte_offset)
                    2'b00: Datard = {24'b0, memory[word_addr][7:0]};
                    2'b01: Datard = {24'b0, memory[word_addr][15:8]};
                    2'b10: Datard = {24'b0, memory[word_addr][23:16]};
                    2'b11: Datard = {24'b0, memory[word_addr][31:24]};
                endcase
            end
            3'b101: begin // LHU
                case (byte_offset[1])
                    1'b0: Datard = {16'b0, memory[word_addr][15:0]};
                    1'b1: Datard = {16'b0, memory[word_addr][31:16]};
                endcase
            end
            default: Datard = 32'h0;
        endcase
    end

    // =================================================================
    // 4. LÓGICA DE ESCRITURA Y RESET (Secuencial)
    // =================================================================
    
    always_ff @(posedge clk or posedge rst) begin
        
		  if (rst) begin
            memory <= init_rom; 
        end 
        else if (mem_write) begin
            case (DMCTRL)
                3'b000: begin // SB
                    case (byte_offset)
                        2'b00: memory[word_addr][7:0]   <= DatamW[7:0];
                        2'b01: memory[word_addr][15:8]  <= DatamW[7:0];
                        2'b10: memory[word_addr][23:16] <= DatamW[7:0];
                        2'b11: memory[word_addr][31:24] <= DatamW[7:0];
                    endcase
                end
                3'b001: begin // SH
                    case (byte_offset[1])
                        1'b0: memory[word_addr][15:0]  <= DatamW[15:0];
                        1'b1: memory[word_addr][31:16] <= DatamW[15:0];
                    endcase
                end
                3'b010: begin // SW
                    memory[word_addr] <= DatamW;
                end
            endcase
        end
    end

endmodule