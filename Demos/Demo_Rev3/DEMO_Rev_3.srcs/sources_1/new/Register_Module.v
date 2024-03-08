module Register_Module#(parameter depth = 21)(
    input clk,
    input rst,
    input write,
    input read_1,
    input [7:0] index_1,
    input [7:0] data_in,
    output led,
    output [7:0] data_out_1,
    //
    output [31:0] data_1,   // 0x40 - 0x43
    output [31:0] data_2,   // 0x44 - 0x47
    output [31:0] data_3,   // 0x48 - 0x4b
    output [31:0] data_4,   // 0x4c - 0x4f
    output [31:0] data_5,   // 0x50 - 0x53
    output method_slc,      // 0x54[0]
    output start_rg         // 0x54[1]
    );
    
    assign data_out_1 = (read_1) ? (internal_register[index_1[4:0]]) : (8'b0);
    
    reg [7:0] internal_register [0:depth-1]; // start from 0x40
    
    assign data_1 = {internal_register[3],internal_register[2],internal_register[1],internal_register[0]};
    assign data_2 = {internal_register[7],internal_register[6],internal_register[5],internal_register[4]};
    assign data_3 = {internal_register[11],internal_register[10],internal_register[9],internal_register[8]};
    assign data_4 = {internal_register[15],internal_register[14],internal_register[13],internal_register[12]};
    assign data_5 = {internal_register[19],internal_register[18],internal_register[17],internal_register[16]};
    assign method_slc = internal_register[20][0];
    assign start_rg = internal_register[20][1];
//    reg leds;
//    assign led = (leds) ? (1'b1) : (1'b0);
    
    always @(posedge clk)begin
        if(rst)begin
            internal_register [0] <= 8'b0;
            internal_register [1] <= 8'b0;
            internal_register [2] <= 8'b0;
            internal_register [3] <= 8'b0;
            internal_register [4] <= 8'b0;
            internal_register [5] <= 8'b0;
            internal_register [6] <= 8'b0;
            internal_register [7] <= 8'b0;
            internal_register [8] <= 8'b0;
            internal_register [9] <= 8'b0;
            internal_register [10] <= 8'b0;
            internal_register [11] <= 8'b0;
            internal_register [12] <= 8'b0;
            internal_register [13] <= 8'b0;
            internal_register [14] <= 8'b0;
            internal_register [15] <= 8'b0;
            internal_register [16] <= 8'b0;
            internal_register [17] <= 8'b0;
            internal_register [18] <= 8'b0;
            internal_register [19] <= 8'b0;
            internal_register [20] <= 8'b0;
        end
        else begin
            internal_register[index_1[4:0]] <= (write) ? (data_in) : (internal_register[index_1[4:0]]);
//            internal_reg_20 <= (index_1==8'h54 && write) ? (data_in) : (internal_reg_20);
//            start_rg <= internal_reg_20[1];
//            if (index_1==8'h54 &&  data_in==8'h02)begin
//                start_rg <= 1'b1;
//                leds <= 1'b1;
//            end 
            if(internal_register[20][1])begin
                internal_register[20][1] <= 1'b0;
            end
        end
    end
endmodule