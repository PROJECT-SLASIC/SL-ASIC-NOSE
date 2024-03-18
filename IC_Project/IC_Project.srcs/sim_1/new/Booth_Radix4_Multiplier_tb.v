`timescale 1ns / 1ps
module Booth_Radix4_Multiplier_tb();
    parameter WIDTH = 32;

    reg clk_tb;
    reg rst_tb;
    reg [WIDTH-1:0] rs1_tb;
    reg [WIDTH-1:0] rs2_tb;
    reg start_tb;
    wire [2*WIDTH-1:0] result_tb;
    wire valid_tb;
    wire busy_tb;
    
    
    reg [63:0]temp_out;
    reg error;
    reg [31:0]rs1 [0:9999];
    reg [31:0]rs2 [0:9999];
    reg [63:0]result [0:9999];
    reg [63:0] control;
    integer i;

    // Instantiate the Unit Under Test (UUT)
    Booth_Radix4_Multiplier #(WIDTH) uut (
        .clk(clk_tb),
        .rst(rst_tb),
        .rs1(rs1_tb),
        .rs2(rs2_tb),
        .start(start_tb),
        .result(result_tb),
        .valid(valid_tb),
        .busy(busy_tb)
    );
        
    // Clock generation
    always begin
        #5 clk_tb = ~clk_tb;
    end

    initial begin
       $readmemh("rs1.mem",rs1);
       $readmemh("rs2.mem",rs2);
       $readmemh("result.mem",result);
        
        clk_tb = 1'b1;
        rst_tb = 1'b1;
        #10;
        rst_tb = 1'b0;
        #10;
        
        for(i=0;i<10000;i=i+1)begin
            rs1_tb= rs1[i];
            rs2_tb= rs2[i];
            start_tb=1;
            #10;
            start_tb=0;
            wait(valid_tb);
            temp_out=result[i];
            control[63:0]= {1'b0,result[i]} -{1'b0,result_tb} ;
            error= control[63] ? ((result_tb - result[i] )>32'd2 ):((result[i]- result_tb )>64'd0 ) ;
            #10;
       end
       $finish;
    end
endmodule
