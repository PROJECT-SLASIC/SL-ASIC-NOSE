`timescale 1ns/1ps

module tb_adder_32bit;

  // Declare testbench signals
  reg [31:0] a, b;
  reg clk, reset;
  wire [31:0] sum;

  // Instantiate the device under test (DUT)
  adder_32bit dut (
    .a(a),
    .b(b),
    .clk(clk),
    .reset(reset),
    .sum(sum)
  );

  // Clock generation
  always begin
    #5 clk = ~clk;
  end

  // Test procedure
  initial begin
    // Initialize signals
    clk = 0;
    reset = 1;
    a = 32'h00000000; // Initialize 'a'
    b = 32'h00000000; // Initialize 'b'

    #10 reset = 0;
    #10;

    // Test case 1
    a = 32'h00000001;
    b = 32'h00000002;
    #10;
    $display("Test case 1: a = %h, b = %h, sum = %h", a, b, sum);
    if (sum != 32'h00000003) $display("Error in Test case 1!");

    // Test case 2
    a = 32'hFFFFFFFF;
    b = 32'h00000001;
    #10;
    $display("Test case 2: a = %h, b = %h, sum = %h", a, b, sum);
    if (sum != 32'h00000000) $display("Error in Test case 2!");

    // Add more test cases as needed

    // Finish simulation
    $finish;
  end

endmodule
