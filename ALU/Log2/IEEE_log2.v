module log2_calc_gpt (
    input clk, rst,start,
    input [31:0] in, // IEEE754 Single Precision
    output reg [31:0] integer_part, // Output integer part
    output reg [31:0] fraction_part, // Output fraction part
    output reg done,
    output reg busy
                   // signal indicating the computation is complete
);

parameter         IDLE = 4'b0000,
                  INITIALIZATION = 4'b0001,
                  LOAD = 4'b0010,
                  START_MULTIPLY_SQUARE = 4'b0011,
                  SQUARE = 4'b0100, 
                  START_MULTIPLY_CUBIC = 4'b0101,
                  CUBE = 4'b0110, 
                  SUBSTRACT_SQUARE = 4'b0111,
                  ADD_CUBIC = 4'b1000, 
                  LOAD_LN2_INV = 4'b1001,
                  START_MULTIPLY_LN2_INV = 4'b1010, 
                  DONE = 4'b1011;
 // We've added an additional bit to account for the DONE state.

reg [3:0] state, next_state;  // Adjusting the width to accommodate the maximum number of states.
reg start_reg;
    reg [23:0] over_ln2;
    reg [7:0] exp_minus_127;
    reg [23:0] x, x_square, x_cubic,fraction;
    reg [23:0] mult_rs1, mult_rs2;
    reg mult_start;
    wire mult_busy;
    wire mult_valid;
    wire [23:0] mult_result;

    // Instantiate the multiplier
    multiplier_unsigned #(.WIDTH(24)) mult (
        .clk(clk),
        .rst(rst),
        .rs1(mult_rs1),
        .rs2(mult_rs2),
        .start(mult_start),
        .result(mult_result),
        .valid(mult_valid),
        .busy(mult_busy)
    );

    always @(posedge clk or posedge rst) begin
         
        if (rst) begin
            state <= IDLE;
            integer_part <= 0;
            fraction_part <= 0;
            mult_rs1 <=0;
            mult_rs2 <=0;
            fraction <= 0;
            done <= 0;
            mult_start <= 0;
            over_ln2 <= 24'hB8AA3E;
        end 
        else  begin
            
            if (start )begin 
            start_reg <=1;
            end
        
        case (state)
            IDLE: begin
            done<=0;
            if(start_reg) begin
           state <= INITIALIZATION;
           busy<= 1;
           
             end
        end
            INITIALIZATION: begin
                exp_minus_127 <= in[30:23] - 8'd127; 
                x <= {1'b0 , in[22:0]};
                fraction <= {1'b0 , in[22:0]};
                state <= LOAD;
                mult_start <= 1;
                
            end

            LOAD: begin
                mult_rs1 <= x;
                mult_rs2 <= x;
                 mult_start <= 0;
                state <= START_MULTIPLY_SQUARE;
            end

            START_MULTIPLY_SQUARE: begin
                mult_start <= 0;
                state <= SQUARE;
            end

            SQUARE: begin
                if (!mult_busy) begin
                    x_square <= mult_result;
                    state <= CUBE;
                    mult_start <= 1;
                end
            end

            CUBE: begin
                mult_rs1 <= x;
                mult_rs2 <= x_square;
                mult_start <= 0;
                state <= START_MULTIPLY_CUBIC;
            end

            START_MULTIPLY_CUBIC: begin
                mult_start <= 0;
                state <= SUBSTRACT_SQUARE;
            end

            SUBSTRACT_SQUARE: begin
                if (!mult_busy) begin
                    x_cubic <= mult_result;
                    fraction_part<= mult_result;
                    fraction <= fraction - (x_square >> 1);
                    state <= ADD_CUBIC;
                    mult_start <= 0;
                end
            end

            ADD_CUBIC: begin
                fraction <= fraction+ (x_cubic/6);
                state <= LOAD_LN2_INV;
                mult_start <= 1;
            end
            
             LOAD_LN2_INV: begin
             mult_rs1 <= fraction;
             mult_rs2 <= over_ln2;  // Hexadecimal representation of 1/ln(2)
             mult_start <= 0;
             state <= START_MULTIPLY_LN2_INV;
         end

          START_MULTIPLY_LN2_INV: begin
             mult_start <= 0;
            state <= DONE;
            end

            DONE: begin
            if (!mult_busy) begin
            fraction_part <= {mult_result[22:0],9'b0}; 
            integer_part <={24'b0, exp_minus_127[7:0]};
                busy<=0;
                done<=1;
                start_reg <= 0;
                state <= IDLE;
            end
        end
        endcase
    end
end
endmodule 
