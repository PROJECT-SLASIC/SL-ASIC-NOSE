module adder#(parameter exponent=8, mantissa=23)(
    input [exponent+mantissa:0] input1,
    input [exponent+mantissa:0] input2,
    input clk,
    input rst,
    input strt,
    output reg valid,busy,
    output reg [exponent+mantissa:0] out
    );
   reg [1:0]state;
   reg strt_reg; 
   wire [exponent:0] dif1;
   wire [exponent+mantissa:0] outB1,outL1; 
   wire [exponent+mantissa:0] out_wire; 
   comparator first(
   .X(input1),
   .Y(input2),
   .dif(dif1),
   .outB(outB1),
   .outL(outL1)
    );
   wire sign;
   
   reg [exponent+mantissa:0] outB,outL; 
   reg [exponent:0] dif;

   assign sign =outB[exponent+mantissa] ^ outL[exponent+mantissa];
   
   wire [mantissa+1:0]shifted;
   assign shifted = ({1'b0,1'b1,outL[22:0]}) >> dif;
   
   wire [mantissa+1:0]shifted1; 
   assign shifted1 = sign ? ~shifted+1 : shifted;
   
   wire [mantissa+1:0] sum_mantissa2;
   assign sum_mantissa2 = shifted1+{2'b01,outB[22:0]};
   reg [mantissa+1:0] sum_mantissa ;

   always @(posedge clk or posedge rst) begin
 if(state==0) valid<=0;
if (rst)begin sum_mantissa <= 0; dif<=0;outB<=0; outL<=0;strt_reg<=0; state<=0; busy<=0; valid<=0; end


else if(strt_reg)begin 
case(state)
 0: begin dif<=dif1;outB<=outB1; outL<=outL1; busy<=1; state<=1; end
 
 1:begin sum_mantissa <= sum_mantissa2; state<=2; end
 
 2: begin out <= out_wire; strt_reg<=0; busy<=0; valid<=1; state<=0; end

endcase
 end
if(strt)begin strt_reg<=1; end
   end

   wire [4:0] count;
  leading find(
     .data(sum_mantissa[23:0]),
     .count(count)
     );
   wire [23:0] lead_shift;
   assign lead_shift = sum_mantissa << count;
   wire [mantissa+1:0] sum_mantissa1;
   wire control;
   assign control = sum_mantissa[mantissa+1] || dif==0;
   assign sum_mantissa1= control ? sum_mantissa>>1:sum_mantissa; 
   assign  out_wire[22:0] = sign ? lead_shift[22:0] : sum_mantissa1[22:0];
   
    wire [7:0]exp_inc;
    assign exp_inc= outB[30:23]+1;
    wire [7:0]exp_mux;
    assign exp_mux = control ? exp_inc :outB[30:23] ;
    assign out_wire[30:23] = sign ? exp_inc+~{3'd0,count} :exp_mux;
    assign out_wire[31] = outB[31];
endmodule

module leading(
    input [23:0] data,
    output reg [4:0] count
);

always @(*) begin
        if       (data[23]) count =  5'd0;
        else if  (data[22]) count =  5'd1;
        else if  (data[21]) count =  5'd2;
        else if  (data[20]) count =  5'd3;
        else if  (data[19]) count =  5'd4;
        else if  (data[18]) count =  5'd5;
        else if  (data[17]) count =  5'd6;
        else if  (data[16]) count =  5'd7;
        else if  (data[15]) count =  5'd8;
        else if  (data[14]) count =  5'd9;
        else if  (data[13]) count = 5'd10;
        else if  (data[12]) count = 5'd11;
        else if  (data[11]) count = 5'd12;
        else if  (data[10]) count = 5'd13;
        else if  (data[9])  count = 5'd14;
        else if  (data[8])  count = 5'd15;
        else if  (data[7])  count = 5'd16;
        else if  (data[6])  count = 5'd17;
        else if  (data[5])  count = 5'd18;
        else if  (data[4])  count = 5'd19;
        else if  (data[3])  count = 5'd20;
        else if  (data[2])  count = 5'd21;
        else if  (data[1])  count = 5'd22;
        else count = 5'd23;
    end
endmodule

module comparator #(parameter width=8)(
    input [31:0] X,
    input [31:0] Y,
    output [8:0] dif,
    output [31:0] outB,
    output [31:0] outL
    );
    wire [8:0] exp1,exp2;
    wire [23:0] mantis1,mantis2;
    wire [8:0] diffexp;
    wire [23:0] diffmantis;
    wire control;
    assign exp1 = {1'b0,X[30:23]};
    assign exp2 = {1'b0,Y[30:23]};
    assign mantis1 ={1'b0,X[22:0]};
    assign mantis2 ={1'b0,Y[22:0]};
    
    
    assign diffexp = exp1-exp2;
    assign diffmantis = mantis1-mantis2;
    assign control = (diffexp==0)&& diffmantis[23];
    
    assign outB = (diffexp[8]|| control) ? (Y) : (X);    
    assign outL = (diffexp[8]|| control) ? (X) : (Y);  
    assign dif  = (diffexp[8]) ?  (~diffexp+1):(diffexp)    ;

endmodule


