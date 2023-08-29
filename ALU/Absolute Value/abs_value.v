module abs_value_ieee754 (
    input [31:0] data_in,
    output [31:0] data_out
);

assign data_out = data_in & 32'h7FFFFFFF;

endmodule
