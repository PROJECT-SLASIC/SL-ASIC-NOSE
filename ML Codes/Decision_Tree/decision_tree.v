module decision_tree(
    input clk,
    input rst,
    input start,
    input [9:0]switch,
    input  [31:0] feature0,
    input  [31:0] feature1,
    input  [31:0] feature2,
    input  [31:0] feature3,
    input  [31:0] feature4,
    output reg [2:0] class,
    output reg busy,valid
    );
    
    
 
    wire [31:0] adder_input1,adder_input2;
    reg adder_start;
    wire adder_busy,adder_valid;
    wire adder_out;

 
reg [31:0] subs1,subs2;
wire [31:0] temp1,temp2,result;
wire control;
reg start_reg;
assign temp1={1'b0,subs1[30:0]};
assign temp2={1'b0,subs2[30:0]};
assign result = temp1-temp2;
assign control= ~result[31];
reg debounce;
 reg[3:0] state ;
 always @(posedge clk)begin
 
    if (rst) begin
    start_reg<=0;
    state<=0;
    class<=0;
    subs1<=0;
    subs2<=0;
    busy<=0;
    valid<=0;
    debounce<=0;
    end
 
    else begin
        if(start && ~debounce )begin start_reg<=1; debounce<=1; end
        if(~start)begin debounce<=0; end
        if(valid)valid<=0;
    
        if(start_reg || start)begin
        case(state)
            0:begin             
                    busy<=1;
                    subs1<=feature2;
                    subs2<=32'h3f000001;
                    state<=1;
                
            end
            1:begin
                if(control)begin
                    state<=0;
                    class<=0;
                    valid<=1;
                    busy<=0;
                    start_reg<=0;
                end
                else begin
                    state<=2;
                    subs1<=feature1;
                    subs2<=32'h3f2e147c;
                end
            end
            2:begin
                if(control)begin
                    state<=0;
                    class<=4;
                    valid<=1;
                    busy<=0;
                    start_reg<=0;
                end
                else begin
                    state<=3;
                    subs1<=feature0;
                    subs2<=32'h3d75c290;
                end
            end
            3:begin
                if(control)begin
                    state<=5;
                    subs1<=feature4;
                    subs2<=32'h3e051eb9;
                end
                else begin
                    state<=4;
                    subs1<=feature1;
                    subs2<=32'h3da3d70b;
                end
            end
            4:begin
                state<=0;
                valid<=1;
                busy<=0;
                start_reg<=0;
                if(control)begin
                     class<=1;
                end
                else begin
                     class<=5;
                end
            end
            
            5:begin
                state<=0;
                valid<=1;
                busy<=0;
                start_reg<=0;
                if(control)begin           
                    class<=3;
                end
                else begin
                    class<=2;
                end
            end
        endcase
    end
    end
end
endmodule
