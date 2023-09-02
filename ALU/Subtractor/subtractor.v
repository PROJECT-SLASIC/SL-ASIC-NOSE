`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.09.2023 14:17:08
// Design Name: 
// Module Name: subtractor
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

module subtractor_32bit_with_carry(
    input wire [31:0] A, B,
    input wire borrow_in,
    input wire clk,
    input wire rst,
    output reg [31:0] difference,
    output reg borrow_out
);

reg [32:0] temp_difference;

always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        difference <= 32'b0;
        borrow_out <= 1'b0;
    end
    else
    begin
        temp_difference = {borrow_in, A} - {1'b0, B};
        difference <= temp_difference[31:0];
        borrow_out <= ~temp_difference[32];
    end
end

endmodule
