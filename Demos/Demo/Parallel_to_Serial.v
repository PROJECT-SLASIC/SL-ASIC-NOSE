module Parallel_to_Serial#(parameter depth = 665)(
    input clk,
    input rst,
    input start,
    input [9:0] switch,
    output reg load_neuron,
    output reg busy,
    output reg valid,
    output reg [31:0] serial_o
    );
    wire [31:0] input_1;
    wire [31:0] input_2;
    wire [31:0] input_3;
    wire [31:0] input_4;
    wire [31:0] input_5;
    
    reg [31:0] array [0:5];
    reg [31:0] array_1 [0:depth-1];
    reg [31:0] array_2 [0:depth-1];
    reg [31:0] array_3 [0:depth-1];
    reg [31:0] array_4 [0:depth-1];
    reg [31:0] array_5 [0:depth-1];
    
    assign input_1 = (start) ? (array_1[switch-1]) : (input_1);
    assign input_2 = (start) ? (array_2[switch-1]) : (input_2);
    assign input_3 = (start) ? (array_3[switch-1]) : (input_3);
    assign input_4 = (start) ? (array_4[switch-1]) : (input_4);
    assign input_5 = (start) ? (array_5[switch-1]) : (input_5);
    
    initial begin
    $readmemh("feature0.mem",array_1);
    $readmemh("feature1.mem",array_2);
    $readmemh("feature2.mem",array_3);
    $readmemh("feature3.mem",array_4);
    $readmemh("feature4.mem",array_5);
    
    end
    
    
    
    reg [2:0] counter;
    always  @(posedge clk)begin
        
        if (rst)begin
            array[1]    <= 32'b0;
            array[2]    <= 32'b0;
            array[3]    <= 32'b0;
            array[4]    <= 32'b0;
            array[5]    <= 32'b0;
            counter<=0;
            busy<=0;
            valid<=0;
            serial_o<=0;
            load_neuron<=0;
        end
        else begin
            if(valid)valid<=0;
            if (start && !busy)begin
                array[1] <= input_1;
                array[2] <= input_2;
                array[3] <= input_3;
                array[4] <= input_4;
                array[5] <= input_5;
                busy <= 1'b1;
                load_neuron <= 1'b1;
            end
            else if (busy)begin
                serial_o <= array[counter];
                if(counter==3'b101)begin
                    counter <= 2'b0;
                    busy <= 1'b0;
                    valid <= 1'b1;
                    load_neuron <= 1'b0;
                end
                else begin
                    counter <= counter+1;
                    load_neuron <= 1'b0;
                end
            end
        end
    end
endmodule
