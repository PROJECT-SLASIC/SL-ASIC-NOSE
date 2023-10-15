`timescale 1ns / 1ps

module adder_tb();

reg [31:0] input1,input2;
wire [31:0] out;


IEEE754_adder uut(
     .input1(input1),
     .input2(input2),
     .out(out)
    );

initial begin 

#10
input1= 32'H41200000;
input2= 32'H40c00000;
#10
 input1= 32'H41f80000;
 input2= 32'H41700000;
#10
 input2= 32'H41f80000;
 input1= 32'H41700000;
 #10
 input1= 32'H445d48f6;
 input2= 32'H41be28f6;
 #10
 input1= 32'H40a9999a;
 input2= 32'H42740000;
 #10
 input1= 32'H40e00000;
 input2= 32'H40c00000;
 #10
 input1= 32'H41200000;
 input2= 32'Hc0800000;
 #10
 input1= 32'H4420e99a;
 input2= 32'Hc22e999a;
  #10
 input1= 32'H4420e99a;
 input2= 32'Hc22e999a;
  #10
 input1= 32'Hc0d820c5;
 input2= 32'H3ff28f5c;
 #10
 input1= 32'H42fe0000;
 input2= 32'H42fe0000;
#10
 input1= 32'H47f12065;
 input2= 32'Hc5b7bd46;
 #10
 input1= 32'H420c0000;
 input2= 32'H00000000;
  #10
 input1= 32'H3f800000;
 input2= 32'Hbf800000;



end

endmodule
