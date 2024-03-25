module ALU_1#(parameter width = 32)(
    input clk,
    input rst,
    input [width-1:0] A_i,
    input [width-1:0] B_i,
    input [4:0] op,
    output busy_alu,
    output valid_alu,
    output reg [width-1:0] F_o
    );
    
    assign busy_alu = busy_div_alu | busy_mul_alu | (op == 5'd15) | (op == 5'd16) | (op == 5'd17);
    assign valid_alu = valid_div_alu | valid_mul_alu;
    
    wire arith_op_alu ;    
    wire [1:0]logic_op_alu ;    
    wire [1:0]shifter_op_alu ;    
    wire [2:0]cmp_op_alu ;    
    wire [2:0]unit_select_alu ;
    wire mul_op_alu;
    wire div_op_alu;
    
    Function_Control Function_Control_1(
        . op(op),
        . arith_op(arith_op_alu),            // 0 for addition, 1 for subtraction
        . logic_op(logic_op_alu),      // 00 for and, 01 for xor, 10 for or
        . shifter_op(shifter_op_alu),    // 00 shift left, 01 shift right logical, 10 shift right arithmetic
        . cmp_op(cmp_op_alu),        // 000 for equal, 001 for not equal, 010 for greater, 011 for greater than, 100 for less than
        . unit_select(unit_select_alu),
        . mul_op(mul_op_alu),
        . div_op(div_op_alu)
    );
    
    wire [width-1:0] F_arithmetic;
    wire C_arithmetic;
    wire Overflow_arithmetic;
    reg zero = 1'b0;
    Ripple_Carry_Adder Ripple_Carry_Adder_1(
        . A_i(A_i),
        . B_i(B_i),
        . C_i(zero),
        . Sel_i(arith_op_alu),        // 0 for addition 1 for subtraction
        . Sum_o(F_arithmetic),
        . C_o(C_arithmetic),
        . Overflow_o(Overflow_arithmetic)
    );
    
    wire [width-1:0] F_logic;
    Logic_Unit Logic_Unit_1(
        . A_i(A_i),
        . B_i(B_i),
        . logic_op(logic_op_alu),
        . Result_o(F_logic)
    );
    
    wire [width-1:0] F_shifter;
    Shifter_Unit Shifter_Unit_1(
        . A_i(A_i),
        . B_i(B_i),
        . shifter_op(shifter_op_alu),     // 00 shift left, 01 shift right logical, 10 shift right arithmetic
        . Result_o(F_shifter)
    );
    
    wire [width-1:0] F_comparison;
    Comparison_Unit Comparison_Unit_1(
        . A_i(A_i),
        . B_i(B_i),
        . cmp_op(cmp_op_alu),
        . Result_o(F_comparison)
    );
    
    wire start_flag_mul_alu = (op == 5'd15 && !busy_mul_alu && !valid_mul_alu) ? (1'b1) : (1'b0);
    wire valid_mul_alu;
    wire busy_mul_alu;
    wire [width-1:0] F_multiplication;
    Booth_Radix4_Multiplier Multiplier(
        . clk(clk),
        . rst(rst),
        . rs1(A_i),
        . rs2(B_i),
        . start(start_flag_mul_alu),
        . result(F_multiplication),  // Only the 24 MSBs
        . valid(valid_mul_alu),
        . busy(busy_mul_alu)
    );
    
    wire start_flag_div_alu = ((op == 5'd16 || op == 5'd17 ) && !busy_div_alu && !valid_div_alu) ? (1'b1) : (1'b0);
    wire busy_div_alu;
    wire valid_div_alu;
    wire error_div_alu;
    wire [width-1:0] F_division;
    Booth_Radix2_Divider Divider(
        . clk(clk),
        . rst_i(rst),
        . divident(A_i),
        . divisor(B_i),
        . return_remainder_or_queotient(div_op_alu),    // 1 = remainder , 0 = queotient
        . start_flag(start_flag_div_alu),
        . busy_o(busy_div_alu),
        . valid_o(valid_div_alu),
        . error_o(error_div_alu),
        . result_o(F_division)
    );
    
    always @(*)begin
        if(unit_select_alu==3'b000)begin
            F_o = F_arithmetic;
        end
        else if (unit_select_alu==3'b001)begin
            F_o = F_logic;
        end
        else if (unit_select_alu==3'b010)begin
            F_o = F_comparison;
        end
        else if (unit_select_alu==3'b011)begin
            F_o = F_shifter;
        end
        else if (unit_select_alu==3'b100 || valid_mul_alu)begin
            F_o = F_multiplication;
        end
        else if ((unit_select_alu==3'b101) || valid_div_alu)begin
            F_o = F_division;
        end
    end
endmodule
