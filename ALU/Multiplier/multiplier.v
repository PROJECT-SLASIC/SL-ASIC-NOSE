module multiplier (
    input clk,
    input rst,
    input [31:0] rs1,
    input [31:0] rs2,
    input rs1_signed,
    input rs2_signed,
    input start,
    output reg [63:0] result,
    output reg valid,
    output reg busy
);

    // Intermediary signals
    reg [63:0] product = 0;
    reg [63:0] multiplicand;  // 64 bits for sign extension
    reg [63:0] multiplier;   // Added one bit for sign extension
    reg [4:0] counter = 0;
    reg start_reg = 0;
    
    wire [2:0] current_bits = multiplier[2:0]; 
    wire [63:0] partial_product0 = multiplicand << (counter * 3);
    wire [63:0] partial_product1 = multiplicand << (counter * 3 + 1);
    wire [63:0] partial_product2 = multiplicand << (counter * 3 + 2);
    wire [63:0] add0 = product + (current_bits[0] ? partial_product0 : 0);
    wire [63:0] add1 = add0 + (current_bits[1] ? partial_product1 : 0);
    wire [63:0] add2 = add1 + (current_bits[2] ? partial_product2 : 0);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            start_reg <= 0;
            product <= 0;
            multiplicand <= 0;
            multiplier <= 0;
            counter <= 0;
            valid <= 0;
            busy <= 0;
        end
        else begin
            start_reg <= start;
    
            if (start_reg && !busy) begin
                multiplicand    <= (rs1_signed && rs1[31]) ? {32'hFFFF_FFFF, rs1} : rs1;
                multiplier      <= (rs2_signed && rs2[31]) ? {32'h0000_0000, (~rs2+1)} : rs2;
                product <= 0;
                counter <= 0;
                busy <= 1;
                valid <= 0;
                result <= 0;
            end else if (busy && counter < 16) begin
                product <= add2;
                multiplier <= multiplier >> 3;
                counter <= counter + 1;
            end else if (counter == 16) begin
                //result <= product;
                if(((rs2_signed && rs2[31])))begin
                    result <= ~product + 1 ;
                end
                else begin
                    result <= product;
                end
                //result[63] <= (((rs2_signed && rs2[31])) ^ (rs1_signed && rs1[31])) ? 1'b1: 1'b0;
                valid <= 1;
                busy <= 0;
            end
        end
    end

endmodule
