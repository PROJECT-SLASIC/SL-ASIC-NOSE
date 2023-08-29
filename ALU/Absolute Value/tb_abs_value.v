module tb_abs_value_ieee754;

// Internal signals
reg [31:0] data_in;
wire [31:0] data_out;

// Instantiate the absolute value module
abs_value_ieee754 u_abs_value_ieee754 (
    .data_in(data_in),
    .data_out(data_out)
);

// Testbench logic
initial begin
    $display("data_in \t\t data_out");

    // Test positive value
    data_in = 32'h3F800000; // 1.0
    #10 $display("%h \t %h", data_in, data_out);

    // Test negative value
    data_in = 32'hBF800000; // -1.0
    #10 $display("%h \t %h", data_in, data_out);

    $finish;
end

endmodule
