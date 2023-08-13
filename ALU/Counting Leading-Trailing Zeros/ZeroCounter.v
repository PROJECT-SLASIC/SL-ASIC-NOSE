module ZeroCounter (
    input [31:0] data,
    input leading_or_trailing,  // 1 for leading, 0 for trailing
    output reg [5:0] count
);

always @(*) begin
    if (leading_or_trailing) begin
        // Priority encoder for leading zeros
        if (data[31]) count = 6'd0;
        else if (data[30:0] == 0) count = 6'd32;
        else if (data[30]) count = 6'd1;
        else if (data[29:0] == 0) count = 6'd31;
        else if (data[29]) count = 6'd2;
        else if (data[28:0] == 0) count = 6'd30;
        else if (data[28]) count = 6'd3;
        else if (data[27:0] == 0) count = 6'd29;
        else if (data[27]) count = 6'd4;
        else if (data[26:0] == 0) count = 6'd28;
        else if (data[26]) count = 6'd5;
        else if (data[25:0] == 0) count = 6'd27;
        else if (data[25]) count = 6'd6;
        else if (data[24:0] == 0) count = 6'd26;
        else if (data[24]) count = 6'd7;
        else if (data[23:0] == 0) count = 6'd25;
        else if (data[23]) count = 6'd8;
        else if (data[22:0] == 0) count = 6'd24;
        else if (data[22]) count = 6'd9;
        else if (data[21:0] == 0) count = 6'd23;
        else if (data[21]) count = 6'd10;
        else if (data[20:0] == 0) count = 6'd22;
        else if (data[20]) count = 6'd11;
        else if (data[19:0] == 0) count = 6'd21;
        else if (data[19]) count = 6'd12;
        else if (data[18:0] == 0) count = 6'd20;
        else if (data[18]) count = 6'd13;
        else if (data[17:0] == 0) count = 6'd19;
        else if (data[17]) count = 6'd14;
        else if (data[16:0] == 0) count = 6'd18;
        else if (data[16]) count = 6'd15;
        else if (data[15:0] == 0) count = 6'd17;
        else if (data[15]) count = 6'd16;
        else if (data[14]) count = 6'd17;
        else if (data[13]) count = 6'd18;
        else if (data[12]) count = 6'd19;
        else if (data[11]) count = 6'd20;
        else if (data[10]) count = 6'd21;
        else if (data[9]) count = 6'd22;
        else if (data[8]) count = 6'd23;
        else if (data[7]) count = 6'd24;
        else if (data[6]) count = 6'd25;
        else if (data[5]) count = 6'd26;
        else if (data[4]) count = 6'd27;
        else if (data[3]) count = 6'd28;
        else if (data[2]) count = 6'd29;
        else if (data[1]) count = 6'd30;
        else count = 6'd31;
    end else begin
        // Priority encoder for trailing zeros
        if (data[0]) count = 6'd0;
        else if (data[31:1] == 0) count = 6'd32;
        else if (data[1]) count = 6'd1;
        else if (data[31:2] == 0) count = 6'd31;
        else if (data[2]) count = 6'd2;
        else if (data[31:3] == 0) count = 6'd30;
        else if (data[3]) count = 6'd3;
        else if (data[31:4] == 0) count = 6'd29;
        else if (data[4]) count = 6'd4;
        else if (data[31:5] == 0) count = 6'd28;
        else if (data[5]) count = 6'd5;
        else if (data[31:6] == 0) count = 6'd27;
        else if (data[6]) count = 6'd6;
        else if (data[31:7] == 0) count = 6'd26;
        else if (data[7]) count = 6'd7;
        else if (data[31:8] == 0) count = 6'd25;
        else if (data[8]) count = 6'd8;
        else if (data[31:9] == 0) count = 6'd24;
        else if (data[9]) count = 6'd9;
        else if (data[31:10] == 0) count = 6'd23;
        else if (data[10]) count = 6'd10;
        else if (data[31:11] == 0) count = 6'd22;
        else if (data[11]) count = 6'd11;
        else if (data[31:12] == 0) count = 6'd21;
        else if (data[12]) count = 6'd12;
        else if (data[31:13] == 0) count = 6'd20;
        else if (data[13]) count = 6'd13;
        else if (data[31:14] == 0) count = 6'd19;
        else if (data[14]) count = 6'd14;
        else if (data[31:15] == 0) count = 6'd18;
        else if (data[15]) count = 6'd15;
        else if (data[31:16] == 0) count = 6'd17;
        else if (data[16]) count = 6'd16;
        else if (data[31:17] == 0) count = 6'd16;
        else if (data[17]) count = 6'd17;
        else if (data[31:18] == 0) count = 6'd18;
        else if (data[18]) count = 6'd19;
        else if (data[31:19] == 0) count = 6'd19;
        else if (data[19]) count = 6'd20;
        else if (data[31:20] == 0) count = 6'd20;
        else if (data[20]) count = 6'd21;
        else if (data[31:21] == 0) count = 6'd21;
        else if (data[21]) count = 6'd22;
        else if (data[31:22] == 0) count = 6'd22;
        else if (data[22]) count = 6'd23;
        else if (data[31:23] == 0) count = 6'd23;
        else if (data[23]) count = 6'd24;
        else if (data[31:24] == 0) count = 6'd24;
        else if (data[24]) count = 6'd25;
        else if (data[31:25] == 0) count = 6'd25;
        else if (data[25]) count = 6'd26;
        else if (data[31:26] == 0) count = 6'd26;
        else if (data[26]) count = 6'd27;
        else if (data[31:27] == 0) count = 6'd27;
        else if (data[27]) count = 6'd28;
        else if (data[31:28] == 0) count = 6'd28;
        else if (data[28]) count = 6'd29;
        else if (data[31:29] == 0) count = 6'd29;
        else if (data[29]) count = 6'd30;
        else if (data[31:30] == 0) count = 6'd30;
        else if (data[30]) count = 6'd31;
        else count = 6'd32; // If data[31] == 1
    end
end

endmodule
