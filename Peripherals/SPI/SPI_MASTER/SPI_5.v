module SPI_5(
    input clk,      // Internal Clock - 100 MHz - 10ns e3
    input rst,  // sw 1
    input clk_ss,   // 0 means 400_000Hz, 1 means 25_000_000Hz  sw0
    
    input spi_start,    // sw 2
    input [1:0] mode,
    input [5:0] response_length,        // represent in byte
    input [9:0] receive_data_length,            // represent in byte
    input [5:0] cmd_length,        // represent in byte
    input [9:0] send_data_length,            // represent in byte
    
    output reg CS,      // Chip Select - Active Low     JA 1
    output reg MOSI,    // Master out Slave in          JA 2
    output reg SCK,     // Clock                        JA 3
    input MISO,         // Master in Slave out          JA 4
    
    output reg busy_spi,    // led 15
    output reg valid_response,  // led 14
    output reg valid_spi    // led13
    );
    
    reg wr_en_fifo;
    reg [7:0] wr_data_fifo;
    reg rd_en_fifo;
    wire [7:0] rd_data_fifo;
    wire empty_fifo;                    // not used 
    wire full_fifo;                     // not used 
    FIFO FIFO_1(
        . clk(clk),
        . rst_n(rst),
        . wr_en(wr_en_fifo),
        . wr_data(wr_data_fifo),
        . rd_en(rd_en_fifo),
        . rd_data(rd_data_fifo),
        . empty(empty_fifo),
        . full(full_fifo)
    );
    
    wire CPOL = mode [1];               // Indicates Clock Polarity
    wire CPHA = mode [0];               // Indicates Clock Phase
    reg [1:0] mode_prev ;               // Used to indicate that mode has been changed clear counter_1
    
    localparam TIME_SLOW = 250/2-1;     // 400 kHz
    localparam TIME_FAST = 10/2-1;       // 25 MHz
    
    reg [19:0] counter_1 ;              // Used to create clock for SCK
    reg  counter_2;                     // Used to arrange SCK for sending data
    reg [19:0] compare_reg_1 ;          // Used to arrange SCK speed according to clk_ss
    reg compare_reg_2;                  // Used to arrange SCK for sending data
    wire compare_reg_3 = (!CPOL) ? (((!SCK) && (!CPHA)) || ((SCK) && (CPHA))) :
                                     (((SCK) && (!CPHA)) || ((!SCK) && (CPHA))); // Used to arrange SCK's Phase
    
    
    reg read_fifo;
    reg SCK_en;
    reg received_started;
    reg [9:0] counter_3;
    reg [3:0] counter_4;
    reg ready;
    reg [9:0] compare_reg;
    reg wait_data;
    reg send_data;
    reg [3:0] i ;
    reg [3:0] t ;
    
    reg [2:0] state;
    parameter IDLE = 0;
    parameter SEND_CMD_AND_DATA = 1;
    parameter WAIT_RESPONSE_AND_DATA = 2;
    parameter VALID_DATA = 3;
    
    always @(posedge clk)begin
        if (rst)begin
            counter_1 <= 20'b0;
            counter_2 <= 1'b0;
            SCK <= 1'b0;
            SCK_en <= 1'b0;
            
            CS <= 1'b1;
            MOSI <= 1'b1;
            
            compare_reg_1 <= 20'b0;
            compare_reg_2 <= 1'b0;
            
            state <= 3'b0;
            counter_3 <= 10'b0;
            counter_4 <= 4'b0;
            ready <= 1'b0;
            received_started <= 1'b0;
            compare_reg <= 10'b0;
            wait_data <= 1'b0;
            send_data <= 1'b0;
            read_fifo <= 1'b0;
            rd_en_fifo <= 1'b0;
            mode_prev <= 2'b0;
            
            busy_spi <= 1'b0;
            valid_spi <= 1'b0;
            valid_response <= 1'b0;
            i <= 4'b0;
            t <= 4'b0;
        end
        else begin
            mode_prev <= mode;
            if (clk_ss && (state==IDLE))begin
                compare_reg_1 <= TIME_FAST;
            end
            else if (!clk_ss && (state==IDLE))begin
                compare_reg_1 <= TIME_SLOW;
            end
            
            if (!rd_en_fifo && read_fifo )begin
                rd_en_fifo <= 1'b1;
            end
            else if (rd_en_fifo && read_fifo)begin
                rd_en_fifo <= 1'b0;
                read_fifo <= 1'b0;
            end
                            //////////////////////////////
                            //For manually buffer data into FIFO
                            //////////////////////////////

                            if (t==0)begin
                                wr_en_fifo <= 1'b1;
                                wr_data_fifo <= 8'h53;
                                t <= t+1;
                            end
                            else if (t==1)begin
                                wr_en_fifo <= 1'b1;
                                wr_data_fifo <= 8'h50;
                                t <= t+1;
                            end
                            else if (t==2)begin
                                wr_en_fifo <= 1'b1;
                                wr_data_fifo <= 8'h49;
                                t <= t+1;
                            end
                            else if (t==3)begin
                                wr_en_fifo <= 1'b1;
                                wr_data_fifo <= 8'h57;
                                t <= t+1;
                            end
                            else if (t==4)begin
                                wr_en_fifo <= 1'b1;
                                wr_data_fifo <= 8'h4f;
                                t <= t+1;
                            end
                            else if (t==5)begin
                                wr_en_fifo <= 1'b1;
                                wr_data_fifo <= 8'h52;
                                t <= t+1;
                            end
                            else if (t==6)begin
                                wr_en_fifo <= 1'b1;
                                wr_data_fifo <= 8'h4b;
                                t <= t+1;
                            end
                            else if (t==7)begin
                                wr_en_fifo <= 1'b1;
                                wr_data_fifo <= 8'h53;
                                t <= t+1;
                            end
                            else begin
                                wr_en_fifo <= 1'b0;
                            end
            if(counter_1==compare_reg_1)begin
                counter_1 <= 20'b0;
                SCK <= (SCK_en) ? (~SCK) : (CPOL);
                if ((counter_4<8) && !ready)begin
                    counter_4 <= counter_4 + 1;
                end
                else begin
                    counter_4 <= 4'b0;
                    ready <= 1'b1;
                end
                case (state)
                    IDLE:begin
                        counter_3 <= 10'b0;
                        valid_response <= 1'b0;
                        valid_spi <= 1'b0;
                        wait_data <= 1'b0;
                        send_data <= 1'b0;
                        SCK_en <= 1'b0;
                        if(spi_start && ready && !empty_fifo)begin
                            state <= SEND_CMD_AND_DATA;
                            CS <= 1'b0;
                            busy_spi <= 1'b1;
                            read_fifo <= 1'b1;
                            counter_2 <= 1'b0;
                            SCK_en <= CPHA;
                        end
                    end
                    SEND_CMD_AND_DATA:begin
                        SCK_en <= 1'b1;
                        compare_reg <= (!send_data) ? (cmd_length-1) : (send_data_length-1);  // daha sonra send_data_length -1 mi olmal? diye bak
                        SCK_en <= 1'b1;
                        compare_reg_2 <= 1'b1;
                        if (counter_2==compare_reg_2)begin
                            counter_2 <= 1'b0;
                            if((counter_3<=compare_reg))begin
                                MOSI <= rd_data_fifo[7-i];
                                if(i == 7) begin
                                    counter_3 <= counter_3 + 1;
                                    read_fifo <= (counter_3==compare_reg) ? (1'b0) : (1'b1);
                                    i <= 0;
                                end else begin
                                    i <= i + 1;
                                end
                            end
                            else begin
                                state <= (!send_data) ? ((response_length==0) ? (VALID_DATA) : (WAIT_RESPONSE_AND_DATA)) : (VALID_DATA);
                                counter_3 <= 10'b0;
                            end
                        end
                        else begin
                            counter_2 <= counter_2 + 1;
                        end
                    end
                    WAIT_RESPONSE_AND_DATA:begin
                        if (compare_reg_3 && !full_fifo) begin
                            received_started <= ((!MISO && !received_started)) ? (1'b1) : (received_started);
                            compare_reg <= (!wait_data) ? (response_length-1) : (receive_data_length-1);
                            if(received_started)begin
                                if (counter_3<=compare_reg)begin
                                    wr_data_fifo[7-i] <= MISO;
                                    if(i == 7) begin
                                        wr_en_fifo <= 1'b1;
                                        counter_3 <= counter_3 + 1;
                                        i <= 0;
                                    end else begin
                                        i <= i + 1;
                                        wr_en_fifo <= 0;
                                    end
                                end
                                else begin
                                    wr_en_fifo <= 0;
                                    received_started <= 1'b0;
                                    counter_3 <= 10'b0;
                                    valid_response <= 1'b1;
                                    if(receive_data_length==0)begin
                                        if(send_data_length==0)begin
                                            state <= VALID_DATA;
                                        end
                                        else begin
                                            state <= SEND_CMD_AND_DATA;
                                            send_data <= 1'b1;
                                        end
                                    end
                                    else if (wait_data) begin 
                                        state <= VALID_DATA;
                                        wait_data <= 1'b0;
                                    end
                                    else begin
                                        if(send_data_length==0)begin
                                            state <= WAIT_RESPONSE_AND_DATA;
                                            wait_data <= 1'b1;
                                        end
                                        else begin
                                            state <= SEND_CMD_AND_DATA;
                                            send_data <= 1'b1;
                                        end
                                    end
                                end
                            end
                        end
                    end
                    VALID_DATA:begin
                        busy_spi <= 1'b0;
                        valid_spi <= 1'b1;
                        CS <= 1'b1;
                        MOSI <= 1'b1;
                        state <= IDLE;
                        ready <= 1'b0;
                    end
                endcase
            end
            else begin
                if (mode_prev!=mode)begin
                    counter_1 <= 20'b0;
                end
                else begin
                    counter_1 <= counter_1 + 1;
                end
            end
        end
    end
endmodule
