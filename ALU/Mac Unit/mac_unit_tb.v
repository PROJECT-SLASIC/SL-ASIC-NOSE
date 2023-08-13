module mac_unit_tb;

    reg clk;
    reg rst;
    reg [31:0] rs1;
    reg [31:0] rs2;
    reg rs1_signed;
    reg rs2_signed;
    reg start_mul;
    reg clear_acc;

    wire [63:0] mac_result;
    wire acc_valid;
    wire acc_busy;

    // Instantiate the mac_unit
    mac_unit uut (
        .clk(clk),
        .rst(rst),
        .rs1(rs1),
        .rs2(rs2),
        .rs1_signed(rs1_signed),
        .rs2_signed(rs2_signed),
        .start_mul(start_mul),
        .clear_acc(clear_acc),
        .mac_result(mac_result),
        .acc_valid(acc_valid),
        .acc_busy(acc_busy)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initial settings
        clk = 0;
        rst = 1;
        rs1 = 0;
        rs2 = 0;
        rs1_signed = 0;
        rs2_signed = 0;
        start_mul = 0;
        clear_acc = 0;
        #20;
        rst = 0;

        // Test case 1: Simple multiplication (as provided)
        rs1 = 32'h12345678; rs2 = 32'h87654321;
        rs1_signed = 1; rs2_signed = 1;
        start_mul = 1; #10; start_mul = 0;
        wait(acc_valid); #10;

        // Test case 2: Another simple multiplication (as provided)
        rs1 = 32'h1234ABCD; rs2 = 32'hEFab5678;
        rs1_signed = 0; rs2_signed = 0;
        start_mul = 1; #10; start_mul = 0;
        wait(acc_valid); #10;

        // Test case 3: Boundary Values
        rs1 = 32'h7FFFFFFF; rs2 = 32'h80000000;
        rs1_signed = 0; rs2_signed = 1;
        start_mul = 1; #10; start_mul = 0;
        wait(acc_valid); #10;

        // Test case 4: Random Values
        rs1 = $random; rs2 = $random;
        rs1_signed = 0; rs2_signed = 0;
        start_mul = 1; #10; start_mul = 0;
        wait(acc_valid); #10;

        // Test case 5: Quick Successive Starts
        rs1 = 32'h11111111; rs2 = 32'h22222222;
        start_mul = 1; #5; start_mul = 0;  // Short wait time
        rs1 = 32'h33333333; rs2 = 32'h44444444;
        start_mul = 1; #5; start_mul = 0;
        wait(acc_valid); #10;

        // Test case 6: Both inputs zero
        rs1 = 0; rs2 = 0;
        rs1_signed = 0; rs2_signed = 0;
        start_mul = 1; #10; start_mul = 0;
        wait(acc_valid); #20;

        // Clearing accumulator
        clear_acc = 1; #10; clear_acc = 0;

        $finish;
    end

endmodule
