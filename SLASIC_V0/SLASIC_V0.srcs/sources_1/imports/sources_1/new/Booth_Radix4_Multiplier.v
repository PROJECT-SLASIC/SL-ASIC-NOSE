module Booth_Radix4_Multiplier #(parameter WIDTH = 32)(
    input clk,
    input rst,
    input [WIDTH-1:0] rs1,
    input [WIDTH-1:0] rs2,
    input start,
    output reg [WIDTH-1:0] result,  // Only the 24 MSBs
    output reg valid,
    output reg busy
);

    // Intermediary signals
    reg [2*WIDTH-1:0] product = 1'b0;
    reg [2*WIDTH-1:0] multiplicand;
    reg [2*WIDTH-1:0] multiplier;
    reg [$clog2(WIDTH):0] counter = 1'b0;
    reg start_reg = 1'b0;
    
    wire [2:0] current_bits = multiplier[2:0]; 
    wire [2*WIDTH-1:0] partial_product0 = multiplicand << (counter * 3);
    wire [2*WIDTH-1:0] partial_product1 = multiplicand << (counter * 3 + 1);
    wire [2*WIDTH-1:0] partial_product2 = multiplicand << (counter * 3 + 2);
    wire [2*WIDTH-1:0] add0 = product + (current_bits[0] ? partial_product0 : 0);
    wire [2*WIDTH-1:0] add1 = add0 + (current_bits[1] ? partial_product1 : 0);
    wire [2*WIDTH-1:0] add2 = add1 + (current_bits[2] ? partial_product2 : 0);

    always @(posedge clk) begin
        if (rst) begin
            start_reg <= 1'b0;
            product <= 1'b0;
            multiplicand <= 0;
            multiplier <= 0;
            counter <= 0;
            valid <= 0;
            busy <= 0;
            result <= 0;
        end else begin
            start_reg <= start;
    
            if ((start_reg || start) && !busy) begin
                multiplicand <= rs1;
                multiplier <= rs2;
                product <= 0;
                counter <= 0;
                busy <= 1;
                valid <= 0;
                result <= 0;
            end else if (busy && counter < WIDTH/3) begin
                product <= add2;
                multiplier <= multiplier >> 3;
                counter <= counter + 1;
            end else if (counter == WIDTH/3) begin
//                result <= add2[2*WIDTH-1:WIDTH]; 
                result <= add2[WIDTH-1:0]; 
                counter <= 0; 
                valid <= 1;
                busy <= 0;
            end else if (valid)begin
                valid <= 1'b0;
            end
        end
    end
endmodule
