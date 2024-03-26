module bootloader(
    input clk,
    input rst,
    
    // I2C Module Connections
	input             i2c_busy       ,
	input             i2c_valid      ,
	input      [ 7:0] i2c_index      ,
	input      [ 7:0] i2c_data_in    ,
	output reg [ 7:0] i2c_data_out   ,
    
	// MLP Module Connections
	output reg        mlp_start      ,
	input             mlp_busy       ,
	input             mlp_valid      ,
	input             mlp_ready      
);

	always @(posedge clk) begin
		if (rst) begin
			
		end
		else begin
			
		end
	end



endmodule