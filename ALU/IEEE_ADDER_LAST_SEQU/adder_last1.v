module adder#(parameter exponent=8, mantissa=23)(
    input [exponent+mantissa:0] input1,
    input [exponent+mantissa:0] input2,
    input clk,
    input rst,
    output [exponent+mantissa:0] out
    );
    
   wire [exponent:0] dif;
   wire [exponent+mantissa:0] outB,outL; 
    
   comparator first(
   .X(input1),
   .Y(input2),
   .dif(dif),
   .outB(outB),
   .outL(outL)
    );
   wire sign;
   
   assign sign =outB[exponent+mantissa] ^ outL[exponent+mantissa];
   
   wire [mantissa+1:0]shifted;
   assign shifted = ({1'b0,1'b1,outL[22:0]}) >> dif;
   
   wire [mantissa+1:0]shifted1; 
   assign shifted1 = sign ? ~shifted+1 : shifted;
   
   wire [mantissa+1:0] sum_mantissa2;
   assign sum_mantissa2 = shifted1+{2'b01,outB[22:0]};
   reg [mantissa+1:0] sum_mantissa ;

   always @(posedge clk or posedge rst) begin
if (rst) sum_mantissa <= 0;
else sum_mantissa <= sum_mantissa2;
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
   assign control = sum_mantissa[mantissa+1] || ((dif==0)&& ~sign);
   assign sum_mantissa1= control ? sum_mantissa>>1:sum_mantissa; 
   assign  out[22:0] = sign ? lead_shift[22:0] : sum_mantissa1[22:0];
   
    wire [7:0]exp_inc;
    assign exp_inc= outB[30:23]+1;
    wire [7:0]exp_mux;
    assign exp_mux = sign ? outB[30:23]-count :outB[30:23] ;
    assign out[30:23] = control ? exp_inc:exp_mux;
    assign out[31] = outB[31];
endmodule
