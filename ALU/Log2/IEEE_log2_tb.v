module tb_log2_calc_gpt();

    reg clk, rst, start;
    reg [31:0] in;
    wire [7:0] integer_part;
    wire [22:0] fraction_part;
    wire done;
    wire busy;
   
    

    // Instantiate the log2_calc_gpt module
    log2_calc_gpt uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .in(in),
        .integer_part(integer_part),
        .fraction_part(fraction_part),
        .done(done),
        .busy(busy)
        
        
    );

    // Clock generation
    always begin
        #5 clk = ~clk; // Generate a clock with period of 10 time units
    end

    // Test procedure
    initial begin
        // Initial settings
        clk = 0; rst = 1; start = 0; in = 0;
        #10;

        // Release reset and apply start signal
        rst = 0;
        #30;

        // Input a sample value, IEEE 754 Single Precision representation of 2.5 for example
        in = 32'h42dc0000; // 47 in IEEE 754 format
        start = 1;
        #10 start = 0;
        #30;
        wait(!busy);
        #10
        
        
         in = 32'h428e0000; // 71 in IEEE 754 format
        start = 1;
        #20 start = 0;
        #30;
        wait(!busy);
        
         in = 32'h42f40000; // 122 in IEEE 754 format
        start = 1;
        #20 start = 0;
        #30;
        wait(!busy);
        
        
        
       
        

        // Monitor the progress
        wait(done); // Wait until done signal is asserted

        $display("Integer Part: %d, Fraction Part: %b", integer_part, fraction_part);

        // Finish the simulation
        $finish;
    end

endmodule
