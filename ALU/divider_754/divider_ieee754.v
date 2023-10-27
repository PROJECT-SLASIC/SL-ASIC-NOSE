`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2023 13:18:59
// Design Name: 
// Module Name: booth_algorithm_divider
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module booth_algorithm_divider_ieee754#(parameter width = 23)(
    input clk_i,
    input rst_i,
    input [31:0] divident,
    input [31:0] divisor,
    input start_flag,
    output reg busy_o,
    output reg valid_o,
    output reg error_o,
    output reg [31:0] result_o
    );
    
    reg [2*width:0] A_Q_reg;
    reg [width:0] B_reg;
    reg [5:0] count;
    reg start_reg;
    reg clear_reg;

    reg divident_sign;                                          //******
    reg divisor_sign;                                           //******
    reg [7:0] divident_exp;                                     //******
    reg [7:0] divisor_exp;                                      //******
    reg [width-1:0] divident_mantissa;                          //******
    reg [width-1:0] divisor_mantissa;                           //******
    reg sign_o;
    reg [7:0] exp_o;
    reg [4:0] shift_count;
    reg initialization;
    
    wire [2*width:0] A_Q_reg_shift = A_Q_reg << 1;
    wire [width:0] A_subtract_B = A_Q_reg_shift[2*width:width] + B_reg;
    wire [width-1:0] remainder = A_Q_reg[2*width-1:width];
    wire [width-1:0] queotient = A_Q_reg[width-1:0];
    
    always @(posedge clk_i)begin
        if(rst_i == 1'b1)begin      
            divident_sign <= 1'b0;                              //******
            divisor_sign <= 1'b0;                               //******
            divident_exp <= 8'b0;                               //******
            divisor_exp <= 8'b0;                                //******
            divident_mantissa <= 23'b0;                         //******
            divisor_mantissa <= 23'b0;                          //******
            sign_o <= 1'b0;                                     //******
            exp_o <= 8'b0;                                      //******
            shift_count <= 5'b0;
            initialization <= 1'b1;
            
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
            
        else if(clk_i == 1'b1)begin
            if (initialization == 1'b1) begin
                divident_sign <= divident[31];                      //******           
                divisor_sign <= divisor[31];                        //******
                divident_exp <= divident[30:23];                    //******
                divisor_exp <= divisor[30:23];                      //******
                divident_mantissa <= divident[22:0];                //******
                divisor_mantissa <= divisor[22:0];                  //******
                initialization <= 1'b0;
            end
            else if(divisor_mantissa > divident_mantissa)begin          //******
                divident_mantissa <= divident_mantissa << 1;        //******
                shift_count <= 1;
            end 
            
            if(start_flag && (divisor!=0))begin
                A_Q_reg <= {{(width+1){1'b0}}, divident_mantissa }; //******
                B_reg <= (~({1'b0,divisor_mantissa})+1);            //******
                busy_o <= 1'b1;
                error_o <= 1'b0;
                count <= width;
                start_reg <= 1'b1;
                end
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
                    sign_o <= divident_sign ^ divisor_sign;             //******                   
                    exp_o <= divident_exp - divisor_exp + 127 - shift_count;
                    result_o <= {sign_o, exp_o, remainder ^ queotient};
                    clear_reg <= 1'b1;
                    start_reg <= 1'b0;
                end
                else begin
                    count <= count - 1;
                end
            end
            else if (clear_reg)begin
                A_Q_reg <= {(2*width+1){1'b0}};
                B_reg <= {(width+1){1'b0}};
                valid_o <= 1'b0;
                busy_o <= 1'b0;
                clear_reg <= 1'b0;
                shift_count <= 5'b0;
                initialization <= 1'b1;
            end
            else if (start_flag && (!divisor))begin
                error_o <= 1'b1;
            end
        end
endmodule
