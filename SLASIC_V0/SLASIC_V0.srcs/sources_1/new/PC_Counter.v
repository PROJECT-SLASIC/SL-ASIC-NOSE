module PC_Counter_1#(parameter width = 32)(
    input clk,
    input rst_i,
    input stall,
    input [width-1:0] Pc_Next,
    output reg [width-1:0] pc
    );
    
    always @(posedge clk)begin
        if(rst_i)begin
            pc <= 32'h80000000;
        end
        else if (stall)begin
            pc <= pc;
        end
        else begin
            pc <= Pc_Next;
        end
    end
endmodule
