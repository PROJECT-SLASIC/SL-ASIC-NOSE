module SVM(
    input clk,
    input rst,
    input [31:0] in_0,
    input [31:0] in_1,
    input [31:0] in_2,
    input [31:0] in_3,
    input [31:0] in_4,
    input [31:0] in_5,
    input [31:0] in_6,
    input [31:0] in_7,
    input [31:0] in_8,
    input start,
    output reg [31:0] predict
);

reg [31:0] weight [0:21][0:20];

initial begin
    $readmemh("weightbias.mem", weight);
end

   wire [31:0] inputs[8:0]; // Array to hold inputs for easier indexing
assign inputs[0] = in_0;
assign inputs[1] = in_1;
assign inputs[2] = in_2;
assign inputs[3] = in_3;
assign inputs[4] = in_4;
assign inputs[5] = in_5;
assign inputs[6] = in_6;
assign inputs[7] = in_7;
assign inputs[8] = in_8;

genvar i;
generate
    for(i=0;i<22;i=i+1) begin: 
        for(j=0;j<9;j=j+1) begin : mult_1
            multiplier mult1(
                .clk(clk),
                .rst(rst),
                .rs1(inputs[j]),  // IEEE 754 single precision
                .rs2(weight[i][j]),  // IEEE 754 single precision
                .start(start),
                .result(),  // IEEE 754 single precision
                .valid(),
                .busy()
            );
        end
    end
endgenerate
endmodule


