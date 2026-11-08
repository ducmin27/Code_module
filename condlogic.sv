module condlogic (
    input  wire       clk, reset,
    input  wire [3:0] cond,
    input  wire [3:0] aluflags,
    input  wire [1:0] flagw,
    input  wire       pcs, regw, memw,
    output wire       pcsrc, regwrite, memwrite
);
    wire [1:0] flagwrite;
    wire [3:0] flags;
    reg        condex;

    // Hai thanh ghi lưu 4 bit cờ trạng thái: Flags[3:2] = {N, Z}, Flags[1:0] = {C, V}
    flopenr #(2) flagreg1(
        .clk(clk), .reset(reset),
        .en(flagwrite[1]),
        .d(aluflags[3:2]),
        .q(flags[3:2])
    );
    flopenr #(2) flagreg0(
        .clk(clk), .reset(reset),
        .en(flagwrite[0]),
        .d(aluflags[1:0]),
        .q(flags[1:0])
    );

    // Mạch tổ hợp kiểm tra điều kiện Cond[31:28]
    wire neg, zero, carry, overflow, ge;
    assign {neg, zero, carry, overflow} = flags;
    assign ge = (neg == overflow);

    always @(*) begin
        case (cond)
            4'b0000: condex = zero;             // EQ (Equal - Bằng nhau)
            4'b0001: condex = ~zero;            // NE (Not Equal - Khác nhau)
            4'b0010: condex = carry;            // CS/HS (Carry Set)
            4'b0011: condex = ~carry;           // CC/LO (Carry Clear)
            4'b0100: condex = neg;              // MI (Minus / Negative)
            4'b0101: condex = ~neg;             // PL (Plus / Positive or Zero)
            4'b0110: condex = overflow;         // VS (Overflow)
            4'b0111: condex = ~overflow;        // VC (No Overflow)
            4'b1000: condex = carry & ~zero;    // HI (Unsigned Higher)
            4'b1001: condex = ~(carry & ~zero); // LS (Unsigned Lower or Same)
            4'b1010: condex = ge;               // GE (Signed Greater or Equal)
            4'b1011: condex = ~ge;              // LT (Signed Less Than)
            4'b1100: condex = ~zero & ge;       // GT (Signed Greater Than)
            4'b1101: condex = ~(~zero & ge);    // LE (Signed Less or Equal)
            4'b1110: condex = 1'b1;             // AL (Always - Luôn thực thi)
            default: condex = 1'bx;
        endcase
    end

    // Chỉ cho phép ghi cờ, ghi thanh ghi, ghi bộ nhớ và nhảy PC nếu điều kiện CondEx = 1
    assign flagwrite = flagw & {2{condex}};
    assign regwrite  = regw  & condex;
    assign memwrite  = memw  & condex;
    assign pcsrc     = pcs   & condex;
endmodule