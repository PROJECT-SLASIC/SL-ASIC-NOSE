`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: Hacettepe University   
// Engineer: Cengizhan Caglayan
// 
// Create Date: 07.08.2023 10:19:14
// Design Name: Logic Unit Design Prototype
// Module Name: LogicUnit
// Project Name: SLASIC
// Target Devices: 
// Tool Versions: 
// Description: Prototype
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module LogicUnit (
    input [31:0] A, B,                // Two 32-bit inputs
    input [5:0] sel,                  // 6-bit select input
    output reg [31:0] out             // 32-bit output
);

always @(A, B, sel) begin
    case(sel)
        6'b000001: out = ~A;         // NOT operation on A
        6'b000010: out = A | B;      // OR operation
        6'b000011: out = A & B;      // AND operation
        6'b000100: out = ~(A | B);   // NOR operation
        6'b000101: out = ~(A & B);   // NAND operation
        6'b000110: out = A ^ B;      // XOR operation
        default: out = 32'b0;        // Default output is 0 for all other select values
    endcase
end

endmodule
