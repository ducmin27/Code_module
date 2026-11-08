module datapath (
    input  wire        clk, reset,
    input  wire [1:0]  regsrc,
    input  wire        regwrite,
    input  wire [1:0]  immsrc,
    input  wire        alusrc,
    input  wire [2:0]  alucontrol,
    input  wire        memtoreg,
    input  wire        pcsrc,
    output wire [3:0]  aluflags,
    output wire [31:0] pc,
    input  wire [31:0] instr,
    output wire [31:0] aluresult, writedata,
    input  wire [31:0] readdata
);
    wire [31:0] pcnext, pcplus4, pcplus8;
    wire [31:0] extimm, srca, srcb, result;
    wire [31:0] rd2_shifted;
    wire [3:0]  ra1, ra2;

    // --- 1. Logic cập nhật PC và các bộ cộng PC+4, PC+8 ---
    mux2 #(32)  pcmux(
        .d0(pcplus4),
        .d1(result),
        .s(pcsrc),
        .y(pcnext)
    );
    flopr #(32) pcreg(
        .clk(clk),
        .reset(reset),
        .d(pcnext),
        .q(pc)
    );
    adder #(32) pcadd1(
        .a(pc),
        .b(32'd4),
        .y(pcplus4)
    );
    adder #(32) pcadd2(
        .a(pcplus4),
        .b(32'd4),
        .y(pcplus8)
    );

    // --- 2. Logic chọn địa chỉ đọc và Tập thanh ghi (Register File) ---
    mux2 #(4) ra1mux(
        .d0(instr[19:16]), // Rn
        .d1(4'b1111),      // R15 (15)
        .s(regsrc[0]),
        .y(ra1)
    );
    mux2 #(4) ra2mux(
        .d0(instr[3:0]),   // Rm
        .d1(instr[15:12]), // Rd (cho lệnh STR)
        .s(regsrc[1]),
        .y(ra2)
    );
    regfile rf(
        .clk(clk),
        .we3(regwrite),
        .ra1(ra1),
        .ra2(ra2),
        .wa3(instr[15:12]),
        .wd3(result),
        .r15(pcplus8),
        .rd1(srca),
        .rd2(writedata)
    );

    // --- 3. Khối Mở rộng dấu (Extend) và Khối Dịch bit (Shift) ---
    extend ext(
        .instr(instr[23:0]),
        .immsrc(immsrc),
        .extimm(extimm)
    );
    shifter shft(
        .a(writedata),
        .shamt5(instr[11:7]),
        .sh(instr[6:5]),
        .y(rd2_shifted)
    );

    // --- 4. Chọn toán hạng SrcB và Khối ALU ---
    mux2 #(32) srcbmux(
        .d0(rd2_shifted),
        .d1(extimm),
        .s(alusrc),
        .y(srcb)
    );
    alu alu_unit(
        .a(srca),
        .b(srcb),
        .alucontrol(alucontrol),
        .result(aluresult),
        .aluflags(aluflags)
    );

    // --- 5. MUX chọn kết quả cuối cùng (MemtoReg) ---
    mux2 #(32) resmux(
        .d0(aluresult),
        .d1(readdata),
        .s(memtoreg),
        .y(result)
    );
endmodule