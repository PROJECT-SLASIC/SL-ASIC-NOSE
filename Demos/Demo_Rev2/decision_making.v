module decision_making
(     
    input clk,
    input rst,
    input start,
    output reg valid,
    output reg busy,
    
    input method_select,
    
    input [32:0] input1,
    input [32:0] input2,
    input [32:0] input3,
    input [32:0] input4,
    input [32:0] input5,
    
    output reg [2:0]class
);

    reg start_reg;
    reg internal_rst;
    wire total_reset;

    assign total_reset = rst || internal_rst;
    
    wire load_neuron;
    wire [31:0] datas;
    wire paralel_busy;
    wire paralel_valid;
    reg start_paralel;

    parallel_to_serial SERIALIZE
    (
        .clk(clk),
        .rst(rst),
        .start(start_paralel),
        .busy(paralel_busy),
        .valid(paralel_valid),
        
        .input1(input1),
        .input2(input2),
        .input3(input3),
        .input4(input4),
        .input5(input5),
        
        .load_neuron(load_neuron),
        .serial_o(datas)
    );

    reg mlp_start;
    wire mlp_valid;
    wire mlp_busy;
    wire [2:0] mlp_class;
    
    feed_forward MLP
    (
        .clk(clk),
        .rst(rst),
        .data(datas),
        .load_neuron(load_neuron),
        .start(mlp_start),
        .first_layer(4'd5),
        .second_layer(4'd15),
        .third_layer(4'd8),
        .fourth_layer(4'd6),
        .oldu(),
        .class(mlp_class),
        .busy(mlp_busy),
        .valid(mlp_valid)
    );
    
	reg dt_start;
    wire dt_valid;
    wire dt_busy;
    wire [2:0] dt_class;
    
    decision_tree DT
    (
        .clk(clk),
        .rst(rst),
        .start(dt_start),
        .busy(dt_busy),
        .valid(dt_valid),
        
        .input1(input1),
        .input2(input2),
        .input3(input3),
        .input4(input4),
        .input5(input5),
        
        .class(dt_class)
    );
    
    reg [3:0]steps;
    
    always @(posedge clk)begin
        if(rst)begin
            steps <= 0;
            start_paralel <= 0;
            mlp_start <= 0;
            start_reg <= 0;
            busy <= 0;
            valid <= 0;
        end

        else begin
            if (valid) begin
                valid <= 0;
            end
            if (start)begin 
                start_reg <= 1;
            end
            if (start_reg) begin
			
				if (method_select) begin
					case(steps)
						0:begin
							steps <= 1;
							dt_start <= 1;
							busy <= 1;
						end
						1:begin
							dt_start <= 0;
							if(dt_valid) begin
								steps <= 0;
								valid <= 1;
								busy <= 0;
								start_reg <= 0;
								class <= dt_class;
							end
						end
					endcase
				end
				if (~method_select) begin
					case(steps)
						0:begin
							start_paralel <= 1;
							steps <= 1;
							busy <= 1;
						end
						1:begin
							start_paralel <= 0;
							if(paralel_valid) begin
								steps <= 2;
							end

						end
						2:begin
							mlp_start <= 1;
							steps <= 3;
						end
						3:begin
							mlp_start <= 0;
							if(mlp_valid) begin
								valid <= 1;
								busy <= 0;
								start_reg <= 0;
								steps <= 0;
								class <= mlp_class;
							end
						end
					endcase
				end
            end
        end
    end
endmodule
