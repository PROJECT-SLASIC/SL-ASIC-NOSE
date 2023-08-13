module multiplier_tb();

    reg clk;
    reg rst;
    reg [31:0] rs1, rs2;
    reg rs1_signed, rs2_signed;
    reg start;
    wire busy;
    wire valid;
    wire [63:0] result;
    reg error_flag = 0;
    reg [63:0] temp_result;
    integer i;

    // Instantiate the multiplier
    multiplier_last U1 (
        .clk(clk), .rst(rst), .rs1(rs1), .rs2(rs2), .rs1_signed(rs1_signed),
        .rs2_signed(rs2_signed), .start(start), .busy(busy), .valid(valid),
        .result(result)
    );
    
    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        #10;
        rst = 1'b0;
        
        /*
        for(i=0;i<1000;i=i+1)begin
            rs1 = $random;
            rs2 = $random;
            rs1_signed = (rs1[31]==1'b1) ? 1'b1: 1'b0;
            rs2_signed = (rs2[31]==1'b1) ? 1'b1: 1'b0;
            temp_result = {rs1_signed * rs2_signed,rs1[30:0] * rs2[30:0]};
            start = 1'b1;
            #10; 
            start = 1'b0;
            wait(valid && !busy);
            if(result!=temp_result)begin
                error_flag = 1'b1;
            end
            else begin
                error_flag = 1'b0;
            end
            #180;
        end
        $finish;
        */
        // Test 1: simple case
        rs1 = 32'h0; 
        rs2 = 32'h0;
        rs1_signed = 0; 
        rs2_signed = 0;
        start = 1;
        /*if((rs1_signed & rs1[31])^ !(rs2_signed & rs2[31]))begin
            temp_result = (~rs1 + 1 ) * rs2;
        end
        else if (!(rs1_signed & rs1[31])^(rs2_signed & rs2[31]))begin
            temp_result = (~rs2 + 1 ) * rs1;
        end
        else if (!(rs1_signed & rs1[31])^!(rs2_signed & rs2[31]))begin
            temp_result = rs2 * rs1;
        end
        else if ((rs1_signed & rs1[31])^(rs2_signed & rs2[31]))begin
            temp_result = (~rs2 + 1 ) * (~rs1 + 1 );
        end*/
        #10;
        start = 0;
        wait(valid);
        
        #220;
        
        
        // Test 2: negative and positive number
        rs1 = 32'h0; rs2 = 32'h7FFFFFFF; rs1_signed = 0; rs2_signed = 0;
        start = 1;
        #10;
        start = 0;
        wait(valid);     
        #220;
        
                // ...

        // Test 3: Large positive numbers
        rs1 = 32'h0; rs2 = 32'h80000000; rs1_signed = 0; rs2_signed = 1;
        start = 1;
        #10;
        start = 0;
        wait(valid);  
        #220;

        // Test 4: Two negative numbers
        rs1 = 32'h7FFFFFFF; rs2 = 32'h80000000; rs1_signed = 0; rs2_signed = 1;
        start = 1;
        #10;
        start = 0;
        wait(valid);    
        #220;

        // Test 5: Different negative numbers
        rs1 = 32'h7FFFFFFF; rs2 = 32'h7FFFFFFF; rs1_signed = 0; rs2_signed = 1;
        start = 1;
        #10;
        start = 0;
        wait(valid);
        #220;

        // Test 6: Mixed sign
        rs1 = 32'h7FFFFFFF; rs2 = 32'h7FFFFFFF; rs1_signed = 0; rs2_signed = 0;
        start = 1;
        #10;
        start = 0;
        wait(valid);  
        #220;

        // Test 7: Another mixed sign
        rs1 = 32'h80000000; rs2 = 32'h80000000; rs1_signed = 1; rs2_signed = 1;
        start = 1;
        #10;
        start = 0;
        wait(valid); 
        #220;
/*
        // Test 8: Medium-sized numbers
        rs1 = 32'hFFFFFFFF; rs2 = 32'hFFFFFFFF; rs1_signed = 0; rs2_signed = 0;
        start = 1;
        #10;
        start = 0;
        wait(valid);  
        #220;

        // Test 9: Small numbers
        rs1 = 10; rs2 = 5; rs1_signed = 0; rs2_signed = 0;
        start = 1;
        #10;
        start = 0;
        wait(valid);
        if(result !== 50) begin
            error_flag = 1;
            $display("Test 9 failed! Expected 32 but got %h", result);
        end     
        #220;

        // Test 10: A positive and a large negative number
        rs1 = 32'hFFFFFFF0; rs2 = 32'h10; rs1_signed = 1; rs2_signed = 0;
        start = 1;
        #10;
        start = 0;
        wait(valid);
        if(result !== 64'hFFFFFFF000000010) begin
            error_flag = 1;
            $display("Test 10 failed! Expected FFFFFFF000000010 but got %h", result);
        end     
        #220;

        // Concluding the testbench...


        // Concluding the testbench
        if(error_flag) 
            $display("Simulation completed with errors!");
        else 
            $display("All tests passed successfully!");

        $finish;*/
    end 
endmodule
