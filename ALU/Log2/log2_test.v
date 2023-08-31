`timescale 1ns / 1ps

module testbench;
  reg [31:0] a;
  wire [7:0] log2_a_int_part;
  wire [31:0] log2_a_frac_part;

  log2 uut (
    .a(a),
    .log2_a_int_part(log2_a_int_part),
    .log2_a_frac_part(log2_a_frac_part)
  );

  initial begin
    a = 32'h3F800000; // 1.0
    #10;
   

    a = 32'h40000000; // 2.0
    #10;
  

    a = 32'h40400000; // 3.0
    #10;
    

    a = 32'h40800000; // 4.0
    #10;
    

    a = 32'h40A00000; // 5.0
    #10;
    
     a = 32'h41D80000; // 27.0
    #10;
    
     a = 32'h41D80000; // 27.0
    #10;
    
     a = 32'h42920000; // 73.0
    #10;

    $stop;
  end
endmodule

