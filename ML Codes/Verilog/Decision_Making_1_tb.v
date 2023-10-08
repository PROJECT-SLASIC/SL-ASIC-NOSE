`timescale 1ns / 1ps
module Decision_Making_1_tb();
    parameter width = 32;
    parameter shift = 4;
    reg clk_tb;
    reg rst_tb;  // sw15 rst
    reg start_i_tb;    // sw14 start
    reg [11:0] switch_for_data_tb;    // sw11 - sw0 for input arrangment
    wire [2:0] led_tb; // 100 for led 15 filter coffee, 010 for led 14 air, 001 for led 13 espresso
    
    Decision_Making_1 DUT(
        . clk(clk_tb),
        . rst(rst_tb),  // sw15 rst
        . start_i(start_i_tb),    // sw14 start
        . switch_for_data(switch_for_data_tb),    // sw11 - sw0 for input arrangment
        . led(led_tb) // 100 for led 15 filter coffee, 010 for led 14 air, 001 for led 13 espresso
    );
    
    reg [9:0] i=0;
    
    always begin
        #5 clk_tb = ~clk_tb;
    end
    
    initial begin
        clk_tb = 1'b0;
        rst_tb = 1'b0;
        start_i_tb = 1'b0;
        switch_for_data_tb = 12'b0;
        
        #10;
        rst_tb = 1'b1;
        #10;
        rst_tb = 1'b0;
        
        //Test Case: All
        for (i=0; i<461; i = i +1)begin
            switch_for_data_tb = i;
            start_i_tb = 1'b1;
            #30;
            start_i_tb = 1'b0;
            #1000;                  // bunu bitmesine göre ayarla
        end 
    end
endmodule
