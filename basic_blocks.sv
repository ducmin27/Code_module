// 1. Thanh ghi D Flip-Flop có Reset (Dùng cho thanh ghi PC)
module flopr #(parameter WIDTH = 32) (
    input  wire             clk, reset,
    input  wire [WIDTH-1:0] d,
    output reg  [WIDTH-1:0] q
);
    always @(posedge clk or posedge reset) begin
        if (reset) q <= {WIDTH{1'b0}};
        else       q <= d;
    end
endmodule

// 2. Thanh ghi D Flip-Flop có Enable và Reset (Dùng lưu cờ trạng thái Flags NZCV)
module flopenr #(parameter WIDTH = 2) (
    input  wire             clk, reset, en,
    input  wire [WIDTH-1:0] d,
    output reg  [WIDTH-1:0] q
);
    always @(posedge clk or posedge reset) begin
        if (reset)   q <= {WIDTH{1'b0}};
        else if (en) q <= d;
    end
endmodule

// 3. Bộ cộng 32-bit (Dùng cho PCPlus4 và PCPlus8)
module adder #(parameter WIDTH = 32) (
    input  wire [WIDTH-1:0] a, b,
    output wire [WIDTH-1:0] y
);
    assign y = a + b;
endmodule

// 4. Bộ chọn kênh Multiplexer 2-sang-1 (Dùng cho PCSrc, RegSrc, ALUSrc, MemtoReg)
module mux2 #(parameter WIDTH = 32) (
    input  wire [WIDTH-1:0] d0, d1,
    input  wire             s,
    output wire [WIDTH-1:0] y
);
    assign y = s ? d1 : d0;
endmodule