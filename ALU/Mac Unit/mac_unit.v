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
