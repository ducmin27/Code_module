module extend (
    input  wire [23:0] instr,
    input  wire [1:0]  immsrc,
    output reg  [31:0] extimm
);
    always @(*) begin
        case (immsrc)
            // 00: Hằng số 8-bit không dấu cho lệnh Data Processing / MOV (Imm)
            2'b00: extimm = {24'b0, instr[7:0]};
            
            // 01: Offset 12-bit không dấu cho lệnh LDR / STR
            2'b01: extimm = {20'b0, instr[11:0]};
            
            // 10: Offset 24-bit có dấu, dịch trái 2 bit (nhân 4) cho lệnh Branch (B)
            2'b10: extimm = {{6{instr[23]}}, instr[23:0], 2'b00};
            
            default: extimm = 32'bx;
        endcase
    end
endmodule