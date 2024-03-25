module Data_Memory_1 #(parameter width = 32, depth = 64) (
	input              clk                    , // Clock
	input              rst_i                  , // Reset
	input  [width-1:0] alu_result             , // Adress
	input  [width-1:0] wd_data                , // Write Data
	input              write_enable           , // Write Enable
	output [width-1:0] rd                     ,  // Read Data
	
	input  [width-1:0] general_result_data_reg_i,
	output [width-1:0] general_result_data_reg_o,
	
	
);

	reg [width-1:0] data_memory[0:depth];

	// FOR FPGA ONLY
	integer i;
	initial begin
		for (i = 0; i < 150; i = i + 1) begin
			data_memory[i] = 32'b0;
		end
	end

	wire [7:0] index_value = alu_result[7:0];

	assign rd = (!write_enable) ? (data_memory[index_value]) : (32'b0);

	always @(posedge clk) begin
		if(rst_i) begin
			// RESET
		end
		else begin
			data_memory[index_value] <= (write_enable) ? (wd_data) : (data_memory[index_value]);
		end
	end
endmodule
