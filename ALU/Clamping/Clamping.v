module clamping (
    input [31:0] in_data,  // 32-bit input data
    output reg [31:0] out_data // 32-bit clamped data
);

    // Define the clamping bounds. For this example, we use 0x00000000 (0 in 32-bit fixed-point representation) 
    // and 0x7FFFFFFF (maximum positive value in 32-bit two's complement representation). 
    // Adjust these values as needed.
    parameter [31:0] LOWER_BOUND = 32'h00000000; 
    parameter [31:0] UPPER_BOUND = 32'h7FFFFFFF;

    always @(*) begin
        if (in_data < LOWER_BOUND) 
        out_data <= LOWER_BOUND;
        else if (in_data > UPPER_BOUND)
        out_data <= UPPER_BOUND;
        else
        out_data <= in_data;
    end

endmodule
