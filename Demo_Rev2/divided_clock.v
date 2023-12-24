module divided_clock
(
    input clk,
    input rst,
    output div_clk
);

    reg counter=0;
	
    assign div_clk = counter;
	
    always @(posedge clk)begin
        if (rst)begin
            counter <= counter + 1;
        end
        else begin
            counter <= counter + 1;
        end
    end
	
endmodule
