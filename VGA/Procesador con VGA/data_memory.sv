module data_memory (
  input             clk,
  input             rst_n,        // reset activo en bajo
  input      [31:0] address,      
  input      [31:0] DataWr,      
  input             DMWR,         
  input      [2:0]  DMCtrl,       
  output reg [31:0] DMOut,        
  output     [7:0]  memory [0:31] 
);

  integer i;
  
  always @(negedge rst_n or posedge clk) begin
    if (!rst_n) begin
      for (i = 0; i < 32; i = i + 1) begin
        memory[i] <= 8'd0;
      end
    end else if (DMWR) begin
      if (address < 32) begin
        case (DMCtrl)
          3'b000: memory[address] <= DataWr[7:0]; // SB
          3'b001: if (address < 31) begin // SH
            memory[address]   <= DataWr[7:0];
            memory[address+1] <= DataWr[15:8];
          end
          3'b010: if (address < 29) begin // SW
            memory[address]   <= DataWr[7:0];
            memory[address+1] <= DataWr[15:8];
            memory[address+2] <= DataWr[23:16];
            memory[address+3] <= DataWr[31:24];
          end
        endcase
      end
    end
  end

  // Extensión de signo para LH
  wire [15:0] halfword;
  assign halfword = (address < 31) ? {memory[address+1], memory[address]} : 16'b0;

  // LOAD
  always @(*) begin
    if (!DMWR && address < 32) begin
      case (DMCtrl)
        3'b000: DMOut = {{24{memory[address][7]}}, memory[address]}; // LB
        3'b001: DMOut = {{16{halfword[15]}}, halfword}; // LH
        3'b010: if (address < 29)
                  DMOut = {memory[address+3], memory[address+2], memory[address+1], memory[address]};
                else
                  DMOut = 32'b0;
        3'b100: DMOut = {24'b0, memory[address]}; // LBU
        3'b101: if (address < 31)
                  DMOut = {16'b0, memory[address+1], memory[address]};
                else
                  DMOut = 32'b0;
        default: DMOut = 32'b0;
      endcase
    end else begin
      DMOut = 32'b0;
    end
  end

endmodule
