module adder_tb();
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
.strt(strt),
.valid(valid),
.busy(busy),
.out(out)   
);
always begin
        #5 clk = ~clk;
    end
 
initial begin
        clk = 1'b0;
        rst = 1'b1;
        #10;
        rst = 1'b0;
        strt=1;
input1=32'hc44d5d0e; //-821.454
input2=32'h44813a7f; //1033.828
#10
strt=0;
#40
strt=1;
input1=32'h44454000; //789
input2=32'hc423c000; //-655
#10
strt=0;
#40
strt=1;
input2=32'h44454000; //789
input1=32'hc423c000; //-655
#10
strt=0;
#40
strt=1;
input1=32'h440df8f6; //567.89
input2=32'h442c8000; //690
#10
strt=0;


end
endmodule
