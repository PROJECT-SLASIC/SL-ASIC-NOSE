`timescale 1ns / 1ps
module SPI_1_tb();
    parameter width = 48;
    reg clk_tb;      // Internal Clock - 100 MHz - 10ns
    reg rst_tb;
    reg clk_ss_tb;   // 0 means 400_000Hz, 1 means 20_000_000Hz
    
    reg spi_start_tb;
    reg [5:0] response_length_tb;
    reg [9:0] data_length_tb;
    reg [5:0] cmd_length_tb;        // represent in byte
    reg [9:0] send_data_length_tb;            // represent in byte
    reg cmd_type_tb;     // 0 for read 1 for write
    
    wire CS_tb;      // Chip Select - Active Low 
    wire MOSI_tb;    // Master out Slave in
    wire SCK_tb;     // Clock    
    reg MISO_tb;         // Master in Slave out
    
    wire busy_spi_tb;
    wire valid_response_tb;
    wire valid_spi_tb;
    
    
    SPI_1 DUT(
        . clk(clk_tb),      // Internal Clock - 100 MHz - 10ns
        . rst(rst_tb),
        . clk_ss(clk_ss_tb),   // 0 means 400_000Hz, 1 means 20_000_000Hz
        
        . spi_start(spi_start_tb),
        . response_length(response_length_tb),
        . data_length(data_length_tb),
        . cmd_length(cmd_length_tb),        // represent in byte
        . send_data_length(send_data_length_tb),            // represent in byte
        . cmd_type(cmd_type_tb),     // 0 for read 1 for write
        
        . CS(CS_tb),      // Chip Select - Active Low 
        . MOSI(MOSI_tb),    // Master out Slave in
        . SCK(SCK_tb),     // Clock    
        . MISO(MISO_tb),         // Master in Slave out
        
        . busy_spi(busy_spi_tb),
        . valid_response(valid_response_tb),
        . valid_spi(valid_spi_tb)
    );
    
    always begin
        #5 clk_tb = ~clk_tb;
    end
    
    initial begin
        clk_tb = 1'b0;
        rst_tb = 1'b0;
        clk_ss_tb = 1'b0;
        spi_start_tb = 1'b0;
        response_length_tb = 6'b0;
        data_length_tb = 10'b0;
        cmd_length_tb = 6'b0;
        send_data_length_tb = 10'b0;
        cmd_type_tb = 1'b0;
        MISO_tb = 1'b1;
        
        #10;
        rst_tb = 1'b1;
        #10;
        rst_tb = 1'b0;
        #25000;
        // Test Cases 
        clk_ss_tb = 1'b0;
        response_length_tb = 6'd1;
        data_length_tb = 10'd5;
        cmd_length_tb = 6'b0;
        send_data_length_tb = 10'b0;
        cmd_length_tb = 6'b0;
        spi_start_tb = 1'b1;
        #200000;
        MISO_tb = 1'b0;
        #10000;
        MISO_tb = 1'b1;
        
        #40000
        MISO_tb = 1'b0;
        #10000;
        MISO_tb = 1'b1;
        #89015;
        spi_start_tb = 1'b0;
        
        #1000000;
        clk_ss_tb = 1'b1;
        response_length_tb = 6'd5;
        data_length_tb = 10'd0;
        cmd_type_tb = 1'b1;
        spi_start_tb = 1'b1;
        #200000;
        spi_start_tb = 1'b0;
        MISO_tb = 1'b0;
        #360;
        MISO_tb = 1'b1;
        
        #40000
        MISO_tb = 1'b0;
        #3000;
        MISO_tb = 1'b1;
        #40015;
        
        
        
        
    end
    
    
    
    
endmodule
