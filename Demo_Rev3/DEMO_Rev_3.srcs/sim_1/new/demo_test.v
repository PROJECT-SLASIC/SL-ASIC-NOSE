`timescale 1ns / 1ps
module demo_test();

reg clk,rst,start;
wire done,busy;
reg [31:0] voc1,voc2,voc3,voc4,voc5;
reg method_slct;
demo demo1(
    .clk(clk),              // E4 
    .rst(rst),              // SW15
    .start(start), //input enable,           // SW14
    .done(done),            // 
    .busy(busy),
    .method_select(method_slct),
    .sda_1(),
    .scl_1(),
    .voc1(voc1),
    .voc2(voc2),
    .voc3(voc3),
    .voc4(voc4),
    .voc5(voc5)
); 

always begin
#5 clk=~clk;
end
initial begin
rst=0;
clk=1;
#50
rst=1;
#20
rst=0;
#10
method_slct=0;
start=1;
voc1=32'h333333;
voc2=32'h333333;
voc3=32'h333333;
voc4=32'h333333;
voc5=32'h333333;
#10
start=0;


end


   
    
endmodule
