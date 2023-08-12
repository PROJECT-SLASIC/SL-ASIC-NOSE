`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: Hacettepe University
// Engineer: Cengizhan Caglayan
// 
// Create Date: 07.08.2023 10:19:14
// Design Name: Carry Look Away Adder / Subtractor Design Prototype
// Module Name: CLA_32bit_improved
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

module CLA_32bit_improved(
    input [31:0] A, B,
    input Cin, sub, signed_op,
    output [31:0] Sum,
    output Cout, overflow
);

    wire [31:0] B_final;
    wire [31:0] G, P, C;
    genvar i;

    // Determine B based on operation: 
    // If subtraction is selected, use two's complement method for B.
    assign B_final = sub ? (~B + 1'b1) : B;

    // Generate and Propagate signals
    assign G = A & B_final;
    assign P = A ^ B_final;

    // Carry signals
    assign C[0] = G[0] | (P[0] & Cin);
    for (i = 1; i < 32; i = i + 1) begin
        assign C[i] = G[i] | (P[i] & C[i - 1]);
    end

    // Sum outputs
    assign Sum[0] = P[0] ^ Cin;
    for (i = 1; i < 32; i = i + 1) begin
        assign Sum[i] = P[i] ^ C[i - 1];
    end

    // Determine Cout and Overflow based on operation mode
    assign Cout = C[31];  // Carry out is straightforwardly the last carry for both addition and subtraction
    assign overflow = (signed_op & sub) ? (Sum[31] ^ A[31]) & (Sum[31] ^ B[31]) : (signed_op & ~sub) ? (Sum[31] ^ A[31]) & (~Sum[31] ^ B[31]) : 0;

endmodule
