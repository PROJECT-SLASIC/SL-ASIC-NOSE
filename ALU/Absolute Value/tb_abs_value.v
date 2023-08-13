module tb_abs_value;

// Internal signals
reg [31:0] data_in;
reg is_signed;
wire [31:0] data_out;

// Instantiate the absolute value module
abs_value u_abs_value (
    .data_in(data_in),
    .is_signed(is_signed),
    .data_out(data_out)
);

// Testbench logic
initial begin
    $display("data_in \t is_signed \t data_out");

    // Test positive value (signed)
    data_in = 32'd15; is_signed = 1'b1;
    #10 $display("%d \t %b \t %d", data_in, is_signed, data_out);

    // Test negative value (signed)
    data_in = 32'b11111111111111111111111111110001; is_signed = 1'b1; // Two's complement representation of -15
    #10 $display("%d \t %b \t %d", data_in, is_signed, data_out);

    // Test positive value (unsigned)
    data_in = 32'd15; is_signed = 1'b0;
    #10 $display("%d \t %b \t %d", data_in, is_signed, data_out);

    // Test large value (unsigned)
    data_in = 32'd4294967295; is_signed = 1'b0; // Maximum 32-bit unsigned integer
    #10 $display("%d \t %b \t %d", data_in, is_signed, data_out);

    $finish;
end

endmodule
