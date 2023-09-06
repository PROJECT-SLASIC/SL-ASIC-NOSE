`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.09.2023 16:48:18
// Design Name: 
// Module Name: multiplier_tb
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

module testbench;  
  // Inputs
  reg [31:0] A;
  reg [31:0] B;
  reg clk;
  reg reset;
  
  // Outputs
  wire [63:0] P;
  
  // Instantiate the multiplier module
  multiplier dut (
    .A(A),
    .B(B),
    .clk(clk),
    .reset(reset),
    .P(P)
  );
  
  // Clock generation
  always begin
    #5 clk = ~clk;
  end
  
  // Testbench process
  initial begin
    // Initialize inputs
    A = 5;
    B = 10;
    clk = 0;
    reset = 0;
    
    // Apply reset
    reset = 1;
    #10 reset = 0;
    
    // Wait for multiplication to complete
    #20;
    
    // Display the result
    $display("A * B = %d", P);
    
    // Finish simulation
    $finish;
  end
  
endmodule