module adder(
    input [31:0] A, B,
    input carry_in,
    input start,
    output [31:0] sum,
    output carry_out
);

assign {carry_out, sum} = start ? (A + B + carry_in) : {1'b0, 32'b0};

endmodule
