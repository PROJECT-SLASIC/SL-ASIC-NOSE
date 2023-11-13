module feed_forward_tb();

reg clk,rst,load,start;
reg [31:0] data;
wire oldu;
wire [31:0] data_out;
reg [3:0] first,second,third,fourth;
feed_forward uut(
    .clk(clk),
    .rst(rst),
    .data(data),
    .load(load),
    .start(start),
    .first_layer(first),
    .second_layer(second),
    .third_layer(third),
    .fourth_layer(fourth),
    .oldu(oldu)
    );
 reg [31:0] dosya [0:127];   
  reg [7:0] i ;
    
    always begin 
    #5 clk = ~clk;
    end

    initial begin
    clk=0;
    $readmemh("dosya.mem",dosya);  
    #10
    rst =1 ;
    #10
    rst=0;
    #10
    first=4;
    second=6;
    third=5;
    fourth=3;
    load=1;
    #10
    load=0;
    for(i=0;i<92;i=i+1)begin
    data= dosya[i];
    #10;
    end
    
    
    #10
    start=1;
    #10
    start=0;
   
   


    end


endmodule
