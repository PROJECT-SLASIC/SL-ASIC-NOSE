module decision_making_controller (
	input             clk            ,
	input             rst            ,
	// I2C Module Connections
	input             i2c_busy       ,
	input             i2c_valid      ,
	input      [ 7:0] i2c_index      ,
	input      [ 7:0] i2c_data_in    ,
	output reg [ 7:0] i2c_data_out   ,
	// MLP Module Connections
	output reg        mlp_start      ,
	input             mlp_busy       ,
	input             mlp_valid      ,
	input             mlp_ready      ,
	// LCD Module Connections
	output reg        lcd_start      ,
	// Data Memory Connections
	inout      [31:0] dm_data        ,
	output reg [31:0] dm_address     ,
	output reg        dm_read_enable ,
	output reg        dm_write_enable,
	// Control Signals
	input             start          ,
	input             real_time      ,
	output reg        done
);

    parameter I2C_CTRL_VAL = 8'h02;
    
    parameter SENSOR_DATA_0_REGISTER_ADDRESS_OFFSET = 8'h04;
    parameter SENSOR_DATA_1_REGISTER_ADDRESS_OFFSET = 8'h08;
    parameter SENSOR_DATA_2_REGISTER_ADDRESS_OFFSET = 8'h0c;
    parameter SENSOR_DATA_3_REGISTER_ADDRESS_OFFSET = 8'h10;
    parameter SENSOR_DATA_4_REGISTER_ADDRESS_OFFSET = 8'h14;
    parameter SENSOR_DATA_5_REGISTER_ADDRESS_OFFSET = 8'h18;
    parameter SENSOR_DATA_6_REGISTER_ADDRESS_OFFSET = 8'h1c;
    parameter SENSOR_DATA_7_REGISTER_ADDRESS_OFFSET = 8'h20;
    parameter SENSOR_DATA_8_REGISTER_ADDRESS_OFFSET = 8'h24;

	reg [1:0] STATE       ;
	parameter IDLE  = 2'd0;
	parameter GET   = 2'd1;
	parameter RUN   = 2'd2;
	parameter SET   = 2'd3;
	
	reg        i2c_started = 0;
	reg [3:0]  i2c_data_counter = 4'd0;
	reg [2:0]  i2c_word_counter = 3'd0;
	reg [31:0] i2c_sensor_data;
	
	assign dm_data = i2c_sensor_data;

	always @(posedge clk) begin
		if (rst) begin
			STATE = IDLE;
		end
		else begin
			case (STATE)
				IDLE : begin
					if (start && mlp_ready) begin
						if (real_time) begin
							STATE <= GET;
						end
						else begin
							mlp_start <= 1;
							STATE     <= RUN;
						end
					end
				end

				GET : begin
				    if (i2c_busy) begin
				        if (i2c_valid) begin
				            if (i2c_data_in  == I2C_CTRL_VAL) begin
				                i2c_started <= 1;
				            end
				        end
				        if (i2c_started) begin
				            if (i2c_valid) begin
				                i2c_word_counter <= i2c_word_counter + 1;
				                case (i2c_word_counter)
				                    3'd0 : begin
				                        i2c_sensor_data[31:24] <= i2c_data_in;
				                    end
				                    3'd1 : begin
				                        i2c_sensor_data[23:16] <= i2c_data_in;
				                    end
				                    3'd2 : begin
				                        i2c_sensor_data[15:8]  <= i2c_data_in;
				                    end
				                    3'd3 : begin
				                        i2c_sensor_data[7:0]   <= i2c_data_in;
				                    end
				                endcase
				            end
				            if (i2c_word_counter == 3'd4) begin
				                i2c_word_counter <= 3'd0;
				                i2c_data_counter <= i2c_data_counter + 1;
				                
                                dm_write_enable <= 1;
                                
                                case (i2c_data_counter)
                                    4'd0 : begin
                                        dm_address <= {24'b0, SENSOR_DATA_0_REGISTER_ADDRESS_OFFSET};
                                    end
                                    4'd1 : begin
                                        dm_address <= {24'b0, SENSOR_DATA_1_REGISTER_ADDRESS_OFFSET};
                                    end
                                    4'd2 : begin
                                        dm_address <= {24'b0, SENSOR_DATA_2_REGISTER_ADDRESS_OFFSET};
                                    end
                                    4'd3 : begin
                                        dm_address <= {24'b0, SENSOR_DATA_3_REGISTER_ADDRESS_OFFSET};
                                    end
                                    4'd4 : begin
                                        dm_address <= {24'b0, SENSOR_DATA_4_REGISTER_ADDRESS_OFFSET};
                                    end
                                    4'd5 : begin
                                        dm_address <= {24'b0, SENSOR_DATA_5_REGISTER_ADDRESS_OFFSET};
                                    end
                                    4'd6 : begin
                                        dm_address <= {24'b0, SENSOR_DATA_6_REGISTER_ADDRESS_OFFSET};
                                    end
                                    4'd7 : begin
                                        dm_address <= {24'b0, SENSOR_DATA_7_REGISTER_ADDRESS_OFFSET};
                                    end
                                    4'd8 : begin
                                        dm_address <= {24'b0, SENSOR_DATA_8_REGISTER_ADDRESS_OFFSET};
                                    end
                                endcase
				            end
				            else begin
				                dm_write_enable <= 0;
				            end
				            if (i2c_data_counter == 4'd9) begin
				                i2c_word_counter <= 3'd0;
				                i2c_data_counter <= 4'd0;
				                STATE <= RUN;
				            end
				        end 
				    end
				end

				RUN : begin
					if (mlp_busy) begin
						mlp_start <= 0;
					end
					if (mlp_valid) begin
						lcd_start <= 1;
						STATE     <= RUN;
					end
				end

				SET : begin
					lcd_start <= 0;
					if (real_time) begin
						STATE <= GET;
					end
					else begin
						STATE <= IDLE;
					end
				end
			endcase
		end
	end

endmodule