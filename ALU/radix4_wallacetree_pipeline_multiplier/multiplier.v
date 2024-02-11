`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/11/2024 04:12:39 PM
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


module multiplier#(parameter width=32)(
input [width-1:0]rs1_i,
input [width-1:0]rs2_i,
input clk_i,
input rst_i,
input start_i,

output [2*width-1:0]result_o,
output busy,
output valid
    );
    
    
wire [32:0]radix4_decoder = {rs1_i,1'b0};   
reg  [63:0]PartialProducts [0:16];    // all partial products that generated via radix4 decoder
wire [32:0] rs2_2scomp = ~{1'b0,rs2_i} +1;
reg [63:0]temprs2;

// radix 4 booth decode stage    
genvar k;    
generate
    for(k=0 ;k<16; k=k+1)begin
        always @(*)begin
            if(rs2_2scomp[32])
                temprs2={32'hffffffff,rs2_2scomp};
            else
                temprs2={32'b0,rs2_2scomp};
            case(radix4_decoder[2+2*k:2*k])
                3'b000:begin
                    PartialProducts[k]=32'b0;
                end
                3'b001:begin
                    PartialProducts[k]=rs2_i<<2*k;
                end
                3'b010:begin
                    PartialProducts[k]=rs2_i<<2*k;
                end
                3'b011:begin
                    PartialProducts[k]=rs2_i<<2*k+1;
                end
                3'b100:begin
                    PartialProducts[k]=temprs2<<2*k+1;
                end
                3'b101:begin
                    PartialProducts[k]=temprs2<<2*k;
                end
                3'b110:begin
                    PartialProducts[k]=temprs2<<2*k;
                end
                3'b111:begin
                    PartialProducts[k]=32'b0;
                end
            endcase

        end  
    
    end
    endgenerate
   
  
    
    
    
    
    
    
endmodule
