module decoder (
    input  wire [1:0] op,
    input  wire [5:0] funct,
    input  wire [3:0] rd,
    output reg  [1:0] flagw,
    output wire       pcs, regw, memw,
    output wire       memtoreg, alusrc,
    output wire [1:0] immsrc, regsrc,
    output reg  [2:0] alucontrol
);
    reg [9:0] controls;
    wire      branch, aluop;

    // --- 1. Main Decoder: Giải mã dựa trên Op[1:0], Funct[5] (bit I), Funct[0] (bit L) ---
    always @(*) begin
        casex (op)
            // Op = 00: Nhóm lệnh Data Processing / Move / Shift
            2'b00: begin
                if (funct[5]) // I = 1: Toán hạng thứ 2 là hằng số tức thời (Immediate)
                    controls = 10'b0_0_0_1_00_1_00_1;
                else          // I = 0: Toán hạng thứ 2 là thanh ghi Rm (qua khối Shift)
                    controls = 10'b0_0_0_0_00_1_00_1;
            end
            // Op = 01: Nhóm lệnh Memory (LDR / STR)
            2'b01: begin
                if (funct[0]) // L = 1: Lệnh nạp bộ nhớ LDR
                    controls = 10'b0_1_0_1_01_1_00_0;
                else          // L = 0: Lệnh lưu bộ nhớ STR
                    controls = 10'b0_0_1_1_01_0_10_0;
            end
            // Op = 10: Nhóm lệnh Rẽ nhánh Branch (B)
            2'b10:  controls = 10'b1_0_0_1_10_0_01_0;
            default: controls = 10'bx;
        endcase
    end

    assign {branch, memtoreg, memw, alusrc, immsrc, regw, regsrc, aluop} = controls;

    // --- 2. ALU Decoder: Giải mã Funct[4:0] thành ALUControl[2:0] và FlagW[1:0] ---
    always @(*) begin
        if (aluop) begin
            case (funct[4:1])
                4'b0100: alucontrol = 3'b000; // ADD
                4'b0010: alucontrol = 3'b001; // SUB
                4'b0000: alucontrol = 3'b010; // AND
                4'b1100: alucontrol = 3'b011; // ORR
                4'b0001: alucontrol = 3'b100; // EOR (XOR)
                4'b1101: alucontrol = 3'b101; // MOV / Shift (LSL, LSR, ASR, ROR)
                4'b1010: alucontrol = 3'b001; // CMP (Trừ để lấy cờ)
                default: alucontrol = 3'bx;
            endcase
            // Cập nhật cờ khi bit S (funct[0]) = 1
            flagw[1] = funct[0]; // Cập nhật cờ N, Z cho mọi phép toán có S=1
            flagw[0] = funct[0] & (alucontrol == 3'b000 | alucontrol == 3'b001); // Cờ C, V cho ADD/SUB
        end else begin
            alucontrol = 3'b000; // Cộng địa chỉ cho lệnh LDR, STR và Branch
            flagw      = 2'b00;  // Không cập nhật cờ
        end
    end

    // --- 3. Logic PC: Bật PCS khi có lệnh Branch HOẶC khi ghi kết quả trực tiếp vào R15 ---
    assign pcs = ((rd == 4'b1111) & regw) | branch;
endmodule