module data_memory(
    input wire clk,
    input wire rst_n,
    input wire mem_write,
    input wire mem_read,
    input wire [2:0] funct3,
    input wire [31:0] address,
    input wire [31:0] write_data,
    output reg [31:0] read_data
);

    reg [7:0] memoria [0:255];
    wire [7:0] dir = address[7:0];
    
    always @(posedge clk) begin
        if (mem_write) begin
            case (funct3)
                3'b000: begin
                    memoria[dir] <= write_data[7:0];
                end
                3'b001: begin
                    memoria[dir] <= write_data[7:0];
                    memoria[dir + 1] <= write_data[15:8];
                end
                3'b010: begin
                    memoria[dir] <= write_data[7:0];
                    memoria[dir + 1] <= write_data[15:8];
                    memoria[dir + 2] <= write_data[23:16];
                    memoria[dir + 3] <= write_data[31:24];
                end
            endcase
        end
    end
    
    always @(*) begin
        read_data = 32'b0;
        if (mem_read) begin
            case (funct3)
                3'b000: begin
                    read_data = {{24{memoria[dir][7]}}, memoria[dir]};
                end
                3'b001: begin
                    read_data = {{16{memoria[dir + 1][7]}}, memoria[dir + 1], memoria[dir]};
                end
                3'b010: begin
                    read_data = {memoria[dir + 3], memoria[dir + 2], memoria[dir + 1], memoria[dir]};
                end
                3'b100: begin
                    read_data = {24'b0, memoria[dir]};
                end
                3'b101: begin
                    read_data = {16'b0, memoria[dir + 1], memoria[dir]};
                end
            endcase
        end
    end
    
endmodule