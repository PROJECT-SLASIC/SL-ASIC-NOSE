module alu #(parameter WIDTH = 32)(
    input clk,
    input rst,
    input [WIDTH-1:0] A, 
    input [WIDTH-1:0] B,
    input [4:0] op,
    input start_alu,
    output error_alu,
    output busy_alu,
    output valid_alu,
    output reg [WIDTH-1:0] result
);
    reg [1:0] state;
    reg busy_alu_1;
    reg [WIDTH-1:0]ieee_754_A;
    reg [WIDTH-1:0]ieee_754_B;
    reg [4:0] op_reg;
    reg [WIDTH-1:0] A_reg;
    reg [WIDTH-1:0] B_reg;
    reg start_alu_reg;
    reg rs1_signed;
    reg rs2_signed;
    
    reg [2*WIDTH-1:0] temp_64_result; 
    
    assign error_alu = error_o_div;     // means divisor is 0 
    assign busy_alu =  acc_busy_mac  | busy_exp  | busy_o_div  | busy_mul_ieee754 | log_busy;
    assign valid_alu = acc_valid_mac | valid_exp | valid_o_div | valid_mul_ieee754;
    
    always @(posedge clk)begin
        if(rst)begin
            rs1_signed <= 1'b0;
            rs2_signed <= 1'b0;
            busy_alu_1 <= 1'b0;
            result <= {(WIDTH){1'b0}};
            start_mul_mac <= 1'b0; 
            clear_acc_mac <= 1'b0; 
            start_exp <= 1'b0; 
            leading_or_trailing_zerocounter <= 1'b0;
            return_remainder_or_queotient_div <= 1'b0; 
            start_flag_div <= 1'b0;
            ieee_754_A <= {(WIDTH){1'b0}};
            ieee_754_B <= {(WIDTH){1'b0}};
            start_mul_ieee754 <= 1'b0;
            state <= 2'b0;
            op_reg <= 5'b0;
            A_reg <= {(WIDTH){1'b0}};
            B_reg <= {(WIDTH){1'b0}};
            start_alu_reg <= 1'b0;
            temp_64_result <= {(2*WIDTH){1'b0}};
        end
        else if (clk)begin
            if(start_alu)begin
                start_alu_reg <= (start_alu);
            end
            if(!busy_alu_1 && start_alu_reg)begin
                op_reg <= op;
                A_reg <= A;
                B_reg <= B;
                busy_alu_1 <= 1;
            end
            else if (busy_alu_1 )begin
                case (op_reg)
                    5'b00000:begin  //AND
                        result <= A_reg & B_reg;
                        busy_alu_1 <= 1'b0;
                    end 
                    5'b00001:begin  //OR
                        result <=  A_reg | B_reg;
                        busy_alu_1 <= 1'b0;
                    end 
                    5'b00010:begin  //XOR
                        result <=  A_reg ^ B_reg;
                        busy_alu_1 <= 1'b0;
                    end 
                    5'b00011:begin  //NOT
                        result <=  ~A_reg;
                        busy_alu_1 <= 1'b0;
                    end 
                    5'b00100:begin  //NOR
                        result <= ~(A_reg | B_reg);
                        busy_alu_1 <= 1'b0;
                    end 
                    5'b00101:begin  // NAND
                        result <= ~(A_reg & B_reg);
                        busy_alu_1 <= 1'b0;
                    end 
                    5'b00110:begin  // Adder
                        result <= result_add;
                        busy_alu_1 <= 1'b0;
                    end 
                    5'b00111:begin  // Sub(tıraktör)
                        result <= result_sub;
                        busy_alu_1 <= 1'b0;
                    end 
                    5'b01000:begin  // Multiplier
                        if(state==2'b00) begin
                            ieee_754_A <= ieee754_output_conv;
                            busy_alu_1 <= 1'b0;
                            state <= 2'b01;
                        end
                        else if (state==2'b01) begin
                            ieee_754_B <= ieee754_output_conv;
                            busy_alu_1 <= 1'b0;
                            state <= 2'b10;
                        end
                        else if (state==2'b10)begin
                            start_mul_ieee754 <= 1'b1;
                            state <= 2'b11;
                        end
                        else if (state==2'b11)begin
                            start_mul_ieee754 <= 1'b0;
                            if (valid_mul_ieee754)begin
                                start_alu_reg <= 1'b0;
                                result <= result_mul_ieee754;
                                busy_alu_1 <= 1'b0;
                                state <= 2'b00;
                            end
                        end
                    end 
                    5'b01001:begin  // Exp
                        if (state==2'b00)begin
                            start_exp <= 1'b1;
                            state <= 2'b01;
                        end
                        else if (state==2'b01)begin
                            start_exp <= 1'b0;
                            if (valid_exp)begin
                                start_alu_reg <= 1'b0;
                                result <= result_exp;
                                busy_alu_1 <= 1'b0;
                                state <= 2'b00;
                            end
                        end
                    end 
                    5'b01010,5'b01011:begin  // Divider
                        if (state==2'b00)begin
                            return_remainder_or_queotient_div <= (op_reg & 5'b00001) ? (1'b1):(1'b0);
                            start_flag_div <= 1'b1;
                            state <= 2'b01;
                        end
                        else if (state==2'b01)begin
                            start_flag_div <= 1'b0;
                            if (valid_o_div)begin
                                start_alu_reg <= 1'b0;
                                result <= result_o_div;
                                busy_alu_1 <= 1'b0;
                                state <= 2'b00;
                            end
                        end
                    end 
                    /*5'b01011:begin  // Modulus
                        if (state==2'b00)begin
                            return_remainder_or_queotient_div <= 1;
                            start_flag_div <= 1'b1;
                            state <= 2'b01;
                        end
                        else if (state==2'b01)begin
                            start_flag_div <= 1'b0;
                            if (valid_o_div)begin
                                result <= result_o_div;
                                busy_alu_1 <= 1'b0;
                                state <= 2'b00;
                            end
                        end
                    end */
                    5'b01100,5'b01101:begin  // trailing ZeroCounter, leading ZeroCounter
                        leading_or_trailing_zerocounter <= (op_reg & 5'b00001) ? (1'b1):(1'b0);
                        result <= {26'b0, count_zerocounter};
                    end   
                    /*5'b01101:begin  // trailing ZeroCounter
                        leading_or_trailing_zerocounter <= 1'b0;
                        result <= {26'b0, count_zerocounter};
                    end   */
                    5'b01110:begin  // MAC
                        if (state == 2'b00 && (A_reg != 0) && (B_reg != 0)) begin
                            start_mul_mac <= 1'b1;
                            state <= 2'b01;
                        end
                        else if (state == 2'b00 && (A_reg == 0) && (B_reg == 0))begin
                            clear_acc_mac <= 1'b1;
                            state <= 2'b01;
                        end
                        else if (state==2'b01&&!clear_acc_mac)begin
                            start_mul_mac <= 1'b0;
                            if (acc_valid_mac)begin
                                start_alu_reg <= 1'b0;
                                temp_64_result <= result_mac;
                                busy_alu_1 <= 1'b0;
                                state <= 2'b00;
                            end
                        end
                        else if (state==2'b01&&clear_acc_mac)begin
                            clear_acc_mac <= 1'b0;
                            state <= 2'b00;
                        end
                    end    
                    5'b01111:begin  // absolute_value
                        result <= ieee754_output_conv & 32'h7FFFFFFF;
                    end     
                    5'b10000:begin  // log_2_IEEE
                        if(state== 2'b00) begin
                        log_start <= 1;
                        busy_alu_1 <=1;
                        state<= 2'b01;
                        end
                   else if(state== 2'b01) begin  
                        log_start <= 0;
                        state<= 2'b10;
                   
                   end 
                    
                   else if(state== 2'b10 & done) begin
                        A_reg <= log_integer;
                        B_reg <= log_fraction;
                        state<= 2'b11;
                        log_start <= 0;
                        
                        
                        end
                        
                   else if(state== 2'b11) begin
                        result <=ieee754_output_conv;
                        state<= 2'b00;
                        start_alu_reg <= 1'b0;
                        busy_alu_1 <=0;
                        
                        end
                     end    
                    default: begin  
                        result <= 32'b0;
                         
                    end
                endcase 
            end
        end
    end
    
    
    
    // Arithmetic Operations 
    wire [WIDTH-1:0] result_add;
    wire  carry_out_add;
    adder adder1 (
        . A(A_reg),
        . B(B_reg), 
        . sum(result_add),
        . carry_out(carry_out_add)
    );
    ///////////////////////////////
    wire [WIDTH-1:0] result_sub;
    wire borrow_out_sub;
    subtractor subtractor1 (
        . A(A_reg), 
        . B(B_reg), 
        . borrow_out(borrow_out_sub),
        . difference(result_sub)
    );
    ///////////////////////////////
    reg start_mul_mac; 
    reg clear_acc_mac;
    wire [2*WIDTH-1:0] result_mac;
    wire acc_valid_mac,acc_busy_mac;
    mac_unit mac_unit_1(
        . clk(clk),
        . rst(rst),
        . rs1(A_reg),
        . rs2(B_reg),
        . rs1_signed(rs1_signed),
        . rs2_signed(rs2_signed),
        . start_mul(start_mul_mac),
        . clear_acc(clear_acc_mac),
        . mac_result(result_mac),
        . acc_valid(acc_valid_mac),      // Changed from mul_valid
        . acc_busy(acc_busy_mac)        // Changed the name for external signal
    );
    //////////////////////////////////
    reg start_exp;
    wire [WIDTH-1:0] result_exp;
    wire valid_exp, busy_exp;
    exponentiation exponentiation_1(
        . clk(clk), 
        . rst(rst), 
        . start(start_exp),
        . exp(B_reg),
        . result(result_exp),
        . valid(valid_exp),
        . busy(busy_exp)
    );
    /////////////////////////////////
    wire [WIDTH-1:0] ieee754_output_conv;
    ieee754_converter ieee754_converter_1(
        . integer_part(A_reg), // 32-bit integer part
        . fractional_part(B_reg), // 32-bit fractional part
        . ieee754_output(ieee754_output_conv) // 32-bit IEEE 754 representation
    );
    ///////////////////////////////////
    reg leading_or_trailing_zerocounter;
    wire [5:0] count_zerocounter;
    ZeroCounter ZeroCounter_1(
        . data(A_reg),
        . leading_or_trailing(leading_or_trailing_zerocounter),  // 1 for leading, 0 for trailing
        . count(count_zerocounter)
    );
    //////////////////////////////////////
    /*wire [WIDTH-1:0] data_out_abs;
    absolute_value absolute_value_1(
        . data_in(A_reg),
        . data_out(data_out_abs)
    );
    ///////////////////////////////////////*/
    reg return_remainder_or_queotient_div;
    reg start_flag_div;
    wire busy_o_div;
    wire valid_o_div;
    wire error_o_div;
    wire [WIDTH-1:0] result_o_div;
    booth_algorithm_divider booth_algorithm_divider_1(
        . clk(clk),
        . rst_i(rst),
        . divident(A_reg),
        . divisor(B_reg),
        . return_remainder_or_queotient(return_remainder_or_queotient_div),    // 1 = remainder , 0 = queotient
        . start_flag(start_flag_div),
        . busy_o(busy_o_div),
        . valid_o(valid_o_div),
        . error_o(error_o_div),
        . result_o(result_o_div)
    );
    /////////////////////////////////////////
    reg start_mul_ieee754;
    wire [WIDTH-1:0] result_mul_ieee754;
    wire valid_mul_ieee754;
    wire busy_mul_ieee754;
    ieee_754_multiplier ieee_754_multiplier_1(
        . clk(clk),
        . rst(rst),
        . rs1(ieee_754_A),  // IEEE 754 single precision
        . rs2(ieee_754_B),  // IEEE 754 single precision
        . start(start_mul_ieee754),
        . result(result_mul_ieee754),  // IEEE 754 single precision
        . valid(valid_mul_ieee754),
        . busy(busy_mul_ieee754)
    );
    /////////////////////////////////////////////
    reg log_start;
    wire [31:0] log_integer;
    wire [31:0] log_fraction;
    wire done;
    wire log_busy;
    log2_calc_gpt log2_calc_gpt (
    .clk(clk), 
    .rst(rst),
    .start(log_start),
    .in(A_reg), // IEEE754 Single Precision
    .integer_part(log_integer), // Output integer part
    .fraction_part(log_fraction), // Output fraction part
    .done(done),
    .busy(log_busy)
                   // signal indicating the computation is complete
);
    //////////////////////////////////////////////
    
    
endmodule

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

module adder(
    input [31:0] A, B,
    input carry_in,
    output [31:0] sum,
    output carry_out
);

assign {carry_out, sum} = A + B + carry_in;

endmodule

module booth_algorithm_divider#(parameter width = 32)(
    input clk,
    input rst_i,
    input [width-1:0] divident,
    input [width-1:0] divisor,
    input return_remainder_or_queotient,    // 1 = remainder , 0 = queotient
    input start_flag,
    output reg busy_o,
    output reg valid_o,
    output reg error_o,
    output reg [width-1:0] result_o
    );
    reg [2*width:0] A_Q_reg;
    reg [width:0] B_reg;
    reg [5:0] count;
    reg start_reg;
    reg clear_reg;
    
    wire [2*width:0] A_Q_reg_shift = A_Q_reg << 1;
    wire [width:0] A_subtract_B = A_Q_reg_shift[2*width:width] + B_reg;
    wire [width-1:0] remainder = A_Q_reg[2*width-1:width];
    wire [width-1:0] queotient = A_Q_reg[width-1:0];
    
    always @(posedge clk)begin
        if(rst_i == 1'b1)begin
            A_Q_reg <= {(2*width+1){1'b0}};
            B_reg <= {(width+1){1'b0}};
            count <= {(width+1){1'b0}};
            busy_o <= 1'b0;
            valid_o <= 1'b0;
            result_o <= {(width){1'b0}};
            start_reg <= 1'b0;
            clear_reg <= 1'b0;
            error_o <= 1'b0;
        end
        else if(clk == 1'b1)begin
            if(start_flag && (divisor!=0))begin
                A_Q_reg <= {{(width+1){1'b0}}, divident };
                B_reg <= (~({1'b0,divisor})+1);
                busy_o <= 1'b1;
                error_o <= 1'b0;
                count <= width;
                start_reg <= 1'b1;
            end
            else if (start_reg)begin
                A_Q_reg <= A_Q_reg_shift;
                if(A_subtract_B[width])begin
                    A_Q_reg[0] <= 1'b0;
                end
                else begin
                    A_Q_reg[0] <= 1'b1;
                    A_Q_reg[2*width:width] <= A_subtract_B;
                end
                if(!count)begin
                    busy_o <= 1'b0;
                    valid_o <= 1'b1;
                    result_o <= (return_remainder_or_queotient) ? remainder : queotient;
                    clear_reg <= 1'b1;
                    start_reg <= 1'b0;
                end
                else begin
                    count <= count -1;
                end
            end
            else if (clear_reg)begin
                A_Q_reg <= {(2*width+1){1'b0}};
                B_reg <= {(width+1){1'b0}};
                valid_o <= 1'b0;
                busy_o <= 1'b0;
                clear_reg <= 1'b0;
            end
            else if (start_flag && (!divisor))begin
                error_o <= 1'b1;
            end
        end
    end
endmodule
module exponentiation(
    input clk, rst, start,
    input [31:0] exp,
    output reg [31:0] result,
    output reg valid,
    output reg busy
);
    reg [31:0] temp;
    reg [31:0] exp_temp;
    reg [31:0] rs1, rs2;
    reg start_received;
    reg mult_start;
    reg no_mult;
    reg [2:0] state;
    wire [31:0] next_exp_temp = exp_temp >> 1;
    
    wire [31:0] mult_result;
    wire mult_valid, mult_busy;
    
    // Instantiate the multiplier module
    ieee_754_multiplier multiplier(
        .clk(clk),
        .rst(rst),
        .rs1(rs1),
        .rs2(rs2),
        .start(mult_start),
        .result(mult_result),
        .valid(mult_valid),
        .busy(mult_busy)
    );
    
    // State Encoding
    parameter IDLE = 3'b000;
    parameter START = 3'b001;
    parameter WAIT_VALID = 3'b010;
    parameter WAIT_VALID_2 = 3'b011;
    parameter FINISHED = 3'b100;
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            exp_temp <= 0;
            valid <= 0;
            busy <= 0;
            start_received <= 0;
            mult_start <= 0;
            rs1 <= 0;
            rs2 <= 0;
            no_mult <= 0;
            state <= IDLE;
        end
        else begin
            case(state)
                IDLE: begin
                    valid <= 0;
                    if(start) begin
                        result <= 32'h3F800000; // 1.0 in IEEE 754
                        temp <= 32'h402DF854; // e in IEEE 754
                        exp_temp <= exp;
                        valid <= 0;
                        busy <= 1;
                        state <= START;
                    end
                end
                
                START: begin
                    mult_start <= 0;
                    if(exp_temp == 0) begin
                        state <= FINISHED;
                    end
                    else if(exp_temp[0]) begin
                        rs2 <= temp;
                        rs1 <= result;
                        mult_start <= 1;
                        no_mult <= 0;
                        state <= WAIT_VALID;
                    end
                    else begin
                        no_mult <= 1;
                        state <= WAIT_VALID;
                    end
                end
                
                WAIT_VALID: begin
                    mult_start <= 0;
                    if(mult_valid || no_mult) begin
                        if(!no_mult) result <= mult_result;
                        if(next_exp_temp != 0) begin
                            rs2 <= temp;
                            rs1 <= temp;
                            mult_start <= 1;
                            no_mult <= 0;
                            state <= WAIT_VALID_2;
                        end
                        else begin
                            exp_temp <= next_exp_temp;
                            state <= START;
                        end
                    end
                end
                
                WAIT_VALID_2: begin
                    mult_start <= 0;
                    if(mult_valid || no_mult) begin
                        if(!no_mult) temp <= mult_result;
                        exp_temp <= next_exp_temp;
                        state <= START;
                    end
                end
                
                FINISHED: begin
                    valid <= 1;
                    busy <= 0;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
module ieee_754_multiplier (
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
module mac_unit (
    input clk,
    input rst,
    input [31:0] rs1,
    input [31:0] rs2,
    input rs1_signed,
    input rs2_signed,
    input start_mul,
    input clear_acc,
    output [63:0] mac_result,
    output reg acc_valid,      // Changed from mul_valid
    output reg acc_busy        // Changed the name for external signal
);

    wire [63:0] mul_result;
    wire mul_busy_internal;     // Internal busy signal for multiplier
    wire mul_valid_internal;

    multiplier_last multiplier_inst (
        .clk(clk),
        .rst(rst),
        .rs1(rs1),
        .rs2(rs2),
        .rs1_signed(rs1_signed),
        .rs2_signed(rs2_signed),
        .start(start_mul),
        .result(mul_result),
        .valid(mul_valid_internal),
        .busy(mul_busy_internal)  // Internal busy signal for multiplier
    );

        accumulator accumulator_inst (
            .clk(clk),
            .reset(rst),
            .clear(clear_acc),
            .accumulate(acc_valid),   // Use acc_valid signal to accumulate the result when it's valid
            .data_in(mul_result),
            .data_out(mac_result)
        );

    always @(mul_valid_internal or mul_busy_internal) begin
        acc_valid = mul_valid_internal;
        acc_busy  = mul_busy_internal;
    end

endmodule
module subtractor(
    input [31:0] A, B,
    output [31:0] difference,
    output borrow_out
);

assign {borrow_out, difference} = A + (~B + 1'b1);

endmodule
module ZeroCounter (
    input [31:0] data,
    input leading_or_trailing,  // 1 for leading, 0 for trailing
    output reg [5:0] count
);

always @(*) begin
    if (leading_or_trailing) begin
        // Priority encoder for leading zeros
        if (data[31]) count = 6'd0;
        else if (data[30:0] == 0) count = 6'd32;
        else if (data[30]) count = 6'd1;
        else if (data[29:0] == 0) count = 6'd31;
        else if (data[29]) count = 6'd2;
        else if (data[28:0] == 0) count = 6'd30;
        else if (data[28]) count = 6'd3;
        else if (data[27:0] == 0) count = 6'd29;
        else if (data[27]) count = 6'd4;
        else if (data[26:0] == 0) count = 6'd28;
        else if (data[26]) count = 6'd5;
        else if (data[25:0] == 0) count = 6'd27;
        else if (data[25]) count = 6'd6;
        else if (data[24:0] == 0) count = 6'd26;
        else if (data[24]) count = 6'd7;
        else if (data[23:0] == 0) count = 6'd25;
        else if (data[23]) count = 6'd8;
        else if (data[22:0] == 0) count = 6'd24;
        else if (data[22]) count = 6'd9;
        else if (data[21:0] == 0) count = 6'd23;
        else if (data[21]) count = 6'd10;
        else if (data[20:0] == 0) count = 6'd22;
        else if (data[20]) count = 6'd11;
        else if (data[19:0] == 0) count = 6'd21;
        else if (data[19]) count = 6'd12;
        else if (data[18:0] == 0) count = 6'd20;
        else if (data[18]) count = 6'd13;
        else if (data[17:0] == 0) count = 6'd19;
        else if (data[17]) count = 6'd14;
        else if (data[16:0] == 0) count = 6'd18;
        else if (data[16]) count = 6'd15;
        else if (data[15:0] == 0) count = 6'd17;
        else if (data[15]) count = 6'd16;
        else if (data[14]) count = 6'd17;
        else if (data[13]) count = 6'd18;
        else if (data[12]) count = 6'd19;
        else if (data[11]) count = 6'd20;
        else if (data[10]) count = 6'd21;
        else if (data[9]) count = 6'd22;
        else if (data[8]) count = 6'd23;
        else if (data[7]) count = 6'd24;
        else if (data[6]) count = 6'd25;
        else if (data[5]) count = 6'd26;
        else if (data[4]) count = 6'd27;
        else if (data[3]) count = 6'd28;
        else if (data[2]) count = 6'd29;
        else if (data[1]) count = 6'd30;
        else count = 6'd31;
    end else begin
        // Priority encoder for trailing zeros
        if (data[0]) count = 6'd0;
        else if (data[31:1] == 0) count = 6'd32;
        else if (data[1]) count = 6'd1;
        else if (data[31:2] == 0) count = 6'd31;
        else if (data[2]) count = 6'd2;
        else if (data[31:3] == 0) count = 6'd30;
        else if (data[3]) count = 6'd3;
        else if (data[31:4] == 0) count = 6'd29;
        else if (data[4]) count = 6'd4;
        else if (data[31:5] == 0) count = 6'd28;
        else if (data[5]) count = 6'd5;
        else if (data[31:6] == 0) count = 6'd27;
        else if (data[6]) count = 6'd6;
        else if (data[31:7] == 0) count = 6'd26;
        else if (data[7]) count = 6'd7;
        else if (data[31:8] == 0) count = 6'd25;
        else if (data[8]) count = 6'd8;
        else if (data[31:9] == 0) count = 6'd24;
        else if (data[9]) count = 6'd9;
        else if (data[31:10] == 0) count = 6'd23;
        else if (data[10]) count = 6'd10;
        else if (data[31:11] == 0) count = 6'd22;
        else if (data[11]) count = 6'd11;
        else if (data[31:12] == 0) count = 6'd21;
        else if (data[12]) count = 6'd12;
        else if (data[31:13] == 0) count = 6'd20;
        else if (data[13]) count = 6'd13;
        else if (data[31:14] == 0) count = 6'd19;
        else if (data[14]) count = 6'd14;
        else if (data[31:15] == 0) count = 6'd18;
        else if (data[15]) count = 6'd15;
        else if (data[31:16] == 0) count = 6'd17;
        else if (data[16]) count = 6'd16;
        else if (data[31:17] == 0) count = 6'd16;
        else if (data[17]) count = 6'd17;
        else if (data[31:18] == 0) count = 6'd18;
        else if (data[18]) count = 6'd19;
        else if (data[31:19] == 0) count = 6'd19;
        else if (data[19]) count = 6'd20;
        else if (data[31:20] == 0) count = 6'd20;
        else if (data[20]) count = 6'd21;
        else if (data[31:21] == 0) count = 6'd21;
        else if (data[21]) count = 6'd22;
        else if (data[31:22] == 0) count = 6'd22;
        else if (data[22]) count = 6'd23;
        else if (data[31:23] == 0) count = 6'd23;
        else if (data[23]) count = 6'd24;
        else if (data[31:24] == 0) count = 6'd24;
        else if (data[24]) count = 6'd25;
        else if (data[31:25] == 0) count = 6'd25;
        else if (data[25]) count = 6'd26;
        else if (data[31:26] == 0) count = 6'd26;
        else if (data[26]) count = 6'd27;
        else if (data[31:27] == 0) count = 6'd27;
        else if (data[27]) count = 6'd28;
        else if (data[31:28] == 0) count = 6'd28;
        else if (data[28]) count = 6'd29;
        else if (data[31:29] == 0) count = 6'd29;
        else if (data[29]) count = 6'd30;
        else if (data[31:30] == 0) count = 6'd30;
        else if (data[30]) count = 6'd31;
        else count = 6'd32; // If data[31] == 1
    end
end

endmodule

module multiplier_last (
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
        else if(clk)begin
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
                counter <= counter + 1;
            end else if (valid && !busy)begin
                valid <= 1'b0;
            end
        end
    end

endmodule

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
            busy <= 0;
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

module multiplier_unsigned #(
    parameter WIDTH = 24
) (
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
    reg [2*WIDTH-1:0] product = 0;
    reg [2*WIDTH-1:0] multiplicand;
    reg [2*WIDTH-1:0] multiplier;
    reg [$clog2(WIDTH):0] counter = 0;
    reg start_reg = 0;
    
    wire [2:0] current_bits = multiplier[2:0]; 
    wire [2*WIDTH-1:0] partial_product0 = multiplicand << (counter * 3);
    wire [2*WIDTH-1:0] partial_product1 = multiplicand << (counter * 3 + 1);
    wire [2*WIDTH-1:0] partial_product2 = multiplicand << (counter * 3 + 2);
    wire [2*WIDTH-1:0] add0 = product + (current_bits[0] ? partial_product0 : 0);
    wire [2*WIDTH-1:0] add1 = add0 + (current_bits[1] ? partial_product1 : 0);
    wire [2*WIDTH-1:0] add2 = add1 + (current_bits[2] ? partial_product2 : 0);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            start_reg <= 0;
            product <= 0;
            multiplicand <= 0;
            multiplier <= 0;
            counter <= 0;
            valid <= 0;
            busy <= 0;
        end else begin
            start_reg <= start;
    
            if (start_reg && !busy) begin
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
                result <= product[2*WIDTH-2:WIDTH-1];  // Assign only the 24 MSBs
                valid <= 1;
                busy <= 0;
            end
        end
    end

endmodule
