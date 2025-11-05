module data_memory (
    input  wire        clk,
    input  wire        DMWR,        // 1 = write (store), 0 = read (load)
    input  wire [2:0]  DMCtrl,      // 3'b010 = word, 3'b001 = half, 3'b000 = byte
    input  wire [31:0] Address,     // byte-addressable
    input  wire [31:0] DataWr,      // data to write
    output reg  [31:0] DataRd
);

    reg [31:0] mem [0:255];

    // Word index (Address[9:2] -> 8 bits for 256 words)
    wire [7:0] word_idx = Address[9:2];

    // --- Combinational read ---
    always @* begin
        reg [31:0] word;
        word = mem[word_idx];

        case (DMCtrl)
            3'b010: begin // LW (load word)
                DataRd = word;
            end
            3'b001: begin // LH (load half) - signed
                if (Address[1] == 1'b0)
                    DataRd = {{16{word[15]}}, word[15:0]};   // low half
                else
                    DataRd = {{16{word[31]}}, word[31:16]};  // high half
            end
            3'b000: begin // LB (load byte) - signed
                case (Address[1:0])
                    2'b00: DataRd = {{24{word[7]}},  word[7:0]};
                    2'b01: DataRd = {{24{word[15]}}, word[15:8]};
                    2'b10: DataRd = {{24{word[23]}}, word[23:16]};
                    2'b11: DataRd = {{24{word[31]}}, word[31:24]};
                endcase
            end
            3'b100: begin // LBU (load byte unsigned)
                case (Address[1:0])
                    2'b00: DataRd = {24'h000000, word[7:0]};
                    2'b01: DataRd = {24'h000000, word[15:8]};
                    2'b10: DataRd = {24'h000000, word[23:16]};
                    2'b11: DataRd = {24'h000000, word[31:24]};
                endcase
            end
            3'b101: begin // LHU (load half unsigned)
                if (Address[1] == 1'b0)
                    DataRd = {16'h0000, word[15:0]};
                else
                    DataRd = {16'h0000, word[31:16]};
            end
            default: DataRd = 32'h00000000;
        endcase
    end

    // --- Synchronous write ---
    always @(posedge clk) begin
        if (DMWR) begin
            case (DMCtrl)
                3'b010: begin // SW (store word)
                    mem[word_idx] <= DataWr;
                end
                3'b001: begin // SH (store half)
                    if (Address[1] == 1'b0)
                        mem[word_idx][15:0]  <= DataWr[15:0];
                    else
                        mem[word_idx][31:16] <= DataWr[15:0];
                end
                3'b000: begin // SB (store byte)
                    case (Address[1:0])
                        2'b00: mem[word_idx][7:0]   <= DataWr[7:0];
                        2'b01: mem[word_idx][15:8]  <= DataWr[7:0];
                        2'b10: mem[word_idx][23:16] <= DataWr[7:0];
                        2'b11: mem[word_idx][31:24] <= DataWr[7:0];
                    endcase
                end
            endcase
        end
    end

endmodule
