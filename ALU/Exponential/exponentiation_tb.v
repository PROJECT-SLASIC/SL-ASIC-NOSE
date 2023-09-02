`timescale 1ns / 1ps

module exponentiation_tb();
    
    reg clk_tb;
    reg rst_tb; 
    reg start_tb;
    reg [31:0] exp_tb;
    wire [31:0] result_tb;
    wire valid_tb;
    wire busy_tb;
    
    exponentiation Dut(
        . clk(clk_tb), 
        . rst(rst_tb), 
        . start(start_tb),
        . exp(exp_tb),
        . result(result_tb),
        . valid(valid_tb),
        . busy(busy_tb)
    );
    
    always begin
        #5 clk_tb = ~clk_tb;
    end
    
    initial begin
        clk_tb = 1'b0;
        rst_tb = 1'b0;
        start_tb = 1'b0;
        exp_tb = 32'b0;
        
        #10;
        rst_tb = 1'b1;        
        #10;
        rst_tb = 1'b0;
        #15;
        
        start_tb = 1'b1;
        exp_tb = 5;
        #10;
        start_tb = 1'b0;
        #1500;
        
        
        
        start_tb = 1'b1;
        exp_tb = 3;
        #10;
        start_tb = 1'b0;
        #1500;
        
    end
    
endmodule
