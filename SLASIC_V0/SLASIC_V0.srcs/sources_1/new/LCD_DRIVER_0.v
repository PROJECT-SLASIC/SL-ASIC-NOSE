module LCD_DRIVER_0(
    input clk,          //
    input rst,          //
    input start_lcd,    //
    
    output scl,         //
    inout sda           //
    );
    
    localparam TIME_20ms = 2000000;
    localparam TIME_5ms = 500000;
    localparam TIME_3ms = 300000;
    
    reg start_dut;
    reg [7:0] i2c_addrr_dut;
    reg [7:0] i2c_data_addrr_i_dut;
    reg [7:0] i2c_data_i_dut;
    
    wire [7:0] i2c_data_o_dut;
    wire resend_dut;
    
    wire busy_dut;
    wire valid_dut;
    
    I2C_0 I2C_0_0(
        . clk(clk),
        . rst(rst),
        
        . start_i(start_dut),
        . i2c_addrr(i2c_addrr_dut),
        . i2c_data_addrr_i(i2c_data_addrr_i_dut),
        . i2c_data_i(i2c_data_i_dut),
        
        . i2c_data_o(i2c_data_o_dut),
        . resend(resend_dut),
        // I2C Ports
        . sda(sda),
        . scl(scl),
        . busy(busy_dut),
        . valid(valid_dut)
    );
    
    reg [2:0] state;
    parameter IDLE = 0;
    parameter INITIALIZE_LCD  = 1;
    parameter WRITE_LCD  = 2;
    parameter COMPLETED  = 3;
    
    reg [7:0] sequences [15:0][2:0];
    
    reg [9:0] counter_1;
    reg [31:0] counter;
    reg counter_reset;
    reg wait_ok;
    reg lcd_initialize_ok;
    
    reg [2:0] state_1;
    parameter PART_1 = 0;
    parameter PART_2  = 1;
    
    initial begin
        sequences[0][0] = 8'h4e; sequences[0][1] = 8'h0C; sequences[0][2] = 8'h08; // high nibble  - blink cursor
        sequences[1][0] = 8'h4e; sequences[1][1] = 8'hfC; sequences[1][2] = 8'hf8; 
        
        sequences[2][0] = 8'h4e; sequences[2][1] = 8'h8C; sequences[2][2] = 8'h88; // high nibble - ddram position
        sequences[3][0] = 8'h4e; sequences[3][1] = 8'h0C; sequences[3][2] = 8'h08;
        
        sequences[4][0] = 8'h4e; sequences[4][1] = 8'h5D; sequences[4][2] = 8'h59; // high nibble - S into 1_1
        sequences[5][0] = 8'h4e; sequences[5][1] = 8'h3D; sequences[5][2] = 8'h39;
        
        sequences[6][0] = 8'h4e; sequences[6][1] = 8'h4D; sequences[6][2] = 8'h49; // high nibble - L into 1_2
        sequences[7][0] = 8'h4e; sequences[7][1] = 8'hCD; sequences[7][2] = 8'hC9;
        
        sequences[8][0] = 8'h4e; sequences[8][1] = 8'h4D; sequences[8][2] = 8'h49; // high nibble - A into 1_1
        sequences[9][0] = 8'h4e; sequences[9][1] = 8'h1D; sequences[9][2] = 8'h19;
        
        sequences[10][0] = 8'h4e; sequences[10][1] = 8'h5D; sequences[10][2] = 8'h59; // high nibble - S into 1_1
        sequences[11][0] = 8'h4e; sequences[11][1] = 8'h3D; sequences[11][2] = 8'h39;
        
        sequences[12][0] = 8'h4e; sequences[12][1] = 8'h4D; sequences[12][2] = 8'h49; // high nibble - I into 1_2
        sequences[13][0] = 8'h4e; sequences[13][1] = 8'h9D; sequences[13][2] = 8'h99;
        
        sequences[14][0] = 8'h4e; sequences[14][1] = 8'h4D; sequences[14][2] = 8'h49; // high nibble - C into 1_1
        sequences[15][0] = 8'h4e; sequences[15][1] = 8'h3D; sequences[15][2] = 8'h39;
    end
    
    
    always @(posedge clk)begin
        if (rst)begin
            start_dut <= 1'b0;
            i2c_addrr_dut <= 8'b0;
            i2c_data_addrr_i_dut <= 8'b0;
            i2c_data_i_dut <= 8'b0;
            
            state <= 3'b0;
            state_1 <= 3'b0;
            wait_ok <= 1'b0;
            lcd_initialize_ok <= 1'b0;
            
            counter <= 32'b0;
            counter_1 <= 10'b0;
            counter_reset <= 1'b0;
        end
        else begin
            if(counter_reset)begin
                counter <= 32'b0;
                counter_reset <= 1'b0;
            end
            else begin
                counter <= counter + 1'b1;
            end
            case (state)
                IDLE:begin
                    counter_reset <= 1'b0;
                    start_dut <= 1'b0;
                    i2c_addrr_dut <= 8'b0;
                    i2c_data_addrr_i_dut <= 8'b0;
                    i2c_data_i_dut <= 8'b0;
                    state <= (start_lcd) ? ((!lcd_initialize_ok) ? (INITIALIZE_LCD) : (WRITE_LCD)) : (IDLE);
                    counter_reset <= (start_lcd) ? (1'b0) : (1'b1);
                end
                INITIALIZE_LCD:begin
                    case (state_1)
                        PART_1:begin
                            if (counter==TIME_20ms)begin
                                counter_reset <= 1'b1;
                                wait_ok <= 1'b1;
                            end
                            else begin
                                wait_ok <= 1'b0;
                            end
                            
                            if (wait_ok && !start_dut)begin
                                send_sequence_i2c(8'h4e,8'h3C,8'h38);
                                if (counter_1==10'd2)begin
                                    state_1 <= PART_2;
                                    wait_ok <= 1'b0;
                                    counter_1 <= 12'b0;
                                end
                                else begin
                                    state_1 <= PART_1;
                                    wait_ok <= 1'b1;
                                    counter_1 <= counter_1 + 1;
                                end
                            end
                            else begin
                                start_dut <= 1'b0;
                            end
                        end 
                        PART_2:begin
                            if (counter==TIME_5ms)begin
                                counter_reset <= 1'b1;
                                wait_ok <= 1'b1;
                            end
                            else begin
                                wait_ok <= 1'b0;
                            end
                            
                            if (wait_ok && !start_dut)begin
                                send_sequence_i2c(8'h4e,8'h2C,8'h28);   // high nibble  - blink cursor
                                state_1 <= PART_1;
                                state <= WRITE_LCD;
                                lcd_initialize_ok <= 1'b1;
                            end
                            else begin
                                start_dut <= 1'b0;
                            end
                        end
                    endcase
                end
                WRITE_LCD:begin
                    if (counter==TIME_3ms)begin
                        counter_reset <= 1'b1;
                        wait_ok <= 1'b1;
                    end
                    else begin
                        wait_ok <= 1'b0;
                    end
                    
                    if (wait_ok && !start_dut)begin
                        if (counter_1 <= 10'd15) begin
                            send_sequence_i2c(sequences[counter_1][0], sequences[counter_1][1], sequences[counter_1][2]);
                            counter_1 <= counter_1 + 1;
                        end else begin
                            counter_1 <= 10'd0;
                            state <= COMPLETED;
                        end
                    end
                    else begin
                        start_dut <= 1'b0;
                    end
                end
                COMPLETED: begin
                    if (!start_lcd) state <= IDLE;  // Wait for start_lcd to be reset
                    start_dut <= 1'b0;
                end
            endcase
        end
    end
    
    task send_sequence_i2c;
        input [7:0] i2c_addr;
        input [7:0] data_addr;
        input [7:0] data;
    
        begin
            start_dut <= 1'b1;
            i2c_addrr_dut <= i2c_addr;
            i2c_data_addrr_i_dut <= data_addr;
            i2c_data_i_dut <= data;
            wait_ok <= 1'b0;
        end
    endtask
endmodule
