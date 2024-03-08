`timescale 1ns / 1ps
module adder_tb();
reg [32:0]control;
reg [31:0]temp_out;
reg error1;
reg [31:0]inputa [0:99999];
reg [31:0]inputb [0:99999];
reg [31:0]output1 [0:99999];

reg clk;
reg rst;
reg [31:0] input1,input2;
wire  [31:0] out;
reg strt;
wire busy,valid;
adder uut(
.input1(input1),
.input2(input2),
.clk(clk),
.rst(rst),
.start(strt),
.valid(valid),
.busy(busy),
.out(out)   
);

integer i ;
always begin
        #5 clk = ~clk;
    end
 
initial begin
     $readmemh("inputa.mem",inputa);
     $readmemh("inputb.mem",inputb);
     $readmemh("output.mem",output1);
        clk = 1'b0;
        rst = 1'b1;
        #10;
        rst = 1'b0;
        #10;

        for(i=0;i<10000;i=i+1)begin
   
        input1= inputa[i];
        input2= inputb[i];
        strt=1;
        #10;
        strt=0;
        wait(valid);
        temp_out=output1[i];
        control[32:0]= {1'b0,output1[i]} -{1'b0,out} ;
        error1= control[32] ? ((out - output1[i] )>32'd0 ):((output1[i]- out )>32'd0 ) ;
        #10;

   end
   $finish;

end
endmodule
