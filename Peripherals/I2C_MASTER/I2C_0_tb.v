`timescale 1ns / 1ps
module I2C_0_tb();
    reg clk_tb;
    reg rst_tb;
    
    reg start_i_tb;
    reg [7:0] i2c_addrr_tb;
    reg [7:0] i2c_data_i_tb;
    reg [7:0] i2c_data_addrr_i_tb;
    
    wire resend_tb;
    wire [7:0] i2c_data_o_tb;
    // I2C Ports
    wire sda_tb;
    wire scl_tb;
    
    I2C_0 DUT(
        . clk(clk_tb),
        . rst(rst_tb),
        
        . start_i(start_i_tb),
        . i2c_addrr(i2c_addrr_tb),
        . i2c_data_addrr_i(i2c_data_addrr_i_tb),
        . i2c_data_i(i2c_data_i_tb),
        
        . resend(resend_tb),
        . i2c_data_o(i2c_data_o_tb),
        // I2C Ports
        . sda(sda_tb),
        . scl(scl_tb)
        //
    );
    
    always begin
        #5 clk_tb = ~clk_tb;
    end
    
    initial begin
        clk_tb = 1'b0;
        rst_tb = 1'b0;
        start_i_tb = 1'b0;
        i2c_addrr_tb = 8'h0;
        i2c_data_i_tb = 8'b0;
        i2c_data_addrr_i_tb = 8'b0;
        
        
        #10;
        rst_tb = 1'b1;
        #10;
        rst_tb = 1'b0;
        
        #50;
        
        start_i_tb = 1'b1;
        i2c_addrr_tb = 8'h4f;    // 4E = write       4F = read
        i2c_data_addrr_i_tb = 8'h36;
        i2c_data_i_tb = 8'h27;
        #10;
        start_i_tb = 1'b0;
        
        
    end
    
    
    
endmodule
