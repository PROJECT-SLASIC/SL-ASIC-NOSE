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
 
if (rst)begin sum_mantissa <= 0; dif<=0;outB<=0; outL<=0;strt_reg<=0; state<=0; busy<=0; valid<=0; end


else begin
if(state==0) begin valid<=0; end
if(strt)begin strt_reg<=1; end
if(strt_reg)begin 
case(state)
 0: begin dif<=dif1;outB<=outB1; outL<=outL1; busy<=1; state<=1; end
 
 1:begin sum_mantissa <= sum_mantissa2; state<=2; end
 
 2: begin out <= out_wire; strt_reg<=0; busy<=0; valid<=1; state<=0; end

endcase
 end
 end
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
