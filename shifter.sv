module shifter (
    input  wire [31:0] a,      // Dữ liệu đầu vào từ cổng RD2 (thanh ghi Rm)
    input  wire [4:0]  shamt5, // Lượng dịch 5-bit: Instr[11:7] (dịch từ 0 đến 31 bit)
    input  wire [1:0]  sh,     // Kiểu dịch 2-bit: Instr[6:5]
    output reg  [31:0] y       // Dữ liệu 32-bit sau khi dịch
);
    always @(*) begin
        if (shamt5 == 5'd0) begin
            y = a; // Không dịch khi shamt5 = 0
        end else begin
            case (sh)
                2'b00: y = a << shamt5;                         // LSL: Dịch trái logic
                2'b01: y = a >> shamt5;                         // LSR: Dịch phải logic
                2'b10: y = $signed(a) >>> shamt5;               // ASR: Dịch phải số học (giữ dấu)
                2'b11: y = (a >> shamt5) | (a << (32 - shamt5));// ROR: Xoay phải bit
                default: y = a;
            endcase
        end
    end
endmodule