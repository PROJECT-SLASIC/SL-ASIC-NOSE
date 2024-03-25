module Ripple_Carry_Adder#(parameter width = 32)(
    input [width-1:0] A_i,
    input [width-1:0] B_i,
    input C_i,
    input Sel_i,        // 0 for addition 1 for subtraction
    output [width-1:0] Sum_o,
    output C_o,
    output Overflow_o
    );
    wire [width-1:0] temp_A , temp_B;
    wire [width:0] C;
    wire [width-1:0] S;
    
    assign temp_A = A_i; 
    assign temp_B = !Sel_i ? (B_i):(~(B_i)+1);
    assign C[0] = C_i;
    assign Sum_o = S;
    assign C_o = C[width];
    assign Overflow_o = C[width] ^ C[width-1];
    
    genvar i;
    generate
        for (i=0;i<width;i=i+1)begin
            full_adder FA(
                . A(temp_A[i]), 
                . B(temp_B[i]), 
                . Ci(C[i]), 
                . Sum(S[i]), 
                . Co(C[i+1]) 
            );
        end
    endgenerate
endmodule 

module full_adder (
    input A, 
    input B, 
    input Ci, 
    output Sum, 
    output Co);
    
    wire A_B, A_Ci, A_B_Ci;
    
    xor (A_B,A,B);
    xor (Sum,A_B,Ci);
    and (A_B_Ci,A_B,Ci);
    and (A_Ci,A,B);
    or  (Co,A_Ci,A_B_Ci );
endmodule
