`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.09.2023 14:17:08
// Design Name: 
// Module Name: adder
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

module adder_32bit_with_carry(
    input wire [31:0] A, B,
    input wire carry_in,
    input wire clk,
    input wire rst,
    output reg [31:0] sum,
    output reg carry_out
);

reg [32:0] temp_sum;

always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        sum <= 32'b0;
        carry_out <= 1'b0;
    end
    else
    begin
        temp_sum = {carry_in, A} + {1'b0, B};
        sum <= temp_sum[31:0];
        carry_out <= temp_sum[32];
    end
end

endmodule

            Cout <= 0;
            overflow <= 0;
        end else begin
            // Sum outputs
            Sum[0] <= P[0] ^ Cin;
            //... [and so on for other bits]

            // Determine Cout and Overflow based on operation mode
            Cout <= C[31];
            overflow <= (signed_op & sub) ? (Sum[31] ^ A[31]) & (Sum[31] ^ B[31]) : (signed_op & ~sub) ? (Sum[31] ^ A[31]) & (~Sum[31] ^ B[31]) : 0;
        end
    end

endmodule
