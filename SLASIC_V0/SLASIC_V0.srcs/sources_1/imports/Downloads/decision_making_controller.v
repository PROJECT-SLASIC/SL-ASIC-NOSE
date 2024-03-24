module decision_making_controller (
	input  clk      ,
	input  rst      ,
	// I2C Module Connections
	output reg i2c_start,
	input  i2c_busy ,
	input  i2c_valid,
	// MLP Module Connections
	output reg mlp_start,
	input  mlp_busy ,
	input  mlp_valid,
	input  mlp_ready,
	// LCD Module Connections
	output reg lcd_start,
	// Control Signals
	input  start    ,
	input  real_time,
	output reg done
);

	reg [1:0] STATE       ;
	parameter IDLE  = 2'd0;
	parameter GET   = 2'd1;
	parameter RUN   = 2'd2;
	parameter SET   = 2'd3;

	always @(posedge clk) begin
		if (rst) begin
			STATE = IDLE;
		end
		else begin
			case (STATE)
				IDLE : begin
					if (start && mlp_ready) begin
						if (real_time) begin
							i2c_start <= 1;
							STATE     <= GET;
						end
						else begin
							mlp_start <= 1;
							STATE     <= RUN;
						end
					end
				end

				GET : begin
					if (i2c_busy) begin
						i2c_start <= 0;
					end
					if (i2c_valid) begin
						mlp_start <= 1;
						STATE     <= RUN;
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
                        STATE     <= GET;
                    end
                    else begin
                        STATE     <= IDLE;
                    end
				end
			endcase
		end
	end

endmodule