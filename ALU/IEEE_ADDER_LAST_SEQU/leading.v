module leading(
    input [23:0] data,
    output reg [4:0] count
);

always @(*) begin
        if       (data[23]) count =  5'd0;
        else if  (data[22]) count =  5'd1;
        else if  (data[21]) count =  5'd2;
        else if  (data[20]) count =  5'd3;
        else if  (data[19]) count =  5'd4;
        else if  (data[18]) count =  5'd5;
        else if  (data[17]) count =  5'd6;
        else if  (data[16]) count =  5'd7;
        else if  (data[15]) count =  5'd8;
        else if  (data[14]) count =  5'd9;
        else if  (data[13]) count = 5'd10;
        else if  (data[12]) count = 5'd11;
        else if  (data[11]) count = 5'd12;
        else if  (data[10]) count = 5'd13;
        else if  (data[9])  count = 5'd14;
        else if  (data[8])  count = 5'd15;
        else if  (data[7])  count = 5'd16;
        else if  (data[6])  count = 5'd17;
        else if  (data[5])  count = 5'd18;
        else if  (data[4])  count = 5'd19;
        else if  (data[3])  count = 5'd20;
        else if  (data[2])  count = 5'd21;
        else if  (data[1])  count = 5'd22;
        else count = 5'd23;
    end
endmodule
