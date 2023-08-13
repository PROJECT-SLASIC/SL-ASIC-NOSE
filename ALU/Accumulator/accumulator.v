module accumulator (
    input clk,            // Clock signal
    input reset,          // Active-high synchronous reset
    input clear,          // Active-high clear accumulator
    input accumulate,     // Pulse this high to accumulate data
    input [63:0] data_in, // 64-bit input data from 32x32 multiplier
    output reg [63:0] data_out // 64-bit accumulated data
);

    // 64-bit internal accumulator
    reg [63:0] acc;

    always @(posedge clk) begin
        if (reset) 
            acc <= 64'd0; // Reset accumulator to 0
        else if (clear)
            acc <= 64'd0; // Clear accumulator to 0
        else if (accumulate)
            acc <= acc + data_in; // Accumulate input data

        data_out <= acc;  // Output accumulated data
    end

endmodule
