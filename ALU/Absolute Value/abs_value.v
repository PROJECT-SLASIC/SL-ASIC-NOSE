module absolute_value (
    input [31:0] data_in,
    input start,
    output [31:0] data_out
);

assign data_out = start ? (data_in & 32'h7FFFFFFF) : 32'd0;

endmodule
