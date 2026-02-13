module data_memory (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    input  logic [2:0]  funct3,
    output logic [31:0] rdata
);

    logic [31:0] ram[127:0];
    
    logic [31:0] mem_word;
    logic [1:0]  byte_offset;
    logic [31:0] read_data_comb;
    
    assign mem_word = ram[addr[8:2]];
    assign byte_offset = addr[1:0];

    always_comb begin
        read_data_comb = 32'hxxxxxxxx;
        if (mem_read) begin
            case (funct3)
                3'b000: begin
                    case (byte_offset)
                        2'b00: read_data_comb = {{24{mem_word[7]}},  mem_word[7:0]};
                        2'b01: read_data_comb = {{24{mem_word[15]}}, mem_word[15:8]};
                        2'b10: read_data_comb = {{24{mem_word[23]}}, mem_word[23:16]};
                        2'b11: read_data_comb = {{24{mem_word[31]}}, mem_word[31:24]};
                    endcase
                end
                3'b001: begin
                    case (byte_offset)
                        2'b00: read_data_comb = {{16{mem_word[15]}}, mem_word[15:0]};
                        2'b10: read_data_comb = {{16{mem_word[31]}}, mem_word[31:16]};
                        default: read_data_comb = 32'hxxxxxxxx;
                    endcase
                end
                3'b010: begin
                    read_data_comb = (byte_offset == 2'b00) ? mem_word : 32'hxxxxxxxx;
                end
                3'b100: begin
                    case (byte_offset)
                        2'b00: read_data_comb = {{24{1'b0}}, mem_word[7:0]};
                        2'b01: read_data_comb = {{24{1'b0}}, mem_word[15:8]};
                        2'b10: read_data_comb = {{24{1'b0}}, mem_word[23:16]};
                        2'b11: read_data_comb = {{24{1'b0}}, mem_word[31:24]};
                    endcase
                end
                3'b101: begin
                    case (byte_offset)
                        2'b00: read_data_comb = {{16{1'b0}}, mem_word[15:0]};
                        2'b10: read_data_comb = {{16{1'b0}}, mem_word[31:16]};
                        default: read_data_comb = 32'hxxxxxxxx;
                    endcase
                end
                default: read_data_comb = 32'hxxxxxxxx;
            endcase
        end
    end
    
    always_ff @(posedge clk) begin
        if (mem_read)
            rdata <= read_data_comb;
    end

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 128; i++) begin
                ram[i] <= 32'h0;
            end
            ram[25] <= 32'hAAAAAAAA;
            ram[26] <= 32'h12345678;
            
        end else if (mem_write) begin
            case (funct3)
                3'b010: begin
                    if (byte_offset == 2'b00)
                        ram[addr[8:2]] <= wdata;
                end
                default: ;
            endcase
        end
    end

endmodule