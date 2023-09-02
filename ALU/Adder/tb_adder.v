`timescale 1ns / 1ps

module tb_adder_32bit_with_carry();
    reg [31:0] A;
    reg [31:0] B;
    reg carry_in;
    reg clk;
    reg rst;
    wire [31:0] sum;
    wire carry_out;

    adder_32bit_with_carry uut (
        .A(A), 
        .B(B), 
        .carry_in(carry_in),
        .clk(clk), 
        .rst(rst), 
        .sum(sum), 
        .carry_out(carry_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        A = 32'h0;
        B = 32'h0;
        carry_in = 0;
        #10 rst = 0;
        
        // test case 1
        A = 32'h1; B = 32'h1; carry_in = 1;
        #10
        // test case 2
        A = 32'hFFFFFFFE; B = 32'h1; carry_in = 1;
        #10
        // test case 3
        A = 32'h80000000; B = 32'h80000000; carry_in = 0;
        #10
        
        // Random test cases
        A = $random; B = $random; carry_in = $random;
        #10
        A = $random; B = $random; carry_in = $random;
        #10
        A = $random; B = $random; carry_in = $random;
        #10
        
        rst = 1;
        #10 $stop;
    end
endmodule
