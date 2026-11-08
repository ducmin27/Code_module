// 1. Bộ nhớ lệnh (Instruction Memory - ROM 64 words x 32-bit)
module imem (
    input  wire [31:0] a,
    output wire [31:0] rd
);
    reg [31:0] RAM[63:0];

    initial begin
        // Chương trình kiểm thử toàn diện các nhóm lệnh ARM:
        // Địa chỉ | Mã máy (Hex) | Lệnh Assembly tương ứng       | Giải thích kết quả kỳ vọng
        RAM[0]  = 32'hE3A00005; // 0x00: MOV  R0, #5              -> R0 = 5
        RAM[1]  = 32'hE3A0100C; // 0x04: MOV  R1, #12             -> R1 = 12
        RAM[2]  = 32'hE1A02100; // 0x08: LSL  R2, R0, #2          -> R2 = R0 << 2 = 5 * 4 = 20 (Shift trái)
        RAM[3]  = 32'hE0813002; // 0x0C: ADD  R3, R1, R2          -> R3 = 12 + 20 = 32 (Data Processing)
        RAM[4]  = 32'hE1A040A3; // 0x10: LSR  R4, R3, #1          -> R4 = 32 >> 1 = 16 (Shift phải)
        RAM[5]  = 32'hE2545010; // 0x14: SUBS R5, R4, #16         -> R5 = 16 - 16 = 0 (Cập nhật cờ Z = 1)
        RAM[6]  = 32'h0A000000; // 0x18: BEQ  target (offset = 0) -> Nhảy tới PC+8+0 = 0x20 vì Z = 1 (Branch)
        RAM[7]  = 32'hE3A040FF; // 0x1C: MOV  R4, #255            -> Lệnh này bị BỎ QUA do lệnh BEQ ở trên!
        RAM[8]  = 32'hE5803060; // 0x20: STR  R3, [R0, #96]       -> Mem[5 + 96] = Mem[101] = 32 (Memory Store)
        RAM[9]  = 32'hE5906060; // 0x24: LDR  R6, [R0, #96]       -> R6 = Mem[101] = 32 (Memory Load)
        RAM[10] = 32'hE0867002; // 0x28: ADD  R7, R6, R2          -> R7 = 32 + 20 = 52
        RAM[11] = 32'hE5807060; // 0x2C: STR  R7, [R0, #96]       -> Mem[101] = 52 (Lưu kết quả cuối cùng)
    end

    assign rd = RAM[a[31:2]]; // Word-aligned address (chia 4)
endmodule

// 2. Bộ nhớ dữ liệu (Data Memory - RAM 64 words x 32-bit)
module dmem (
    input  wire        clk, we,
    input  wire [31:0] a, wd,
    output wire [31:0] rd
);
    reg [31:0] RAM[63:0];

    assign rd = RAM[a[31:2]]; // Đọc bất đồng bộ (Word-aligned)

    always @(posedge clk) begin
        if (we) RAM[a[31:2]] <= wd; // Ghi đồng bộ vào cạnh lên CLK
    end
endmodule

// 3. Module Top-Level kết nối toàn mạch (ARM Processor + Instruction Memory + Data Memory)
module top (
    input  wire        clk, reset,
    output wire [31:0] writedata, dataadr,
    output wire        memwrite
);
    wire [31:0] pc, instr, readdata;

    // Kết nối Lõi vi xử lý ARM đơn chu kỳ
    arm_single arm(
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .instr(instr),
        .memwrite(memwrite),
        .aluresult(dataadr),
        .writedata(writedata),
        .readdata(readdata)
    );

    // Kết nối Bộ nhớ lệnh (IMEM) và Bộ nhớ dữ liệu (DMEM)
    imem imem_unit(
        .a(pc),
        .rd(instr)
    );

    dmem dmem_unit(
        .clk(clk),
        .we(memwrite),
        .a(dataadr),
        .wd(writedata),
        .rd(readdata)
    );
endmodule