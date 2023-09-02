module ALU #(parameter WIDTH = 32)(
    input clk,
    input rst,
    input rs1_signed,
    input rs2_signed,
    input [WIDTH-1:0] A, B,
    input [4:0] op,
    input start_alu,
    output busy_alu,
    output valid_alu,
    output reg [WIDTH-1:0] result
);
    reg [1:0] state;
    reg busy_alu_1;
    
    assign busy_alu =  acc_busy_mac  | busy_exp  | busy_o_div  | busy_mul_ieee754;
    assign valid_alu = acc_valid_mac | valid_exp | valid_o_div | valid_mul_ieee754;
    
    always @(posedge clk)begin
        if(rst)begin
            busy_alu_1 <= 1'b0;
            result <= 0;
            carry_in_add <= 0; 
            start_mul_mac <= 0; 
            clear_acc_mac <= 0; 
            start_exp <= 0; 
            leading_or_trailing_zerocounter <= 0;
            return_remainder_or_queotient_div <= 0; 
            start_flag_div <= 0;
            ieee_754_A <= 0;
            ieee_754_B <= 0;
            start_mul_ieee754 <= 0;
            state <= 0;
           
        end
        else if (clk)begin
            if(!busy_alu_1 && start_alu)begin
                op_reg <= op;
                A_reg <= A;
                B_reg <= B;
                busy_alu_1 <= 1;
                
            end
            else if (busy_alu_1 )begin
                case (op_reg)
                    5'b00000:begin  //AND
                        result <= A & B;
                    end 
                    5'b00001:begin  //OR
                        result <=  A | B;
                    end 
                    5'b00010:begin  //XOR
                        result <=  A ^ B;
                    end 
                    5'b00011:begin  //NOT
                        result <=  ~A;
                    end 
                    5'b00100:begin  //NOR
                        result <= ~(A | B);
                    end 
                    5'b00101:begin  // NAND
                        result <= ~(A & B);
                    end 
                    5'b00110:begin  // Adder
                        result <= result_add;
                    end 
                    5'b00111:begin  // Sub(týraktör)
                        result <= result_sub;
                    end 
                    5'b01000:begin  // Multiplier
                        if(state==2'b00) begin
                            ieee_754_A <= ieee754_output_conv;
                            state <= 2'b01;
                        end
                        else if (state==2'b01) begin
                            ieee_754_B <= ieee754_output_conv;
                            state <= 2'b10;
                        end
                        else if (state==2'b10)begin
                            start_mul_ieee754 <= 1'b1;
                            state <= 2'b11;
                        end
                        else if (state==2'b11)begin
                            if (valid_mul_ieee754)begin
                                result <= result_mul_ieee754;
                                state <= 2'b00;
                                
                            end
                        end
                    end 
                    5'b01001:begin  // Exp
                        if (state==2'b00 & !cengo  )begin
                            start_exp <= 1'b1;
                            state <= 2'b01;
                        end
                        else if (state==2'b01)begin
                            if (valid_exp)begin
                                result <= result_exp;
                                state <= 2'b00;
                            end
                        end
                    end 
                    5'b01010:begin  // Divider
                    
                    end 
                    5'b01011:begin  // IEEE475 converter
                    
                    end  
                    5'b01100:begin  // ZeroCounter
                    
                    end   
                    5'b01101:begin  // MAC
                    
                    end   
                    5'b01110:begin  // absolute_value
                    
                    end       
                    default: begin  
                        
                    end
                endcase 
            end
        end
    end
    
    
    
    // Arithmetic Operations 
    reg carry_in_add;
    wire [WIDTH-1:0] result_add;
    wire  carry_out_add;
    adder adder1 (
        . A(A),
        . carry_in(carry_in_add), 
        . B(B), 
        . sum(result_add),
        . carry_out(carry_out_add)
    );
    ///////////////////////////////
    wire [WIDTH-1:0] result_sub;
    wire borrow_out_sub;
    subtractor subtractor1 (
        . A(A), 
        . B(B), 
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
        . rs1(A),
        . rs2(B),
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
        . exp(B),
        . result(result_exp),
        . valid(valid_exp),
        . busy(busy_exp)
    );
    /////////////////////////////////
    wire [WIDTH-1:0] ieee754_output_conv;
    ieee754_converter ieee754_converter_1(
        . integer_part(A), // 32-bit integer part
        . fractional_part(B), // 32-bit fractional part
        . ieee754_output(ieee754_output_conv) // 32-bit IEEE 754 representation
    );
    ///////////////////////////////////
    reg leading_or_trailing_zerocounter;
    wire [5:0] count_zerocounter;
    ZeroCounter ZeroCounter_1(
        . data(A),
        . leading_or_trailing(leading_or_trailing_zerocounter),  // 1 for leading, 0 for trailing
        . count(count_zerocounter)
    );
    //////////////////////////////////////
    wire [WIDTH-1:0] data_out_abs;
    absolute_value absolute_value_1(
        . data_in(A),
        . data_out(data_out_abs)
    );
    ///////////////////////////////////////
    reg return_remainder_or_queotient_div;
    reg start_flag_div;
    wire busy_o_div;
    wire valid_o_div;
    wire error_o_div;
    wire [WIDTH-1:0] result_o_div;
    booth_algorithm_divider booth_algorithm_divider_1(
        . clk_i(clk),
        . rst_i(rst),
        . divident(A),
        . divisor(B),
        . return_remainder_or_queotient(return_remainder_or_queotient_div),    // 1 = remainder , 0 = queotient
        . start_flag(start_flag_div),
        . busy_o(busy_o_div),
        . valid_o(valid_o_div),
        . error_o(error_o_div),
        . result_o(result_o_div)
    );
    /////////////////////////////////////////
    reg [WIDTH-1:0]ieee_754_A;
    reg [WIDTH-1:0]ieee_754_B;
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