`timescale 1ns / 1ps

module ALU_tb();
    parameter WIDTH = 32;
    
    reg clk;
    reg rst;
    reg rs1_signed;
    reg rs2_signed;
    reg [31:0] A, B;
    reg [4:0] op;
    reg start_alu;
    reg operation_ieee754_or_integer;
    
    wire error_alu;
    wire busy_alu;
    wire valid_alu;
    wire [31:0] result;
    
    ALU #(32) uut (
        .clk(clk),
        .rst(rst),
        .rs1_signed(rs1_signed),
        .rs2_signed(rs2_signed),
        .A(A),
        .B(B),
        .op(op),
        .start_alu(start_alu),
        .operation_ieee754_or_integer(operation_ieee754_or_integer),
        .error_alu(error_alu),
        .busy_alu(busy_alu),
        .valid_alu(valid_alu),
        .result(result)
    );
    reg error_flag = 0;
    reg [WIDTH-1:0] expected_result;
    
    initial begin
        clk = 0;
        rst = 0;
        rs1_signed = 0;
        rs2_signed = 0;
        A = 0;
        B = 0;
        op = 0;
        start_alu = 0;
        operation_ieee754_or_integer = 0;
        
        #10;
        rst = 1;
        #10;
        rst = 0;
        #5;
        
//        //Test Case1: Operation 5'b00000 ---AND
//        start_alu = 1;
//        op = 5'b00000;
//        A = 32'h00000004;
//        B = 32'h00000004;
//        #10;
//        expected_result = 32'h00000004;
       
//        #10;
        
//        A = 32'h0A010114;
//        B = 32'h06020014;
//        #10;
//        expected_result = 32'h02000014;
        
//        #10;
        
        
        
//        //Test Case2: Operation 5'b00001 ---OR
//        start_alu = 1;
//        op = 5'b00001;
//        A = 32'hA3B52F1D;
//        B = 32'h7D3E9A0B;
//        #10;
//        expected_result = 32'hFFBFBF1F;
//        #10;
        
//        A = 32'hF1C2D84E;
//        B = 32'h923467AF;
//        #10;
//        expected_result = 32'hF3F6FFEF;  
//        #10;
        
        
//        //Test Case3: Operation 5'b00010 ---XOR
//         start_alu = 1;
//        op = 5'b00010;
//        A = 32'hA3B52F1D;
//        B = 32'h7D3E9A0B;
//        #10;
//        expected_result = 32'hDE8BB516;
//        #10;
        
//        A = 32'hF1C2D84E;
//        B = 32'h923467AF;
//        #10;
//        expected_result = 32'h63F6BFE1;  
//        #10;
        
//         //Test Case4: Operation 5'b00011 ---NOT
//         start_alu = 1;
//        op = 5'b00011;
//        A = 32'hA3B52F1D;
//        #10;
//        expected_result = 32'h5C4AD0E2;
//        #10;
        
//        A = 32'hF1C2D84E;
//        #10;
//        expected_result = 32'h0E3D27B1;  
//        #10;
        
//        //Test Case5: Operation 5'b00100 ---NOR
//         start_alu = 1;
//        op = 5'b00100;
//        A = 32'hA3B52F1D;
//        B = 32'h7D3E9A0B;
//        #10;
//        expected_result = 32'h004040E0;
//        #10;
        
//        A = 32'hF1C2D84E;
//        B = 32'h923467AF;
//        #10;
//        expected_result = 32'h0C090010;  
//        #10;
        
        
//        //Test Case5: Operation 5'b00101 ---NAND
//         start_alu = 1;
//        op = 5'b00101;
//        A = 32'hA3B52F1D;
//        B = 32'h7D3E9A0B;
//        #10;
//        expected_result = 32'hDECBF5F6;
//        #10;
        
//        A = 32'hF1C2D84E;
//        B = 32'h923467AF;
//        #10;
//        expected_result = 32'h6FFFBFF1;  
//        #10;
        
        
//        //Test Case6: Operation 5'b00110 ---adder
//         start_alu = 1;
//        op = 5'b00110;
//        A = 32'hA3B52F1D;
//        B = 32'h7D3E9A0B;
//        #10;
//        expected_result = 32'h20F3C928;
//        #10;
        
//        A = 32'hF1C2D84E;
//        B = 32'h923467AF;
//        #10;
//        expected_result = 32'h83F73FFD;  
//        #10;
        
        
//        //Test Case7: Operation 5'b00111 ---subtractor
//        start_alu = 1;
//        op = 5'b00111;
//        A = 32'hA3B52F1D;
//        B = 32'h7D3E9A0B;
//        #10;
//        expected_result = 32'h26769512;
//        #10;
        
//        A = 32'hF1C2D84E;
//        B = 32'h923467AF;
//        #10;
//        expected_result = 32'h5F8E709F;  
//        #10;
        
        
        //Test Case7: Operation 5'b010000 ---ieee754 multiplier
        start_alu = 1;
        op = 5'b01000;
        A = 32'h000B85F8;
        B = 32'h0;
        //B = 32'h7D3E9A0B;
        #20;
        A = 32'h0000004B;
        B = 32'h0;
//        B = 32'h923467AF;
        #10;
        start_alu = 0;
        expected_result = 32'h4C580FEA;
        #1000;
        
        //Test Case7: Operation 5'b010000 ---ieee754 multiplier
        start_alu = 1;
        op = 5'b01000;
        A = 32'h0000062C;   //1580,6634
        B = 32'hA9D49600;
        //B = 32'h7D3E9A0B;
        #20;
        A = 32'h0000004B;   //75,8714352
        B = 32'hDF166000;
//        B = 32'h923467AF;
        #10;
        start_alu = 0;
        expected_result = 32'h47EA3B9A;
        #1000;
    
    
    
    
    
    $stop;
    
    
    
    end
    always begin
    #5 clk = ~clk;
    end
    
    
endmodule
