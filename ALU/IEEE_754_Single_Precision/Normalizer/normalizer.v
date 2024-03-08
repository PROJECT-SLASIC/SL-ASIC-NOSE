//////////////////////////////////////////////////////////////////////////////////
// Company: Hacettepe University
// Engineer: Cengizhan Caglayan
// 
// Create Date: 12.11.2023 11:23:53
// Design Name: Normalizer (IEEE-754 Floating Point)
// Module Name: normalizer
// Project Name: SLASIC
// 
// Revision:
//  - Revision 0.01 - File Created - 12/11/2023
//  - Revision 1.00 - First Stable Version - 12/11/2023
//////////////////////////////////////////////////////////////////////////////////

module normalizer(
    input clk,
    input rst,
    input start,
    output reg valid,
    output reg busy,

    input [31:0] max,
    input [31:0] min,
    input [31:0] in_data,

    output reg [31:0] out_data
    );
    
    // ADDER & DIVIDER REGISTERS & WIRES
    reg [31:0] D1;
    reg [31:0] D2;
    reg [31:0] A1;
    reg [31:0] A2;

    wire [31:0] result_div;
    wire [31:0] result_add;

    reg start_div = 0;
    reg start_add = 0;

    wire valid_div;
    wire valid_add;

    // DIVIDER INSTANCE
    divider DIV1 (
        .clk(clk),
        .rst(rst),
        .start(start_div),
        .valid(valid_div),
        .busy(),
        .dividened(D1),
        .divisor(D2),
        .out_reg(result_div)
    );

    // ADDER INSTANCE
    adder ADD1 (
        .clk(clk),
        .rst(rst),
        .start(start_add),
        .valid(valid_add),
        .busy(),
        .input1(A1),
        .input2(A2),
        .out(result_add)
    );

    // STATES
    reg [2:0] STATE;
    parameter IDLE                  = 0;
    parameter ADD_DIVIDEND_START    = 1;
    parameter ADD_DIVIDEND_VALID    = 2;
    parameter ADD_DIVISOR_START     = 3;
    parameter ADD_DIVISOR_VALID     = 4;
    parameter DIVISION_START        = 5;
    parameter DIVISION_VALID        = 6;

    always @(posedge clk or posedge rst) begin
        if (rst) begin 
            STATE <= IDLE;
            start_add <= 0;
            start_div <= 0;
            valid <= 0;
            busy <= 0;
        end
        else begin
            case (STATE) 
                IDLE : begin
                    valid <= 0;
                    A1 <= in_data;
                    A2 <= min;
                    A2[31] <= 1; // @TODO : SUBTRACTION
                    if (start) begin
                        STATE <= ADD_DIVIDEND_START;
                        busy <= 1;
                    end 
                end
                ADD_DIVIDEND_START : begin
                    start_add <= 1;
                    STATE <= ADD_DIVIDEND_VALID;
                end
                ADD_DIVIDEND_VALID : begin
                    start_add <= 0;
                    if (valid_add) begin
                        D1 <= result_add;
                        A1 <= max;
                        STATE <= ADD_DIVISOR_START;
                    end
                end
                ADD_DIVISOR_START : begin
                    start_add <= 1;
                    STATE <= ADD_DIVISOR_VALID;
                end
                ADD_DIVISOR_VALID : begin
                    start_add <= 0;
                    if (valid_add) begin
                        D2 <= result_add;
                        STATE <= DIVISION_START;
                    end
                end
                DIVISION_START : begin
                    start_div <= 1;
                    STATE <= DIVISION_VALID;
                end                
                DIVISION_VALID : begin
                    start_div <= 0;
                    if (valid_div) begin
                        out_data <= result_div;
                        STATE <= IDLE;
                        valid <= 1;
                        busy <= 0;
                    end
                end
            endcase
        end        
    end

endmodule
