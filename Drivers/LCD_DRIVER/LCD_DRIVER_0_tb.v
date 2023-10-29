`timescale 1ns / 1ps
module LCD_DRIVER_0_tb();

    reg clk_tb;
    reg rst_tb;
    reg start_lcd_tb;
    wire scl_tb;         //
    wire sda_tb;         //
    
    LCD_DRIVER_0 DUT(
        . clk(clk_tb),
        . rst(rst_tb),
        . start_lcd(start_lcd_tb),
        . scl(scl_tb),         //
        . sda(sda_tb)           //
    );
    
    always begin
        #5 clk_tb = ~clk_tb;
    end
    
    initial begin
        clk_tb = 1'b0;
        rst_tb = 1'b0;
        start_lcd_tb = 1'b0;
        
        #10;
        rst_tb = 1'b1;
        #10;
        rst_tb = 1'b0;
        
        #50;
        
        start_lcd_tb = 1'b1;
//        #500;
//        start_lcd_tb = 1'b0;
        
//        #100000000;
//        start_lcd_tb = 1'b1;
//        #500;
//        start_lcd_tb = 1'b0;
//        start_lcd_tb = 1'b1;
//        #430000;
        
//        start_lcd_tb = 1'b1;
//        #20;
//        start_lcd_tb = 1'b1;
        
    end
    
    
    
endmodule
