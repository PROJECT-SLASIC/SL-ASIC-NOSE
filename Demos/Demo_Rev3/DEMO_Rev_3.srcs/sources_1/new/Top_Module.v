module Top_Module(
    input clk,
    input rst,
    output [7:0] led_o,
    output write_o,
    output valid_o_top,
    // I2C Slave
    input scl,
    inout sda,
    // I2C Master
    inout sda_1,
    output scl_1
    );
    
   assign write_o = demo_busy;
   assign valid_o_top = start_dm_top;
    
    wire [31:0] data_1_wire;
    wire [31:0] data_2_wire;
    wire [31:0] data_3_wire;
    wire [31:0] data_4_wire;
    wire [31:0] data_5_wire;
    wire method_slc_wire;
    wire start_dm_top;
    
    wire demo_valid;
    wire demo_busy;
    
    demo Demo(
        . clk(clk),  
        . rst(rst),       
        . start(start_dm_top),
        . done(demo_valid), 
        . busy(demo_busy),
        . method_select(method_slc_wire),
        
        . sda_1(sda_1),
        . scl_1(scl_1),
        
        . voc1(data_1_wire),
        . voc2(data_2_wire),
        . voc3(data_3_wire),
        . voc4(data_4_wire),
        . voc5(data_5_wire)
    );
    
    wire busy_wire;
    wire valid_wire;
    wire [7:0] data_out_i2c;
    wire [7:0] data_out_ram;
    wire write_i2c;
    wire read_1_i2c;
    wire [7:0] index_1_i2c;
    wire sda_enable;
    
    I2C_Slave I2C_SLAVE_1(
        . clk(clk),
        . rst(rst),
        // I2C Ports
        . sda(sda),
        . scl(scl),
        . sda_enable(sda_enable),
        // RAM control signals
        . write(write_i2c),
        . read_1(read_1_i2c),
        . index_1(index_1_i2c),
        . data_out(data_out_i2c),
        . data_in(data_out_ram),
        // control signals
        . busy(busy_wire),
        . valid(valid_wire)
    );
    
    Register_Module Register_Module_1(
        . clk(clk),
        . rst(rst),
        . write(write_i2c),
        . read_1(read_1_i2c),
        . index_1(index_1_i2c),
        . data_in(data_out_i2c),
        . led(led_o[1]),
        . data_out_1(data_out_ram),
        //
        . data_1(data_1_wire),   // 0x40 - 0x43
        . data_2(data_2_wire),   // 0x44 - 0x47
        . data_3(data_3_wire),   // 0x48 - 0x4b
        . data_4(data_4_wire),   // 0x4c - 0x4f
        . data_5(data_5_wire),   // 0x50 - 0x53
        . method_slc(method_slc_wire),      // 0x54[0]
        . start_rg(start_dm_top)
    );
    
     assign led_o[0] = start_dm_top;
endmodule
