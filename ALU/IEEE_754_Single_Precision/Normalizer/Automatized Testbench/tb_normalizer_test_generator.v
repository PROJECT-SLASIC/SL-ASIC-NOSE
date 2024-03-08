`timescale 1ns / 1ps

module tb_normalizer;

    // Inputs
    reg clk;
    reg rst;
    reg start;
    wire valid;
    wire busy;
    reg [31:0] max;
    reg [31:0] min;
    reg [31:0] in_data;

    // Outputs
    wire [31:0] out_data;

    // Instantiate the Unit Under Test (UUT)
    normalizer uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .valid(valid),
        .busy(busy),
        .max(max),
        .min(min),
        .in_data(in_data),
        .out_data(out_data)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Initialize Inputs and apply test cases
    initial begin
        // Initialize Inputs
        clk = 1;
        rst = 0;
        start = 0;
        max = 0;
        min = 0;
        in_data = 0;

        // Wait for global reset
        #100;

        // Add stimulus here
        // Example test case
        rst = 1; #20;
        rst = 0; #20;
        start = 1;
        max = 0'h41733333; min = 0'h40733333; in_data = 0'h4111eb85;
        #10
        start = 0;
        #500
        
        start = 1;
        max = 0'h4a3d3580; min = 0'h47629000; in_data = 0'h490ed280;
        #10
        start = 0;
        #500;

        // You can add more test cases here
        // ...

        // Finish the simulation
        $finish;
    end

endmodule
