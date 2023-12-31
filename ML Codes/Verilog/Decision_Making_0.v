module Decision_Making_0#(parameter width = 32,parameter shift = 4)(
    input clk,
    input rst,  // sw15 rst
    input start_i,    // sw14 start
    input [11:0] switch_for_data,    // sw11 - sw0 for input arrangment
    output reg [2:0] led // 100 for led 15 filter coffee, 010 for led 14 air, 001 for led 13 espresso
    );
    
    reg [width-1:0] Temperature [0:599];
    reg [width-1:0] Humidity [0:599];
    reg [width-1:0] Pressure [0:599];
    reg [width-1:0] VCO [0:599];
    
    initial begin
        $readmemh("Temperature.mem",Temperature);
        $readmemh("Humidity.mem",Humidity);
        $readmemh("Pressure.mem",Pressure);
        $readmemh("VCO.mem",VCO);
    end
    
    reg [2:0] state_0;
    parameter IDLE=0;
    parameter START=1;
    parameter SIGMOID=2;
    parameter VALID=3;
    
    reg [2:0] state_1;
    parameter layer1=0;
    parameter layer2=1;
    parameter layer3=2;
    
    reg [2:0] i;
    
    reg [width-1:0] first_layer [0:3];
    reg [width-1:0] w0_l1 [0:5];
    reg [width-1:0] w1_l1 [0:5];
    reg [width-1:0] w2_l1 [0:5];
    reg [width-1:0] w3_l1 [0:5];
    
    reg [width-1:0] second_layer [0:5];
    reg [width-1:0] second_layer_bias [0:5];
    reg [width-1:0] w0_l2 [0:4];
    reg [width-1:0] w1_l2 [0:4];
    reg [width-1:0] w2_l2 [0:4];
    reg [width-1:0] w3_l2 [0:4];
    reg [width-1:0] w4_l2 [0:4];
    reg [width-1:0] w5_l2 [0:4];
    
    reg [width-1:0] third_layer [0:4];
    reg [width-1:0] third_layer_bias [0:4];
    reg [width-1:0] w0_l3 [0:2];
    reg [width-1:0] w1_l3 [0:2];
    reg [width-1:0] w2_l3 [0:2];
    reg [width-1:0] w3_l3 [0:2];
    reg [width-1:0] w4_l3 [0:2];
    
    reg [width-1:0] fourth_layer [0:2];
    reg [width-1:0] fourth_layer_bias [0:2];
    
    reg [5:0] LUT [0:500];
    
    
    always @(posedge clk )begin
        if(rst)begin
            led <= 3'b0;
            state_0 <= 3'b0;
            state_1 <= 3'b0;
            i <= 3'b0;
        end
        else begin
            case (state_0)
                IDLE:begin
                    first_layer[0] <= Temperature[switch_for_data];
                    first_layer[1] <= Humidity[switch_for_data];
                    first_layer[2] <= Pressure[switch_for_data];
                    first_layer[3] <= VCO[switch_for_data];
                    if(start_i)begin
                        state <= START;
                    end
                end
                START:begin
                    case (state_1)
                        layer1:begin
                            if(i<6)begin
                                second_layer[i] <= first_layer[0] * w0_l1[i]
                                                +  first_layer[1] * w1_l1[i]
                                                +  first_layer[2] * w2_l1[i]
                                                +  first_layer[3] * w3_l1[i] 
                                                + second_layer_bias[i];
                            end
                            else begin
