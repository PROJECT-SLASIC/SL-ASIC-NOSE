module abs_value (
    input [31:0] data_in,
    input is_signed,      // 1 if data_in is signed, 0 if unsigned
    output reg [31:0] data_out
);

always @* begin
    if(is_signed && data_in[31])        // If signed and negative
        data_out = ~data_in + 1;        // Two's complement to get positive value
    else
        data_out = data_in;             // Return as is
end

endmodule
