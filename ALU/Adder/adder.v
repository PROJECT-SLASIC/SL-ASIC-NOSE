module adder(
    input [31:0] A, B,
    input carry_in,
    output [31:0] sum,
    output carry_out
);

assign {carry_out, sum} = A + B + carry_in;

endmodule
