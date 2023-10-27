`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2023 13:20:44
// Design Name: 
// Module Name: divider_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps
module test_booth_algorithm_divider;

    // Parameters
    parameter width = 23;

    // Inputs
    reg clk;
    reg rst;
    reg [31:0] divident;
    reg [31:0] divisor;
    reg start_flag;

    // Outputs
    wire busy_o;
    wire valid_o;
    wire error_o;
    wire [31:0] result_o;

    // Instantiate the UUT (Unit Under Test)
    booth_algorithm_divider UUT(
        .clk_i(clk),
        .rst_i(rst),
        .divident(divident),
        .divisor(divisor),
        .start_flag(start_flag),
        .busy_o(busy_o),
        .valid_o(valid_o),
        .error_o(error_o),
        .result_o(result_o)
    );

    // Clock Generation
    always begin
       #10 clk = ~clk;
    end

    // Testbench Stimulus
    initial begin
        // Initialize inputs
        clk = 1'b0;
        rst = 1;
        divident = 32'b01000010100101100000000000000000;    //75
        divisor = 32'b01000000101000000000000000000000;     //5
        #20;
        rst = 0;
        #20;

        // Test 1: Normal division
       
        start_flag = 1;
        #20;
        start_flag = 0;
        #100;

        // Check result
        if (valid_o) begin
            $display("Test 1: 8 / 2 = %d", result_o);
        end else begin
            $display("Test 1: Error or no valid output!");
        end


        // Check result
        if (error_o) begin
            $display("Test 2: Division by zero detected!");
        end else begin
            $display("Test 2: No error detected for division by zero!");
        end


        // Check result
        if (valid_o) begin
            $display("Test 3: 10 mod 3 = %d", result_o);
        end else begin
            $display("Test 3: Error or no valid output!");
        end

        // Finish simulation
        $finish;
    end

endmodule

