module divider_tb( );
reg [31:0]temp_out;
reg error1;
reg [31:0]inputa [0:99999];
reg [31:0]inputb [0:99999];
reg [31:0]output1 [0:99999];
reg clk,rst,start;
reg[31:0] dividened,divisor;
wire [31:0] out;
wire busy,valid;
IEEE_divider uut(
.clk(clk),
.rst(rst),
.start(start),
.dividened(dividened) ,
.divisor(divisor),
.valid(valid),
.busy(busy),
.out_reg(out)
    );
    
 integer i;   
   always begin
   clk=~clk;
   #5;
   end 
   
   initial begin
   $readmemh("inputa.mem",inputa);
   $readmemh("inputb.mem",inputb);
   $readmemh("output.mem",output1);
   
   clk=0;
   rst=0;
   #10
   rst=1;
   #10;
   rst=0;
   #10;
   
   for(i=0;i<100000;i=i+1)begin
   
        dividened= inputa[i];
        divisor= inputb[i];
        start=1;
        #10;
        start=0;
        wait(valid);
        temp_out=output1[i];
        error1= ~(out[31:12]== output1[i][31:12]);
        #10;

   end
   $finish;
//   dividened= 32'h461fd000;
//   divisor= 32'h453d4f12;
//   start=1;
//   #10;
//   start=0;
//   wait(valid);
//   #10;
//   dividened= 32'h443c8000;
//   divisor= 32'h46188800;  
//    start=1;
//   #10;
//   start=0;     
    end
endmodule
