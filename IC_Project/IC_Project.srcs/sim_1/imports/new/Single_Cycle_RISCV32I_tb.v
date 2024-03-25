module Single_Cycle_RISCV32I_tb();
    parameter width = 32;
    reg clk_i_tb;
    reg rst_i_tb;
    wire tx_pin_tb;
    
    Single_Cycle_RISCV32I Dut(
        . clk(clk_i_tb),
        . rst_i(rst_i_tb),
        . tx_pin(tx_pin_tb)
    );

    always begin
        #5 clk_i_tb = ~clk_i_tb;
    end
    
    initial begin
        clk_i_tb = 1'b0;
        rst_i_tb = 1'b0;
        
        #10;
        rst_i_tb = 1'b1;
        #10;
        rst_i_tb = 1'b0;
        
        #53000;
        
    end
    
endmodule