//                                // ReLu
//                                second_layer[0] <= (second_layer[0][width-1]) ? ({(width){1'b0}}) : (second_layer[0]);
//                                second_layer[1] <= (second_layer[1][width-1]) ? ({(width){1'b0}}) : (second_layer[1]);
//                                second_layer[2] <= (second_layer[2][width-1]) ? ({(width){1'b0}}) : (second_layer[2]);
//                                second_layer[3] <= (second_layer[3][width-1]) ? ({(width){1'b0}}) : (second_layer[3]);
//                                second_layer[4] <= (second_layer[4][width-1]) ? ({(width){1'b0}}) : (second_layer[4]);
//                                second_layer[5] <= (second_layer[5][width-1]) ? ({(width){1'b0}}) : (second_layer[5]);
                                
                                // Leaky ReLu
                                second_layer[0] <= (second_layer[0][width-1]) ? (second_layer[0] >> shift) : (second_layer[0]);
                                second_layer[1] <= (second_layer[1][width-1]) ? (second_layer[1] >> shift) : (second_layer[1]);
                                second_layer[2] <= (second_layer[2][width-1]) ? (second_layer[2] >> shift) : (second_layer[2]);
                                second_layer[3] <= (second_layer[3][width-1]) ? (second_layer[3] >> shift) : (second_layer[3]);
                                second_layer[4] <= (second_layer[4][width-1]) ? (second_layer[4] >> shift) : (second_layer[4]);
                                second_layer[5] <= (second_layer[5][width-1]) ? (second_layer[5] >> shift) : (second_layer[5]);
                                i <= 3'b0;
                                state_1 <= layer2;
                            end
                        end
                        layer2:begin
                            if(i<5)begin
                                third_layer[i] <= second_layer[0] * w0_l2[i]
                                               +  second_layer[1] * w1_l2[i]
                                               +  second_layer[2] * w2_l2[i]
                                               +  second_layer[3] * w3_l2[i] 
                                               +  second_layer[4] * w4_l2[i] 
                                               +  second_layer[5] * w5_l2[i] 
                                               +  third_layer_bias[i];
                            end
                            else begin
//                                // ReLu
//                                third_layer[0] <= (third_layer[0][width-1]) ? ({(width){1'b0}}) : (third_layer[0]);
//                                third_layer[1] <= (third_layer[1][width-1]) ? ({(width){1'b0}}) : (third_layer[1]);
//                                third_layer[2] <= (third_layer[2][width-1]) ? ({(width){1'b0}}) : (third_layer[2]);
//                                third_layer[3] <= (third_layer[3][width-1]) ? ({(width){1'b0}}) : (third_layer[3]);
//                                third_layer[4] <= (third_layer[4][width-1]) ? ({(width){1'b0}}) : (third_layer[4]);
                                
                                // Leaky ReLu
                                third_layer[0] <= (third_layer[0][width-1]) ? (third_layer[0] >> shift) : (third_layer[0]);
                                third_layer[1] <= (third_layer[1][width-1]) ? (third_layer[1] >> shift) : (third_layer[1]);
                                third_layer[2] <= (third_layer[2][width-1]) ? (third_layer[2] >> shift) : (third_layer[2]);
                                third_layer[3] <= (third_layer[3][width-1]) ? (third_layer[3] >> shift) : (third_layer[3]);
                                third_layer[4] <= (third_layer[4][width-1]) ? (third_layer[4] >> shift) : (third_layer[4]);
                                i <= 3'b0;
                                state_1 <= layer3;
                            end
                        end
                        layer3:begin
                            if(i<2)begin
                                fourth_layer[i] <= third_layer[0] * w0_l3[i]
                                                +  third_layer[1] * w1_l3[i]
                                                +  third_layer[2] * w2_l3[i]
                                                +  third_layer[3] * w3_l3[i] 
                                                +  third_layer[4] * w4_l3[i] 
                                                +  fourth_layer_bias[i];
                            end
                            else begin
                                i <= 3'b0;
                                state_1 <= layer1;
                                state_0 <= SIGMOID;
                            end
                        end
                    endcase
                end
                SIGMOID:begin
                    fourth_layer[0] <= LUT [fourt_layer];
                    fourth_layer[1] <= LUT [fourt_layer];
                    fourth_layer[2] <= LUT [fourt_layer];
                    state_0 <= VALID;
                end
                VALID:begin
                    state_0 <= IDLE;
                end
            endcase
        end
    end
endmodule
