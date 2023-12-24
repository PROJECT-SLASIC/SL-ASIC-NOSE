module demo
(
    input clk,              // E4 
    input rst,              // SW15
    input start,
    input enable,           // SW14
    output done,            // 
     
    input [9:0] switch_i,   // SW9-SW0    // kalkacak
    
    inout sda,              // JA1
    output scl,             // JA2
    
    input [31:0] voc1,
    input [31:0] voc2,
    input [31:0] voc3,
    input [31:0] voc4,
    input [31:0] voc5,
    
    output [2:0] decision 
);
    wire dm_valid;
    wire dm_busy;
    wire div_clk_top;
        
    divided_clock SLOW_CLOCK
	(
        .clk(clk),
        .rst(rst),
        .div_clk(div_clk_top)
    );
    
    decision_making DECISION_MAKING
	(
        .clk(div_clk_top),
        .rst(rst),
        .start(start),
        .busy(dm_busy),
        .valid(dm_valid),
        
        .input1(voc1),
        .input2(voc2),
        .input3(voc3),
        .input4(voc4),
        .input5(voc5),
        
        .class(decision)          // asl?nda genel output olarak tam?nlanmas? beklenen decision signal
    );
    
    lcd_driver LCD
	(
        .clk(div_clk_top),          
        .rst(rst),         
        .start_lcd(valid_top && !busy_top),   
        .selective(class),
       
        .scl(scl),        
        .sda(sda) 
    );

endmodule
