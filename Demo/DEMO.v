module DEMO(
    input clk,  // e4 clock
    input rst,  // sw 15
    input start_signal, // sw14
    input [9:0] switch_i, // sw9-sw0    // kalkacak
    inout sda,  // ja1
    output scl  // ja2
                // 4 *32 bit signal girecek i2c data_1 
                // decision, 3 bit 
                // i2c register write 1 clock cycle olsun yeterli - done signal 
                
    );
    
    wire [2:0] class;
    wire valid_top;
    wire busy_top;
    wire div_clk_top;
    total Algorithm(
        . switch(switch_i),
        . start(start_signal),
        . clk(div_clk_top),
        . rst(rst),
        . valid(valid_top),
        . busy(busy_top),
        . class(class)          // asl?nda genel output olarak tam?nlanmas? beklenen decision signal
    );
    
    LCD_DRIVER_0 LCD(   // kals?n
        . clk(div_clk_top),          
        . rst(rst),         
        . start_lcd(valid_top && !busy_top),   
        . selective(class),
        
        . scl(scl),        
        . sda(sda) 
    );
    
    Divided_Clock Slow_Clock(       // kals?n    
        . clk(clk),
        . rst(rst),
        . div_clk(div_clk_top)
    );
endmodule
