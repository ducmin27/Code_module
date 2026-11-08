// Khối Control Unit hoàn chỉnh trên sơ đồ
module controller (
    input  wire        clk, reset,
    input  wire [31:12] instr,
    input  wire [3:0]  aluflags,
    output wire [1:0]  regsrc,
    output wire        regwrite,
    output wire [1:0]  immsrc,
    output wire        alusrc,
    output wire [2:0]  alucontrol,
    output wire        memwrite, memtoreg,
    output wire        pcsrc
);
    wire [1:0] flagw;
    wire       pcs, regw, memw;

    decoder dec(
        .op(instr[27:26]),
        .funct(instr[25:20]),
        .rd(instr[15:12]),
        .flagw(flagw),
        .pcs(pcs),
        .regw(regw),
        .memw(memw),
        .memtoreg(memtoreg),
        .alusrc(alusrc),
        .immsrc(immsrc),
        .regsrc(regsrc),
        .alucontrol(alucontrol)
    );

    condlogic cl(
        .clk(clk),
        .reset(reset),
        .cond(instr[31:28]),
        .aluflags(aluflags),
        .flagw(flagw),
        .pcs(pcs),
        .regw(regw),
        .memw(memw),
        .pcsrc(pcsrc),
        .regwrite(regwrite),
        .memwrite(memwrite)
    );
endmodule

// Lõi Vi xử lý đơn chu kỳ ARM (Kết nối Control Unit + Datapath)
module arm_single (
    input  wire        clk, reset,
    output wire [31:0] pc,
    input  wire [31:0] instr,
    output wire        memwrite,
    output wire [31:0] aluresult, writedata,
    input  wire [31:0] readdata
);
    wire [3:0] aluflags;
    wire       regwrite, alusrc, memtoreg, pcsrc;
    wire [1:0] regsrc, immsrc;
    wire [2:0] alucontrol;

    controller c(
        .clk(clk),
        .reset(reset),
        .instr(instr[31:12]),
        .aluflags(aluflags),
        .regsrc(regsrc),
        .regwrite(regwrite),
        .immsrc(immsrc),
        .alusrc(alusrc),
        .alucontrol(alucontrol),
        .memwrite(memwrite),
        .memtoreg(memtoreg),
        .pcsrc(pcsrc)
    );

    datapath dp(
        .clk(clk),
        .reset(reset),
        .regsrc(regsrc),
        .regwrite(regwrite),
        .immsrc(immsrc),
        .alusrc(alusrc),
        .alucontrol(alucontrol),
        .memtoreg(memtoreg),
        .pcsrc(pcsrc),
        .aluflags(aluflags),
        .pc(pc),
        .instr(instr),
        .aluresult(aluresult),
        .writedata(writedata),
        .readdata(readdata)
    );
endmodule