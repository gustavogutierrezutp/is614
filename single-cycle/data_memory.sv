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
    reg [7:0] dmem [0:255];
    wire [7:0] addr = address[7:0];
    
    // Escritura síncrona
    always @(posedge clk) begin
        if (mem_write) begin
            case (funct3)
                3'b000: begin // SB - Store Byte
                    dmem[addr] <= write_data[7:0];
                end
                3'b001: begin // SH - Store Half
                    dmem[addr]     <= write_data[7:0];
                    dmem[addr + 1] <= write_data[15:8];
                end
                3'b010: begin // SW - Store Word
                    dmem[addr]     <= write_data[7:0];
                    dmem[addr + 1] <= write_data[15:8];
                    dmem[addr + 2] <= write_data[23:16];
                    dmem[addr + 3] <= write_data[31:24];
                end
            endcase
        end
    end
    
    always @(*) begin
        read_data = 32'b0;
        if (mem_read) begin
            case (funct3)
                3'b000: begin // LB - Load Byte 
                    read_data = {{24{dmem[addr][7]}}, dmem[addr]};
                end
                3'b001: begin // LH - Load Half 
                    read_data = {{16{dmem[addr + 1][7]}}, dmem[addr + 1], dmem[addr]};
                end
                3'b010: begin // LW - Load Word
                    read_data = {dmem[addr + 3], dmem[addr + 2], dmem[addr + 1], dmem[addr]};
                end
                3'b100: begin // LBU - Load Byte Unsigned 
                    read_data = {24'b0, dmem[addr]};
                end
                3'b101: begin // LHU - Load Half Unsigned 
                    read_data = {16'b0, dmem[addr + 1], dmem[addr]};
                end
            endcase
        end
    end
endmodule