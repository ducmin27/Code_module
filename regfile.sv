module regfile (
    input  wire        clk,
    input  wire        we3,           // Tín hiệu cho phép ghi (RegWrite)
    input  wire [3:0]  ra1, ra2, wa3, // Địa chỉ đọc A1, A2 và địa chỉ ghi A3 (Rd)
    input  wire [31:0] wd3, r15,      // Dữ liệu ghi WD3 (Result) và đầu vào R15 (PCPlus8)
    output wire [31:0] rd1, rd2       // Dữ liệu đọc ra RD1, RD2
);
    reg [31:0] rf[14:0]; // 15 thanh ghi thực R0 -> R14 (R15 lấy trực tiếp từ cổng r15)

    // Ghi dữ liệu vào cạnh lên của xung nhịp CLK (không ghi đè vào R15 tại mảng rf)
    always @(posedge clk) begin
        if (we3 && (wa3 != 4'b1111))
            rf[wa3] <= wd3;
    end

    // Đọc dữ liệu tổ hợp: nếu địa chỉ là 15 (4'b1111) thì xuất giá trị r15 (PCPlus8)
    assign rd1 = (ra1 == 4'b1111) ? r15 : rf[ra1];
    assign rd2 = (ra2 == 4'b1111) ? r15 : rf[ra2];
endmodule