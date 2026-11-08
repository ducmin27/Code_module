`timescale 1ns / 1ps

module tb_arm_single();
    reg         clk;
    reg         reset;
    wire [31:0] writedata, dataadr;
    wire        memwrite;

    // Khởi tạo hệ thống vi xử lý đơn chu kỳ ARM (Device Under Test)
    top dut(
        .clk(clk),
        .reset(reset),
        .writedata(writedata),
        .dataadr(dataadr),
        .memwrite(memwrite)
    );

    // Khởi tạo tín hiệu Reset ban đầu
    initial begin
        reset = 1;
        #22;
        reset = 0;
    end

    // Tạo xung nhịp đồng hồ CLK (Chu kỳ T = 10ns -> Tần số 100MHz)
    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    // In thông tin giám sát mỗi chu kỳ xung nhịp (sườn xuống CLK để dữ liệu đã ổn định)
    always @(negedge clk) begin
        if (!reset) begin
            $display("Time=%0t ns | PC=0x%02h | Instr=0x%08h | ALUResult(Addr)=%0d | WriteData=%0d | MemWrite=%b",
                     $time, dut.pc, dut.instr, dataadr, writedata, memwrite);
                     
            // Kiểm tra tự động (Self-check) khi có lệnh STR ghi vào Data Memory
            if (memwrite) begin
                if (dataadr === 32'd101 && writedata === 32'd32) begin
                    $display("  --> [PASS 1] Lenh STR dau tien thanh cong: Mem[101] = 32");
                end else if (dataadr === 32'd101 && writedata === 32'd52) begin
                    $display("  --> [PASS 2] HOAN TAT CHUONG TRINH! tat ca cac lenh MOV, SHIFT, ADD, SUBS, BEQ, LDR, STR deu chay CHINH XAC (Mem[101] = 52)!");
                    $stop;
                end else begin
                    $display("  --> [ERROR] Gia tri ghi bo nho khong khop: Addr=%0d, Data=%0d", dataadr, writedata);
                    $stop;
                end
            end
        end
    end
endmodule