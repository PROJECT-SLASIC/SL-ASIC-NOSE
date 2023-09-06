`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.09.2023 16:45:34
// Design Name: 
// Module Name: multiplier
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

/*
32-bit Multiplier without Loops
 
This Verilog code implements a 32-bit multiplier without using any loops.
The multiplier takes two 32-bit inputs, A and B, and produces a 64-bit output, P.
The multiplication is performed using clock and reset processes.
 
*/
 
module multiplier(
  input wire [31:0] A,
  input wire [31:0] B,
  input wire clk,
  input wire reset,
  output wire [63:0] P
);
 
  // Internal registers for intermediate calculations
  reg [31:0] a_reg;
  reg [31:0] b_reg;
  reg [63:0] p_reg;
 
  // Clock and reset process
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      // Reset the registers
      a_reg <= 0;
      b_reg <= 0;
      p_reg <= 0;
    end else begin
      // Update the registers
      a_reg <= A;
      b_reg <= B;
      p_reg <= a_reg * b_reg;
    end
  end
 
  // Output assignment
  assign P = p_reg;
 
endmodule
