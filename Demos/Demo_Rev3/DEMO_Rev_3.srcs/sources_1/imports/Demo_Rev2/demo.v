module demo
(
    input clk,              // E4 
    input rst,              // SW15
    input start,
    //input enable,           // SW14
    output done,            // 
    output busy,
    input method_select,
    
    inout sda_1,
    output scl_1,
    
    input [31:0] voc1,
    input [31:0] voc2,
    input [31:0] voc3,
    input [31:0] voc4,
    input [31:0] voc5
    
    //output [2:0] decision
);
    assign done = dm_valid;
    assign busy = dm_busy;
    //assign decision = decision_top;
    
    wire dm_valid;
    wire dm_busy;
    wire div_clk_top;
    wire [2:0] decision_top;
        
    divided_clock SLOW_CLOCK
	(
        .clk(clk),
        .rst(rst),
        .div_clk(div_clk_top)
    );
    
    decision_making DECISION_MAKING
	(
        .clk(clk),
        .rst(rst),
        .start(start),
        .busy(dm_busy),
        .valid(dm_valid),
        
        .method_select(method_select),
        
        .input1(voc1),
        .input2(voc2),
        .input3(voc3),
        .input4(voc4),
        .input5(voc5),
        
        .class(decision_top)
    );
    
    lcd_driver LCD
	(
        .clk(div_clk_top),          
        .rst(rst),         
        .start_lcd(dm_valid && !dm_busy),   
        .selective(decision_top),
       
        .scl(scl_1),        
        .sda(sda_1) 
    );
    

endmodule
