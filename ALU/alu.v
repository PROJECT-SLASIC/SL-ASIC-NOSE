module ALU #(parameter WIDTH = 32)(
    input clk,
    input rst,
    input rs1_signed,
    input rs2_signed,
    input [WIDTH-1:0] A, B,
    input [4:0] op,
    input start_alu,
    input operation_ieee754_or_integer, // will be added later on
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
    
    reg [2*WIDTH-1:0] temp_64_result; 
    
    assign error_alu = error_o_div;     // means divisor is 0 
    assign busy_alu =  acc_busy_mac  | busy_exp  | busy_o_div  | busy_mul_ieee754;
    assign valid_alu = acc_valid_mac | valid_exp | valid_o_div | valid_mul_ieee754;
    
    always @(posedge clk)begin
        if(rst)begin
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
//                    5'b10000:begin  // absolute_value
//                        result <= ieee754_output_conv & 32'h7FFFFFFF;
//                    end        
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
    
    
    
endmodule
