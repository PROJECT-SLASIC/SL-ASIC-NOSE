`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/13/2024 07:48:35 PM
// Design Name: 
// Module Name: 64bit_comparasor
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


module comparasor_64bit(
input [63:0] x1,x2,x3,x4,x5,
output [63:0] out1,out2,out3
                        );
wire [63:0] temp_out2,temp_out3;    
comparasor4_2  cmp[63:0](.caryin_i(x1),.input1_i(x2),.input2_i(x3),.input3_i(x4),.input4_i(x5),.sum_o(out1),.cary_o(temp_out2),.caryout_o(temp_out3));    
assign out2= temp_out2<<1;
assign out3= temp_out3<<1;
    
endmodule
