module parallel_to_serial
(
    input clk,
    input rst,
    input start,
    output reg busy,
    output reg valid,
    
    input [31:0] input1,
    input [31:0] input2,
    input [31:0] input3,
    input [31:0] input4,
    input [31:0] input5,
    
    output reg load_neuron,
    output reg [31:0] serial_o
);
    
    wire [31:0] array [0:5];
    reg [2:0] counter;
    
    assign array[1] = input1;
    assign array[2] = input2;
    assign array[3] = input3;
    assign array[4] = input4;
    assign array[5] = input5;
    
    always  @(posedge clk) begin
        
        if (rst)begin
            counter <= 0;
            busy <= 0;
            valid <= 0;
            serial_o <= 0;
            load_neuron <= 0;
        end
        else begin
            if (valid) begin
                valid <= 0;
            end
            if (start && !busy)begin
                busy <= 1'b1;
                load_neuron <= 1'b1;
            end
            else if (busy) begin
                serial_o <= array[counter];
                if(counter != 3'b101) begin
                    counter <= counter + 1;
                    load_neuron <= 1'b0;
                end
                else begin
                    counter <= 2'b0;
                    busy <= 1'b0;
                    valid <= 1'b1;
                    load_neuron <= 1'b0;
                end
            end
        end
    end
endmodule
