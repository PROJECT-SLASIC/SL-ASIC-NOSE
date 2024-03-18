module Logic_Unit#(parameter width = 32)(
    input [width-1:0] A_i,
    input [width-1:0] B_i,
    input [1:0] logic_op,
    output reg [width-1:0] Result_o
    );
    always @(*)begin
        if(logic_op==2'b00)begin        // AND
            Result_o = A_i & B_i;
        end
        else if (logic_op==2'b01)begin  // XOR
            Result_o = A_i ^ B_i;
        end
        else if (logic_op==2'b10)begin  // OR
            Result_o = A_i | B_i;
        end
        else begin
            Result_o = {(width){1'b0}};
        end
    end
endmodule
