module alu (
    input  wire [31:0] a,          // Toán hạng nguồn 1 (SrcA)
    input  wire [31:0] b,          // Toán hạng nguồn 2 (SrcB)
    input  wire [2:0]  alucontrol, // Tín hiệu điều khiển ALUControl[2:0]
    output reg  [31:0] result,     // Kết quả ALUResult
    output wire [3:0]  aluflags    // Cờ trạng thái {N, Z, C, V}
);
    wire        neg, zero, carry, overflow;
    wire [31:0] condinvb;
    wire [32:0] sum;

    // Đảo bit B và cộng thêm 1 (thông qua alucontrol[0]) khi thực hiện phép Trừ (SUB = 3'b001)
    assign condinvb = alucontrol[0] ? ~b : b;
    assign sum      = a + condinvb + alucontrol[0];

    always @(*) begin
        case (alucontrol)
            3'b000: result = sum[31:0]; // ADD (Cộng: dùng cho ADD, LDR, STR, B)
            3'b001: result = sum[31:0]; // SUB (Trừ: dùng cho SUB, CMP)
            3'b010: result = a & b;     // AND (Logic AND)
            3'b011: result = a | b;     // ORR (Logic OR)
            3'b100: result = a ^ b;     // EOR (Logic XOR)
            3'b101: result = b;         // MOV / SHIFT (Truyền thẳng SrcB sang ALUResult)
            default: result = 32'bx;
        endcase
    end

    // Tính toán 4 cờ trạng thái {N, Z, C, V}
    assign neg      = result[31];
    assign zero     = (result == 32'b0);
    assign carry    = (alucontrol[2:1] == 2'b00) & sum[32];
    assign overflow = (alucontrol[2:1] == 2'b00) &
                      ~(a[31] ^ b[31] ^ alucontrol[0]) &
                      (a[31] ^ sum[31]);

    assign aluflags = {neg, zero, carry, overflow};
endmodule