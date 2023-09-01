`timescale 1ns / 1ps

module multiplier_unsigned_tb;

    parameter WIDTH = 24;

    reg clk;
    reg rst;
    reg [WIDTH-1:0] rs1;
    reg [WIDTH-1:0] rs2;
    reg start;
    wire [WIDTH-1:0] result;
    wire valid;
    wire busy;

    // Instantiate the Unit Under Test (UUT)
    multiplier_unsigned #(WIDTH) uut (
        .clk(clk),
        .rst(rst),
        .rs1(rs1),
        .rs2(rs2),
        .start(start),
        .result(result),
        .valid(valid),
        .busy(busy)
    );

    initial begin
        // Initialize inputs
        clk = 0;
        rst = 0;
        rs1 = 0;
        rs2 = 0;
        start = 0;
        
        // Apply reset
        rst = 1;
        #10;
        rst = 0;
        #10;
        
        // Apply input values
        rs1 = 24'h000123;
        rs2 = 24'h000456;
        start = 1;
        #10;
        
        // Wait for operation to complete
        wait (!busy);
        
        // Check result
        if (result !== 24'h056088) begin
            $display("Test Failed. Expected: 056088, Got: %h", result);
        end else begin
            $display("Test Passed.");
        end
        
        // End simulation
        $stop;
    end

    // Clock Generation
    always #5 clk = ~clk;

endmodule
