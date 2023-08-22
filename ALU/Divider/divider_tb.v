`timescale 1ns / 1ps

module booth_algorithm_divider_tb();

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
    
    booth_algorithm_divider dut(
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
    
    integer i = 0;
    reg [width-1:0] queotient = {(width){1'b0}};
    reg [width-1:0] remainder = {(width){1'b0}};
    reg error_in_queotient = 0;
    reg error_in_remainder = 0;
    
    always begin
        #5 clk_i_tb = ~clk_i_tb;
    end
    
    initial begin
        clk_i_tb = 1'b1;
        rst_i_tb = 1'b0;
        divident_tb = {(width){1'b0}};
        divisor_tb = {(width){1'b0}};
        return_remainder_or_queotient_tb = 1'b1;
        start_flag_tb = 1'b0;
        #5;
        
        rst_i_tb = 1'b1;
        #10;
        rst_i_tb = 1'b0;
        #10;
        
        for (i=0;i<10000000;i=i+1)begin
            divident_tb = $random;
            divisor_tb = $random;
            return_remainder_or_queotient_tb = $random;
            start_flag_tb = 1'b1;
            #10;
            start_flag_tb = 1'b0;
            wait(!busy_o_tb);
            #10;
            queotient = divident_tb / divisor_tb;
            remainder = divident_tb % divisor_tb;
            error_in_queotient = ((queotient!=result_o_tb) && !(return_remainder_or_queotient_tb)) ? 1'b1: 1'b0; 
            error_in_remainder = ((remainder!=result_o_tb) && (return_remainder_or_queotient_tb)) ? 1'b1: 1'b0;
        end
        $finish;
    end
endmodule
