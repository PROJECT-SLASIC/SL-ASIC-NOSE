`timescale 1ns / 1ps
module DEMO_tb();

    reg clk_tb;  // e4 clock
    reg rst_tb;  // sw 15
    reg start_signal_tb; // sw14
    reg [9:0] switch_i_tb; // sw9-sw0
    wire sda_tb;  // ja1
    wire scl_tb;  // ja2
    
    DEMO DUT(
        . clk(clk_tb),  // e4 clock
        . rst(rst_tb),  // sw 15
        . start_signal(start_signal_tb), // sw14
        . switch_i(switch_i_tb), // sw9-sw0
        . sda(sda_tb),  // ja1
        . scl(scl_tb)  // ja2
    );
    
    always begin
        #10 clk_tb = ~clk_tb;
    end
    
    
    initial begin
        clk_tb = 1'b0;
        rst_tb = 1'b0;
        start_signal_tb = 1'b0;
        switch_i_tb = 10'b0;
        
        
        #20;
        rst_tb = 1'b1;
        #20;
        rst_tb = 1'b0;
        
        #100;
        ///////
        start_signal_tb = 1'b1;
        switch_i_tb = 10'd127;
        
        #60;
        
        start_signal_tb = 1'b0;
        
        
    end
endmodule
