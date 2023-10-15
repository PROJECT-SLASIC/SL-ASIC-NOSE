`timescale 1ns / 1ps
module comparator #(parameter width=8)(
    input [7:0] exp1,
    input [7:0] exp2,
    output reg [7:0] dif,
    output reg [1:0] bigger
    );
    
    
    wire [width:0] result ;
    
     assign result = exp1 - exp2;
    always @(*) begin  
    //burada çıkarmanın sonucu negatifse twos complementini alıp sonuca veriyoruz
     if(result[width])begin
     dif=(~result)+1 ;
     // sonuç negatif çıktığı için exp2 > exp1 olduğunu belirtiyoruz
     bigger=2;
        end
    else if(result==0) begin
     bigger=0;
   end
   else begin
   // exp1 > exp2 olduğu durumda direkt devam knkkkk
    dif= result;
    bigger=1;
            
        end
    end
endmodule
