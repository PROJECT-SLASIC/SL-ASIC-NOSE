`timescale 1ns / 1ps
module comparator #(parameter width=8)(
    input [31:0] X,
    input [31:0] Y,
    output [8:0] dif,
    output [31:0] outB,
    output [31:0] outL
    );
    wire [8:0] exp1,exp2;
    wire [8:0] diffexp;
    
    assign exp1 = {1'b0,X[30:23]};
    assign exp2 = {1'b0,Y[30:23]};
    
    assign diffexp = exp1-exp2;
    
    assign outB = (diffexp[8]) ? (Y) : (X);    
    assign outL = (diffexp[8]) ? (X) : (Y);  
    assign dif  = (diffexp[8]) ?  (~diffexp+1):(diffexp)    ;
    
    
    
endmodule
