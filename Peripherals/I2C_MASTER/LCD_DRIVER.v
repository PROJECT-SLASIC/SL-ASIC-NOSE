module LCD_DRIVER_0(
    input clk,          //
    input rst,          //
    input start_lcd,    //
    
    output scl,         //
    inout sda           //
    );
    
    localparam TIME_20ms = 2000000;
    localparam TIME_5ms = 500000;
    
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
    
    reg [2:0] counter_1;
    reg [31:0] counter;
    reg counter_reset;
    reg wait_ok;
    
    reg [2:0] state_1;
    parameter PART_1 = 0;
    parameter PART_2  = 1;
    
    
    always @(posedge clk)begin
        if (rst)begin
            start_dut <= 1'b0;
            i2c_addrr_dut <= 8'b0;
            i2c_data_addrr_i_dut <= 8'b0;
            i2c_data_i_dut <= 8'b0;
            
            state <= 3'b0;
            state_1 <= 3'b0;
            wait_ok <= 1'b0;
            
            counter <= 32'b0;
            counter_1 <= 3'b0;
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
                    start_dut <= 1'b0;
                    i2c_addrr_dut <= 8'b0;
                    i2c_data_addrr_i_dut <= 8'b0;
                    i2c_data_i_dut <= 8'b0;
                    state <= (start_lcd) ? (INITIALIZE_LCD) : (IDLE);
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
                            
                            if (wait_ok && (!busy_dut || valid_dut) && !start_dut)begin
                                start_dut <= 1'b1;
                                i2c_addrr_dut <= 8'h4e; i2c_data_addrr_i_dut <= 8'h34; i2c_data_i_dut <= 8'h30;
                                state_1 <= (counter_1==3'd2) ? (PART_2) : (PART_1);
                                wait_ok <= (counter_1==3'd2) ? (1'b0) : (wait_ok);
                                counter_1 <= (counter_1==3'd2) ? (3'b0) : (counter_1 + 1);
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
                            
                            if (wait_ok && (!busy_dut || valid_dut))begin
                                start_dut <= 1'b1;
                                i2c_addrr_dut <= 8'h4e; i2c_data_addrr_i_dut <= 8'h24; i2c_data_i_dut <= 8'h20;
                                state_1 <= PART_1;
                                state <= WRITE_LCD;
                                wait_ok <= 1'b0;
                            end
                            else begin
                                start_dut <= 1'b0;
                            end
                        end
                    endcase
//                    // i2c_addrr_tb = -4E = write
//                    // i2c_addrr_tb = -4F = read
//                    start_dut <= (!busy_dut) ? (1'b1) : (1'b0);
//                    i2c_addrr_dut <= 8'h4e; i2c_data_addrr_i_dut <= 8'h80; i2c_data_i_dut <= 8'h41;
//                    state <= (valid_dut) ? (IDLE) : (INITIALIZE_LCD);
                end
                WRITE_LCD:begin
                    if (counter==TIME_20ms)begin
                        counter_reset <= 1'b1;
                        wait_ok <= 1'b1;
                    end
                    else begin
                        wait_ok <= 1'b0;
                    end
                    
                    if (wait_ok && (!busy_dut || valid_dut) && (counter_1==3'd0))begin
                        start_dut <= 1'b1;
                        counter_1 <= counter_1 + 1;
                        i2c_addrr_dut <= 8'h4e; i2c_data_addrr_i_dut <= 8'h04; i2c_data_i_dut <= 8'h00;
                        state_1 <= PART_1;
                        state <= WRITE_LCD;
                        wait_ok <= 1'b0;
                    end
                    else if (wait_ok && (!busy_dut || valid_dut) && (counter_1==3'd1) && !start_dut)begin
                        start_dut <= 1'b1;
                        i2c_addrr_dut <= 8'h4e; i2c_data_addrr_i_dut <= 8'hf4; i2c_data_i_dut <= 8'hf0;
                        state_1 <= PART_1;
                        state <= IDLE;
                        wait_ok <= 1'b0;
                        counter_1 <= (counter_1==3'd1) ? (3'b0) : (counter_1 + 1);
                    end
                    else begin
                        start_dut <= 1'b0;
                    end
                end
            endcase
        end
    end
endmodule
