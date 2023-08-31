module ieee754_converter (
    input [31:0] integer_part, // 32-bit integer part
    input [31:0] fractional_part, // 32-bit fractional part
    output reg [31:0] ieee754_output // 32-bit IEEE 754 representation
);

    reg [22:0] fraction; // 23-bit fraction part
    reg [7:0] exponent; // 8-bit exponent
    reg sign; // Sign bit
    reg [4:0] first_one_position; // Position of the first '1' bit in integer_part
    integer i;
    reg found_one;
    reg [63:0] temp64bit; // Temporary 64-bit storage

    always @* begin
        // Find position of first '1' bit in integer part when looking from left
        first_one_position = 0; // Default value if no '1' bit is found
        found_one = 0; // Flag to indicate if '1' bit is found

        for (i = 31; i >= 0; i = i - 1) begin
            if (integer_part[i] == 1'b1 && !found_one) begin
                first_one_position = i; // Assign the position of the first '1' bit
                found_one = 1; // Set the flag to indicate '1' bit is found
            end
        end

        // Calculate exponent using the position of the first '1' bit
        exponent = 127 + first_one_position;

        // Combine integer and fractional parts into a temporary 64-bit variable
        temp64bit = {integer_part, fractional_part};

        // Shift the combined value right by the position of the first '1' bit
        temp64bit = temp64bit >> first_one_position;

        // Extract the lower 23 bits of the result as the fraction
        fraction = temp64bit[31:9];

        // Check for exponent overflow
        if (exponent >= 255) begin
            exponent = 255; // Set to maximum exponent
            fraction = 0; // Set fraction to 0
        end

        sign = 0; // Always positive for this example

        ieee754_output = {sign, exponent, fraction};
    end

endmodule
