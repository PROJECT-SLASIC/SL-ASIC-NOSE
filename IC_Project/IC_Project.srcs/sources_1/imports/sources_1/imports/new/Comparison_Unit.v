module Comparison_Unit#(parameter width = 32)(
    input [width-1:0] A_i,
    input [width-1:0] B_i,
    input [2:0] cmp_op,
    output reg [width-1:0] Result_o
    );
    
    wire signed [width-1:0] A_i_wire = A_i;
    wire signed [width-1:0] B_i_wire = B_i;
    wire equal = (A_i==B_i) ? (1'b1):(1'b0);
    wire greater_than = (A_i>=B_i) ? (1'b1):(1'b0);
    
    always @(*)begin
        if(cmp_op==3'b000)begin        // Equal
            Result_o = (equal) ? (32'h00000001):(32'h00000000);
        end
        else if (cmp_op==3'b001)begin  // Not Equal
            Result_o = (!equal) ? (32'h00000001):(32'h00000000);
        end
        else if (cmp_op==3'b010)begin  // Greater
            Result_o = (!equal && greater_than) ? (32'h00000001):(32'h00000000);
        end
        else if (cmp_op==3'b011)begin  // Greater Than
            Result_o = (greater_than) ? (32'h00000001):(32'h00000000);
        end
        else if (cmp_op==3'b100)begin  // Less Than
            Result_o = (!greater_than) ? (32'h00000001):(32'h00000000);
        end
        else if (cmp_op==3'b101)begin  // Less Than signed
            Result_o = (A_i_wire<B_i_wire) ? (32'h00000001):(32'h00000000);
        end
        else if (cmp_op==3'b110)begin  // Greater Than Signed
            Result_o = (A_i_wire>=B_i_wire) ? (32'h00000001):(32'h00000000);
        end
        else begin
            Result_o = {(width){1'b0}};
        end
    end
endmodule
