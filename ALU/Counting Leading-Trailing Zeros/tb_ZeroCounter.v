module tb_ZeroCounter;

    reg [31:0] data;
    reg leading_or_trailing;
    wire [5:0] count;

    // Instantiate the count_zeros module
    ZeroCounter u0 (
        .data(data),
        .leading_or_trailing(leading_or_trailing),
        .count(count)
    );

    // Test procedure
    initial begin
        $display("data\t\tleading_or_trailing\tcount");
        $display("-------------------------------------------------");

        data = 32'b00000000000000000000000000000000; leading_or_trailing = 1; #10;
        $display("%b\t%b\t\t\t\t%d", data, leading_or_trailing, count);

        data = 32'b00000000000000000000000000000001; leading_or_trailing = 0; #10;
        $display("%b\t%b\t\t\t\t%d", data, leading_or_trailing, count);

        data = 32'b10000000000000000000000000000000; leading_or_trailing = 1; #10;
        $display("%b\t%b\t\t\t\t%d", data, leading_or_trailing, count);

        data = 32'b00000000000000000000000000000010; leading_or_trailing = 0; #10;
        $display("%b\t%b\t\t\t\t%d", data, leading_or_trailing, count);

        data = 32'b00000010000000000000000000000000; leading_or_trailing = 1; #10;
        $display("%b\t%b\t\t\t\t%d", data, leading_or_trailing, count);

        data = 32'b00000000000000000000001000000000; leading_or_trailing = 0; #10;
        $display("%b\t%b\t\t\t\t%d", data, leading_or_trailing, count);

        $finish;
    end

endmodule
