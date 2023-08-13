module signed_comparator (
    input [31:0] A,
    input [31:0] B,
    output AeqB,    // A equals B
    output AltB,    // A less than B
    output AgtB     // A greater than B
);

wire signed_A = A[31];   // MSB of A
wire signed_B = B[31];   // MSB of B

assign AeqB = (A == B);
assign AltB = (signed_A && !signed_B) || (!signed_A && !signed_B && A < B) || (signed_A && signed_B && A < B);
assign AgtB = (!signed_A && signed_B) || (!signed_A && !signed_B && A > B) || (signed_A && signed_B && A > B);

endmodule

