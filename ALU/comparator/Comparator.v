module tb_signed_comparator();

reg [31:0] A;
reg [31:0] B;
wire AeqB;
wire AltB;
wire AgtB;

signed_comparator u1 (
    .A(A),
    .B(B),
    .AeqB(AeqB),
    .AltB(AltB),
    .AgtB(AgtB)
);

initial begin
    // Example test cases
    A = 32'd10; B = 32'd-10; #10; // Expected: A > B
    if(AgtB) $display("Test 1 Passed");
    else $display("Test 1 Failed");

    A = 32'd-10; B = 32'd10; #10; // Expected: A < B
    if(AltB) $display("Test 2 Passed");
    else $display("Test 2 Failed");

    A = 32'd-10; B = 32'd-20; #10; // Expected: A > B
    if(AgtB) $display("Test 3 Passed");
    else $display("Test 3 Failed");

    $finish;
end

endmodule
