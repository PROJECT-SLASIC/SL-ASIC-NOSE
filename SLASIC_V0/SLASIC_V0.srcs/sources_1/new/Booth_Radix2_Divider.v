module Booth_Radix2_Divider#(parameter width = 32)(
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
            else if (start_reg )begin
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
