`timescale 1ns / 1ps
module Booth_Radix2_Divider_tb();
    
    parameter width = 32;
    
    reg clk_i_tb;
    reg rst_i_tb;
    reg [width-1:0] divident_tb;
    reg [width-1:0] divisor_tb;
    reg return_remainder_or_queotient_tb;
    reg start_flag_tb;
    wire busy_o_tb;
    wire valid_o_tb;
    wire error_o_tb;
    wire [width-1:0] result_o_tb;
    
    reg [31:0]temp_out;
    reg error;
    reg [31:0]rs1 [0:9999];
    reg [31:0]rs2 [0:9999];
    reg return_remainder_or_quotient_divider [0:9999];
    reg [31:0]result [0:9999];
    reg [32:0] control;
    integer i;
    
    Booth_Radix2_Divider dut(
        . clk_i(clk_i_tb),
        . rst_i(rst_i_tb),
        . divident(divident_tb),
        . divisor(divisor_tb),
        . return_remainder_or_queotient(return_remainder_or_queotient_tb),    // 1 = remainder , 0 = queotient
        . start_flag(start_flag_tb),
        . busy_o(busy_o_tb),
        . valid_o(valid_o_tb),
        . error_o(error_o_tb),
        . result_o(result_o_tb)
    );
        
    // Clock generation
    always begin
        #5 clk_i_tb = ~clk_i_tb;
    end
    
    initial begin
       $readmemh("rs1_divider.mem",rs1);
       $readmemh("rs2_divider.mem",rs2);
       $readmemh("return_remainder_or_quotient_divider.mem",return_remainder_or_quotient_divider);
       $readmemh("expected_output_divider.mem",result);
        
        clk_i_tb = 1'b0;
        rst_i_tb = 1'b1;
        #10;
        rst_i_tb = 1'b0;
        #10;
        
        for(i=0;i<10000;i=i+1)begin
            divident_tb= rs1[i];
            divisor_tb= rs2[i];
            return_remainder_or_queotient_tb = return_remainder_or_quotient_divider[i];
            start_flag_tb=1;
            #10;
            start_flag_tb=0;
            wait(valid_o_tb);
            temp_out=result[i];
            control[32:0]= {1'b0,result[i]} -{1'b0,result_o_tb} ;
            error= control[32] ? ((result_o_tb - result[i] )>32'd2 ):((result[i]- result_o_tb )>32'd0 ) ;
            #20;
       end
       $finish;
    end
endmodule