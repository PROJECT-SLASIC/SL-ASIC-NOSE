`timescale 1ns / 1ps
module IEEE754_adder #(parameter width=32)(
    input [width-1:0] input1,
    input [width-1:0] input2,
    output reg [width-1:0] out
    );
    
    wire sign;
    wire [1:0] select;
    wire [7:0] dif;
    comparator first(
     .exp1(input1[30:23]),
     .exp2(input2[30:23]),
     .dif(dif),
     .bigger(select)
    );
    reg [23:0] lead_input;
    wire [5:0] leading1;
    leading lead(
    .data(lead_input),
    .count(leading1) 
    );
    
    reg [7:0] exptemp;
    reg [24:0] temp1;
    reg [24:0] temp2;
    reg [24:0] sum;
    reg indc;
    
    assign sign = input1[width-1] ^ input2[width-1];
   always @(*) begin
 
   temp1={1'b0,1'b1,input1[22:0]};
   temp2={1'b0,1'b1,input2[22:0]};
           if(select==0) begin
           if(temp1==temp2 && sign)begin 
           out =0;
           end
           else begin
                indc=input1[width-1];
                exptemp= input1[30:23];
                     if(sign)begin
                        temp2= ~temp2+1; end
                     
                     sum = temp1 + temp2 ;
                     
                     if(sum[24]&& sign)begin
                        sum = ~sum+1;
                        indc=input2[width-1]; end 
                     
                     if(sign)begin
                        lead_input=sum[23:0];
                        sum= sum <<  leading1;
                        exptemp = exptemp - leading1; end
                            else begin
                                sum = sum >> 1;
                                exptemp= exptemp+1;  end
                         
                  out = {indc,exptemp,sum[22:0]};
           end
            end
           else if(select==1)begin   
           if(dif > 5'd23) begin
               out = input1;end
           else begin
                temp2= temp2 >> dif;
                exptemp= input1[30:23];
                    if(sign)begin 
                    sum = ~temp2+temp1+1;
                    lead_input=sum[23:0];
                    sum= sum <<  leading1;
                    exptemp = exptemp - leading1; end
                    else begin
                    sum = temp2 + temp1 ; end
                    if(sum[24])begin 
                    sum = sum >> 1;
                    exptemp= exptemp+1;
                    out = {1'b0,exptemp,sum[22:0]}; end
                       else begin     
                            out = {input1[width-1],exptemp,sum[22:0]};
                        end
            end
            
            end
            else if(select==2'd2) begin
            if(dif > 5'd23) begin
               out = input2;end
           else begin
                temp1= temp1 >> dif;
                exptemp= input2[30:23];
                if(sign)begin
                sum = temp2+~temp1+1;
                lead_input=sum[23:0];
                sum= sum <<  leading1;
                exptemp = exptemp - leading1;
                end
                else begin
                sum = temp2 + temp1 ;
                
                end
                if(sum[24])begin 
               sum = sum >> 1;
               exptemp= exptemp+1;
               out = {1'b0,exptemp,sum[22:0]};
               end
                   else begin     
                        out = {input2[width-1],exptemp,sum[22:0]};
                        
                    end
                end
        end 
   end
endmodule
