module Uart_TX_tb();
    reg clk_tb;
    reg rst_tb;
    reg [7:0] din_i_tb;
    reg tx_start_i_tb;
    wire tx_o_tb;
    wire tx_busy_tb;
    wire tx_done_tick_o_tb;

    Uart_TX DUT(
        . clk(clk_tb),
        . rst(rst_tb),
        . din_i(din_i_tb),
        . tx_start_i(tx_start_i_tb),
        . tx_o(tx_o_tb),
        . tx_busy(tx_busy_tb),
        . tx_done_tick_o(tx_done_tick_o_tb)
    );
    
    always begin
        #5 clk_tb = ~clk_tb;
    end
    
    initial begin
        clk_tb = 1'b0;
        rst_tb = 1'b0;
        din_i_tb = 8'b0;
        tx_start_i_tb = 1'b0;
        #10;
        rst_tb = 1'b1;
        #10;
        rst_tb = 1'b0;
        #50;
        din_i_tb = 8'h45;
        tx_start_i_tb = 1'b1;
        #10;
        tx_start_i_tb = 1'b0;
    end
endmodule
