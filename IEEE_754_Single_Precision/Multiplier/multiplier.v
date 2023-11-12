module multiplier(
    input clk,
    input rst,
    input [31:0] rs1,  // IEEE 754 single precision
    input [31:0] rs2,  // IEEE 754 single precision
    input start,
    output reg [31:0] result,  // IEEE 754 single precision
    output reg valid,
    output reg busy
);

    parameter WIDTH = 24;
    reg [2*WIDTH-1:0] product = 0;
    reg [WIDTH-1:0] multiplicand ;
    reg [WIDTH-1:0] multiplier ;
    reg [8:0] exponent;
    reg sign;
    reg [4:0] counter = 0;
    reg start_reg = 0;
    reg valid_reg = 0;
    reg zero_flag = 0;
    reg valid_reg_1 = 0;
    
    wire [31:0] rounded_result = {sign, exponent[7:0], product[2*WIDTH-1:WIDTH+1]} + (product[WIDTH] & (product[WIDTH-1] | product[WIDTH+1]));
    wire [2:0] current_bits = multiplier[2:0]; 
    wire [2*WIDTH-1:0] partial_product0 = {{{WIDTH}{1'b0}}, multiplicand} << (counter * 3);
    wire [2*WIDTH-1:0] partial_product1 = {{{WIDTH}{1'b0}}, multiplicand} << (counter * 3 + 1);
    wire [2*WIDTH-1:0] partial_product2 = {{{WIDTH}{1'b0}}, multiplicand} << (counter * 3 + 2);
    wire [2*WIDTH-1:0] add0 = product + (current_bits[0] ? partial_product0 : 0);
    wire [2*WIDTH-1:0] add1 = add0 + (current_bits[1] ? partial_product1 : 0);
    wire [2*WIDTH-1:0] add2 = add1 + (current_bits[2] ? partial_product2 : 0);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            start_reg <= 0;
            product <= 0;
            multiplicand <= 0;
            multiplier <= 0;
            exponent <= 0;
            sign <= 0;
            counter <= 0;
            valid <= 0;
            busy <= 0;
            valid_reg <= 0;
            zero_flag <= 0;
            valid_reg_1 <= 0;
        end else begin
            start_reg <= start;
    
            if (start_reg && !busy) begin
                multiplicand <= {1'b1,rs1[22:0]};
                multiplier <= {1'b1, rs2[22:0]};
                exponent <= rs1[30:23] + rs2[30:23]-127;
                sign <= rs1[31] ^ rs2[31];
                product <= 0;
                valid_reg <= 0;
                zero_flag <= ((rs1 == 0) || (rs2 == 0)) ? 1'b1 : 1'b0;
                counter <= 0;
                busy <= 1;
                valid <= 0; 
                result <= 0;
            end 
            else if (busy && counter < (WIDTH/3)&& !zero_flag) begin
                product <= add2;
                multiplier <= multiplier >> 3;
                counter <= counter + 1;
            end 
            else if ((counter == (WIDTH/3))&&!(valid_reg)&& !zero_flag) begin
                // Handle the overflow
                if (product[2*WIDTH-1:2*WIDTH-2]==2'b01) begin
                    product <= product << 2;
                    valid_reg <= 1'b1;
                end
                else if (product[2*WIDTH-1:2*WIDTH-2]==2'b10) begin
                    product <= product << 1;
                    exponent <= exponent + 1;
                    valid_reg <= 1'b1;
                end
                else if (product[2*WIDTH-1:2*WIDTH-2]==2'b11) begin
                    product <= product << 1;
                    exponent <= exponent + 1;
                    valid_reg <= 1'b1;
                end
            end
            else if (valid_reg || zero_flag) begin
                // Compose the final result
                result <= (!zero_flag) ? rounded_result : 32'b0;
                valid <= !valid_reg_1;
                busy <= 0;
                valid_reg_1 <= 0;
            end
            valid_reg_1 <= valid_reg | zero_flag;
        end
    end
endmodule
