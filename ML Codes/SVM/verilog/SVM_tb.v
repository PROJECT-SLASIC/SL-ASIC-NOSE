module SVM_tb();

reg clk, rst;
reg [31:0] i0, i1, i2, i3, i4, temp;
wire [31:0] predict;

SVM uut(
    .clk(clk),
    .rst(rst),
    .i0(i0),
    .i1(i1),
    .i2(i2),
    .i3(i3),
    .i4(i4),
    .temp(temp),
    .predict(predict)
);

initial begin
    clk = 0;
    forever clk = ~clk;
    #10
end

initial begin
    rst = 1;
    #20
    rst = 0;
end

initial begin 
    i0 = 32'h41163e7c;
    i1 = 32'h402da481;			//2
    i2 = 32'h3ee2e70c;
    i3 = 32'h3f6f4e32;
    i4 = 32'h40f91bf0;
    temp = 32'h42c6afb6;
    #100
    i0 = 32'h41b7f93a;				//3	
    i1 = 32'h41a61e00;			
    i2 = 32'h4155af52;
    i3 = 32'h41871caa;
    i4 = 32'h41f96311;
    temp = 32'h424703c9;

end

endmodule