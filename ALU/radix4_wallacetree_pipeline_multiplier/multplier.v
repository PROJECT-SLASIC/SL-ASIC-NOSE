`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Slasic
// Engineer: Cimonk
// 
// Create Date: 02/11/2024 04:12:39 PM
// Design Name: Multplier
// Module Name: multplier
// Project Name: CPU
// Target Devices: nexys3 100T
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

module multplier#(parameter width=32)(
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
reg  [63:0]PartialProducts [0:15];    // all partial products that generated via radix4 decoder
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
    
// wallace tree adder  

reg  [63:0]pipeline1[0:9],pipeline2[0:5],pipeline3[0:3],pipeline4[0:9];
wire [63:0] comp1_out1,comp1_out2,comp1_out3;
comparasor_64bit  first1(.x1(PartialProducts[0]),.x2(PartialProducts[1]),.x3(PartialProducts[2]),.x4(PartialProducts[3]),.x5(PartialProducts[4]),.out1(comp1_out1),.out2(comp1_out2),.out3(comp1_out3));

wire [63:0] comp2_out1,comp2_out2,comp2_out3;
comparasor_64bit  first2(.x1(PartialProducts[5]),.x2(PartialProducts[6]),.x3(PartialProducts[7]),.x4(PartialProducts[8]),.x5(PartialProducts[9]),.out1(comp2_out1),.out2(comp2_out2),.out3(comp2_out3));

wire [63:0] comp3_out1,comp3_out2,comp3_out3;
comparasor_64bit  first3(.x1(PartialProducts[10]),.x2(PartialProducts[11]),.x3(PartialProducts[12]),.x4(PartialProducts[13]),.x5(PartialProducts[14]),.out1(comp3_out1),.out2(comp3_out2),.out3(comp3_out3));


wire [63:0] comp2_1_out1,comp2_1_out2,comp2_1_out3;
comparasor_64bit  second1(.x1(pipeline1[0]),.x2(pipeline1[1]),.x3(pipeline1[2]),.x4(pipeline1[3]),.x5(pipeline1[4]),.out1(comp2_1_out1),.out2(comp2_1_out2),.out3(comp2_1_out3));

wire [63:0] comp2_2_out1,comp2_2_out2,comp2_2_out3;
comparasor_64bit  second2(.x1(pipeline1[5]),.x2(pipeline1[6]),.x3(pipeline1[7]),.x4(pipeline1[8]),.x5(pipeline1[9]),.out1(comp2_2_out1),.out2(comp2_2_out2),.out3(comp2_2_out3));

wire [63:0] comp3_1_out1,comp3_1_out2,comp3_1_out3;
comparasor_64bit  third(.x1(pipeline2[0]),.x2(pipeline2[1]),.x3(pipeline2[2]),.x4(pipeline2[3]),.x5(pipeline2[4]),.out1(comp3_1_out1),.out2(comp3_1_out2),.out3(comp3_1_out3));


always @(posedge clk_i)begin
    if(rst_i)begin     
        pipeline1[0]<=0 ;
        pipeline1[1]<=0 ;
        pipeline1[2]<=0 ;
        pipeline1[3]<=0 ;
        pipeline1[4]<=0 ;
        pipeline1[5]<=0 ;             
        pipeline1[6]<=0 ;
        pipeline1[7]<=0 ;
        pipeline1[8]<=0 ;        
        pipeline1[9]<=0 ;       
        pipeline2[0]<=0 ;
        pipeline2[1]<=0 ;
        pipeline2[2]<=0 ;
        pipeline2[3]<=0 ;
        pipeline2[4]<=0 ;
        pipeline2[5]<=0 ;     
        pipeline3[0]<=0 ;
        pipeline3[1]<=0 ;
        pipeline3[2]<=0 ;
        pipeline3[3]<=0 ;
    end
    else begin
        pipeline1[0]<= comp1_out1;
        pipeline1[1]<= comp1_out2;
        pipeline1[2]<= comp1_out3;
        
        pipeline1[3]<= comp2_out1;
        pipeline1[4]<= comp2_out2;
        pipeline1[5]<= comp2_out3;
        
        pipeline1[6]<= comp3_out1;
        pipeline1[7]<=comp3_out2;
        pipeline1[8]<=comp3_out3;
        
        pipeline1[9]<=PartialProducts[15];
        
        pipeline2[0]<=comp2_1_out1;
        pipeline2[1]<=comp2_1_out2;
        pipeline2[2]<=comp2_1_out3;
        pipeline2[3]<=comp2_2_out1;
        pipeline2[4]<=comp2_2_out2;
        pipeline2[5]<=comp2_2_out3;
        
        pipeline3[0]<=comp3_1_out1;
        pipeline3[1]<=comp3_1_out2;
        pipeline3[2]<=comp3_1_out3;
        pipeline3[3]<=pipeline2[5];
        
        
    end
end 
    
    
    
endmodule




