module Data_Memory_1#(parameter width = 32)(
    input clk,
    input rst_i,
    
    input [width-1:0] alu_result,   // Address
    input [width-1:0] wd_data,      // Write Data  
    input write_enable,             // Write Enable
//    output enable,
    output [width-1:0] rd,          // Read Data
    
    // Special Registers
    output dmc_start_bit,
    output dmc_real_time_bit,
    input  dmc_done_bit,
    output mlp_busy_bit,
    output i2c_busy_bit,
    inout  [3:0] mlp_result_bits
    );
      
    reg [width-1:0] data_memory [0:150];
    
    integer i;
    initial begin
        for (i = 0; i < 150; i = i + 1) begin
            data_memory[i] = 32'b0;
        end
    end
    wire [7:0] index_value = alu_result[7:0];
    
    assign rd = (!write_enable) ? (data_memory[index_value]) : (32'b0);
    assign tx_data = data_memory [8][8:0];
//    assign enable = data_memory [8][8];
    
    always @(posedge clk) begin
        if(rst_i)begin
            // RESET
        end
        else begin
            data_memory[index_value] <= (write_enable) ? (wd_data) : (data_memory[index_value]);
            //data_memory [8][8] <= (data_memory [8][8]) ? (1'b0) : (data_memory [8][8]);
        end
    end
endmodule
