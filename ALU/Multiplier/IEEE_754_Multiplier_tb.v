`timescale 1ns / 1ps

module IEEE_754_Multiplier_tb;
    parameter width = 24;
    reg clk_tb;
    reg rst_tb;
    reg [31:0] rs1_tb;  // IEEE 754 single precision
    reg [31:0] rs2_tb;  // IEEE 754 single precision
    reg start_tb;
    wire [31:0] result_tb;  // IEEE 754 single precision
    wire valid_tb;
    wire busy_tb;
    
    ieee_754_multiplier  dut(
        . clk(clk_tb),
        . rst(rst_tb),
        . rs1(rs1_tb),  // IEEE 754 single precision
        . rs2(rs2_tb),  // IEEE 754 single precision
        . start(start_tb),
        . result(result_tb),  // IEEE 754 single precision
        . valid(valid_tb),
        . busy(busy_tb)
    );
        
    // Clock generation
    always begin
        #5 clk_tb = ~clk_tb;
    end

    initial begin
        clk_tb = 1'b0;
        rst_tb = 1'b1;
        #10;
        rst_tb = 1'b0;

        // Test case 1: 1.0 * 2.0 = 2.0
        rs1_tb = 32'h3F800000;  // 1.0 in IEEE 754
        rs2_tb = 32'h40000000;  // 2.0 in IEEE 754
        start_tb = 1'b1;
        #10;
        start_tb = 1'b0;
        #150;

        // Test case 2: -1.0 * 2.0 = -2.0
        rs1_tb = 32'hBF800000;  // -1.0 in IEEE 754
        rs2_tb = 32'h40000000;  // 2.0 in IEEE 754
        start_tb = 1'b1;
        #10;
        start_tb = 1'b0;
        #150;

        // Test case 3: -1.5 * 3.0 = -4.5
        rs1_tb = 32'HBFC00000;  // -1.5 in IEEE 754
        rs2_tb = 32'h40400000;  // 3.0 in IEEE 754
        start_tb = 1'b1;
        #10;
        start_tb = 1'b0;
        #150;
        
        

        // Test case 3: -1.5 * 3.0 = -4.5
        rs1_tb = 32'hBFA00000;  // -1.25 in IEEE 754
        rs2_tb = 32'hBFB00000;  // -1.375 in IEEE 754
        start_tb = 1'b1;
        #10;
        start_tb = 1'b0;
        #150;
        
        

        // Test case 4: -1.5 * 3.0 = -4.5
        rs1_tb = 32'h483A1C90;  // 190578.256 in IEEE 754
        rs2_tb = 32'hCB08E81C;  // -8972316.2456 in IEEE 754
        start_tb = 1'b1;
        #10;
        start_tb = 1'b0;
        #150;
        
                // Test case 4: 0.5 * 0.5 = 0.25
        rs1_tb = 32'h3F000000;  // 0.5 in IEEE 754
        rs2_tb = 32'h3F000000;  // 0.5 in IEEE 754
        start_tb = 1'b1;
        #10;
        start_tb = 1'b0;
        #150;
        
        // Test case 5: 5.25 * -10.5 = -55.125
        rs1_tb = 32'h40A80000;  // 5.25 in IEEE 754
        rs2_tb = 32'hC1280000;  // -10.5 in IEEE 754
        start_tb = 1'b1;
        #10;
        start_tb = 1'b0;
        #150;
        
        // Test case 6: -0.75 * -0.75 = 0.5625
        rs1_tb = 32'hBF400000;  // -0.75 in IEEE 754
        rs2_tb = 32'hBF400000;  // -0.75 in IEEE 754
        start_tb = 1'b1;
        #10;
        start_tb = 1'b0;
        #150;
        
        // Test case 7: 100000.5 * 0.00001 = 1.000005
        rs1_tb = 32'h47c35040;  // 100000.5 in IEEE 754
        rs2_tb = 32'h3727c5ac;  // 0.00001 in IEEE 754
        start_tb = 1'b1;
        #10;
        start_tb = 1'b0;
        #150;
        
                // Test case 8: 1.175 * 2.25 = 2.64375
        rs1_tb = 32'h3F966666;  // 1.175 in IEEE 754
        rs2_tb = 32'h40100000;  // 2.25 in IEEE 754
        start_tb = 1'b1;
        #10;
        start_tb = 1'b0;
        #150;
        
        // Test case 9: -3.5 * 4.75 = -16.625
        rs1_tb = 32'hC0600000;  // -3.5 in IEEE 754
        rs2_tb = 32'h40980000;  // 4.75 in IEEE 754
        start_tb = 1'b1;
        #10;
        start_tb = 1'b0;
        #150;
        
        // Test case 10: 0.625 * -0.875 = -0.546875
        rs1_tb = 32'h3F200000;  // 0.625 in IEEE 754
        rs2_tb = 32'hBF600000;  // -0.875 in IEEE 754
        start_tb = 1'b1;
        #10;
        start_tb = 1'b0;
        #150;
        
        // Test case 11: 123456.789 * 0.000123 = 15.185185047
        rs1_tb = 32'h47F12065;  // 123456.789 in IEEE 754
        rs2_tb = 32'h3900F990;  // 0.000123 in IEEE 754
        start_tb = 1'b1;
        #10;
        start_tb = 1'b0;
        #150;
        
        // Test case 16: Multiply by 0: 12345.6789 * 0 = 0
        rs1_tb = 32'h4640E6B7;  // 12345.6789 in IEEE 754
        rs2_tb = 32'h00000000;  // 0 in IEEE 754
        start_tb = 1'b1;
        #10;
        start_tb = 1'b0;
        #150;
        
        // Test case 17: Multiply by 1: 12345.6789 * 1 = 12345.6789
        rs1_tb = 32'h4640E6B7;  // 12345.6789 in IEEE 754
        rs2_tb = 32'h3F800000;  // 1 in IEEE 754
        start_tb = 1'b1;
        #10;
        start_tb = 1'b0;
        #150;
        
        

        $finish;
    end

endmodule

