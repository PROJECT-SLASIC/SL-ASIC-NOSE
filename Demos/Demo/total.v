module total(       // decision tree        // input selecter, mlp mi çal??cak decision tree , ikisi birden mi çal??cak 
input [9:0] switch,                         // 
input start,
input clk,
input rst,
output reg valid,busy,
output reg [2:0]class
    );

reg start_mlp;
reg start_reg;    
reg internal_rst;  
wire total_reset;

assign total_reset = rst || internal_rst;  
    wire load_neuron;
    wire [31:0] datas;
    wire paralel_busy,paralel_valid;
    reg start_paralel;
    
    Parallel_to_Serial trans(       // kalkacak
    .clk(clk),
    .rst(rst),
    .start(start_paralel),
    .switch(switch),
    .load_neuron(load_neuron),
    .busy(paralel_busy),
    .valid(paralel_valid),
    .serial_o(datas)
    );
    
    wire mlp_valid,mlp_busy;
    wire [2:0]mlp_class;
    feed_forward Mlp(
    .clk(clk),
    .rst(rst),
    .data(datas),
    .load_neuron(load_neuron),
    .start(start_mlp),
    .first_layer(4'd5),
    .second_layer(4'd15),
    .third_layer(4'd8),
    .fourth_layer(4'd6),
    .oldu(),
    .class(mlp_class),
    .busy(mlp_busy),
    .valid(mlp_valid)
    );
   reg [3:0]steps;
   reg a;
   always @(posedge clk)begin
   if(rst)begin
   steps<=0;
   a<=0;
   start_paralel<=0;
   start_mlp<=0;
   start_reg<=0;
   busy<=0;
   valid<=0;
   end
   
   else begin
            if(valid)valid<=0;
            if(start&&~a)begin start_reg<=1; a<=1;end
            if(~start&&a)begin a<=0;end
            if(start_reg)begin 
            
                case(steps)
                   0:begin 
                    start_paralel<=1;
                    steps<=1;
                    busy<=1;
                    end
                   1:begin
                   start_paralel<=0;
                    if(paralel_valid)begin
                    steps<=2;
                    
                    end
                   
                   end
                   
                   
                   2:begin
                    start_mlp<=1;
                    steps<=3;
                   end
                   
                   
                   3:begin
                   start_mlp<=0;
                   if(mlp_valid)begin
                    valid<=1;
                    busy<=0;
                    start_reg<=0;
                    steps<=0;
                    class<=mlp_class;
                    end
                   end
                endcase
            end
   end
   end 
endmodule
