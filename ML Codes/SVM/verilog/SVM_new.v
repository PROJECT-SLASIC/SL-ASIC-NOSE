module SVM(
    input clk,
    input rst,
    input [31:0] i0,
    input [31:0] i1,
    input [31:0] i2,
    input [31:0] i3,
    input [31:0] i4,
    input [31:0] temp,
    output reg [31:0] predict
);

wire [31:0] maxval, maxval1, maxval2;
reg [31:0] weight [0:5][0:5];
reg [31:0] sum0,sum1,sum2,sum3,sum4,sum5; 
reg [31:0] pred_matrix [0:4];

initial begin
    $readmemh("weightbias.mem" weight);
end
    always@*begin
        sum0 <= weight[0][0]+weight[0][1]+weight[0][2]+weight[0][3]+weight[0][4]+weight[0][5];
        sum1 <= weight[1][0]+weight[1][1]+weight[1][2]+weight[1][3]+weight[1][4]+weight[1][5];
        sum2 <= weight[2][0]+weight[2][1]+weight[2][2]+weight[2][3]+weight[2][4]+weight[2][5];
        sum3 <= weight[3][0]+weight[3][1]+weight[3][2]+weight[3][3]+weight[3][4]+weight[3][5];
        sum4 <= weight[4][0]+weight[4][1]+weight[4][2]+weight[4][3]+weight[4][4]+weight[4][5];
    end

    always@(posedge clk or posedge rst) begin
        if(rst) begin
            predict <= 32'b0; 
        end     
        else begin
            pred_matrix[0] <= res0 + weight[5][0];
            pred_matrix[1] <= res1 + weight[5][1];
            pred_matrix[2] <= res2 + weight[5][2];
            pred_matrix[3] <= res3 + weight[5][3];
            pred_matrix[4] <= res4 + weight[5][4];
            if(pred_matrix[0] > pred_matrix[1]) begin
                maxval1 <= pred_matrix[0];
            end
            else begin
                maxval1 <= pred_matrix[1];
            end
            if (pred_matrix[2] > pred_matrix[3]) begin
                maxval2 <= pred_matrix[2];
            end
            else begin
                maxval2 <= pred_matrix[3];
            end
            if (maxval1 > maxval2) begin
                maxval <= maxval1;
            end
            else begin
                maxval <= maxval2;
            end
            if(pred_matrix[4] > maxval) begin
                predict <= pred_matrix[4];
            end
            else begin
                predict <= maxval;
            end
        end
    end

multiplier mult0(
    .clk(clk),
    .rst(rst),
    .rs1(i0),  // IEEE 754 single precision
    .rs2(sum0),  // IEEE 754 single precision
    .start(start),
    .result(res0),  // IEEE 754 single precision
    .valid,
    .busy
);
multiplier mult1(
    .clk(clk),
    .rst(rst),
    .rs1(i1),  // IEEE 754 single precision
    .rs2(sum1),  // IEEE 754 single precision
    .start(start),
    .result(res1),  // IEEE 754 single precision
    .valid,
    .busy
);
multiplier mult2(
    .clk(clk),
    .rst(rst),
    .rs1(i2),  // IEEE 754 single precision
    .rs2(sum2),  // IEEE 754 single precision
    .start(start),
    .result(res2),  // IEEE 754 single precision
    .valid,
    .busy
);
multiplier mult3(
    .clk(clk),
    .rst(rst),
    .rs1(i3),  // IEEE 754 single precision
    .rs2(sum3),  // IEEE 754 single precision
    .start(start),
    .result(res3),  // IEEE 754 single precision
    .valid,
    .busy
);
multiplier mult4(
    .clk(clk),
    .rst(rst),
    .rs1(i4),  // IEEE 754 single precision
    .rs2(sum4),  // IEEE 754 single precision
    .start(start),
    .result(res4),  // IEEE 754 single precision
    .valid,
    .busy
);

adder#(parameter exponent=8, mantissa=23) adder0
(
    .input1(res0),
    .input2(weight[5][0]),
    .clk(clk),
    .rst(rst),
    .start(start_addr),
    .valid,
    .busy,
    .out(s)
);



endmodule