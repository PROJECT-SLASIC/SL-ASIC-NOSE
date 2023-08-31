module ieee754_converter_tb;

    reg [31:0] integer_part;
    reg [31:0] fractional_part;
    wire [31:0] ieee754_output;

    // Instantiate the module under test
    ieee754_converter converter (
        .integer_part(integer_part),
        .fractional_part(fractional_part),
        .ieee754_output(ieee754_output)
    );

    initial begin
        $dumpfile("simulation.vcd");
        $dumpvars(0, ieee754_converter_tb);

        // Test Case 1: integer_part = 5, fractional_part = 0.5
        integer_part = 32'h00000005;
        fractional_part = 32'h80000000;
        #10;
      
        // Test Case 2: integer_part = 123, fractional_part = 0.456
        integer_part = 32'h0000007B;
        fractional_part = 32'h74BC6A00;
        #10;    

        // Test Case 3: integer_part = 0, fractional_part = 0.25
        integer_part = 32'h00000000;
        fractional_part = 32'h40000000;
        #10;

        $finish;
    end

endmodule
