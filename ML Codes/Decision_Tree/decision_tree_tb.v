`timescale 1ns / 1ps
module tree_tb( );
integer i;
reg error;
reg clk,rst,start;
reg [31:0] feature0,feature1,feature2,feature3,feature4;
reg [31:0] feature0_mem[0:665],feature1_mem[0:665],feature2_mem[0:665],feature3_mem[0:665],feature4_mem[0:665];
reg[2:0] label_mem [0:665];
wire [2:0] class;
wire busy,valid;
decision_tree uut(
     .clk(clk),
     .rst(rst),
     .start(start),
     .feature0(feature0),
     .feature1(feature1),
     .feature2(feature2),
     .feature3(feature3),
     .feature4(feature4),
     .class(class),
     .busy(busy),
     .valid(valid)
    );

always begin
#5 clk=~clk;
end


initial begin

$readmemh("feature0.mem",feature0_mem);
$readmemh("feature1.mem",feature1_mem);
$readmemh("feature2.mem",feature2_mem);
$readmemh("feature3.mem",feature3_mem);
$readmemh("feature4.mem",feature4_mem);
$readmemh("label.mem",label_mem);


clk=0;
rst=0;
#10;
rst=1;
#10
rst=0;

for (i=0;i<665 ; i=i+1)begin
start=1;
feature0=feature0_mem[i];
feature1=feature1_mem[i];
feature2=feature2_mem[i];
feature3=feature3_mem[i];
feature4=feature4_mem[i];
#10
start=0;
wait(valid);
error=(class-label_mem[i])? 1 : 0 ;
#10;

end



end



endmodule
