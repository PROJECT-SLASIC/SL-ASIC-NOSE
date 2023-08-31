module log2(
  input [31:0] a, 
  output reg [7:0] log2_a_int_part,
  output reg [31:0] log2_a_frac_part
);
  reg [7:0] a_exp;
  reg [31:0] a_frac;
  reg [31:0] x;
  reg [31:0] one_over_ln2 = 32'hb8aa3b00; // 1/ln(2) scaled by 2^30
  reg [31:0] taylor_term;
  reg [63:0] temp_result;

  always @(*) begin
    // Extract the exponent and fractional parts of 'a'
    a_exp = a[30:23] - 8'd127;

    // Compute x = a_frac - 1
    x = {1'b0,a[22:0], 8'b0};

   // Compute log2(a_frac) using Taylor series expansion of ln(x)
    // ln(x) = (x-1) - (x-1)^2/2 + (x-1)^3/3 - (x-1)^4/4 + ...
    taylor_term = x;
    log2_a_frac_part = taylor_term;
     temp_result =  x * taylor_term;
     taylor_term = temp_result[62:31];
     
     log2_a_frac_part = log2_a_frac_part - (taylor_term >>> 1);
      temp_result = taylor_term * x;
     taylor_term = temp_result[62:31];
     log2_a_frac_part = log2_a_frac_part + (taylor_term / 3);
     temp_result = taylor_term * x;
     taylor_term = temp_result[62:31];
    log2_a_frac_part = log2_a_frac_part - (taylor_term >>> 2); 
    temp_result = taylor_term * x;
     taylor_term = temp_result[62:31];
    log2_a_frac_part = log2_a_frac_part + (taylor_term / 5); 

    // Adjust for base 2
    temp_result = log2_a_frac_part * one_over_ln2;
    log2_a_frac_part = temp_result[61:30];

    // Compute the integer part of log2(a)
    log2_a_int_part = a_exp;
  end
endmodule

